<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class AppleOAuthService
{
    private const APPLE_JWKS_URL = 'https://appleid.apple.com/auth/keys';
    private const APPLE_ISSUER = 'https://appleid.apple.com';

    public function __construct(
        private HttpClientInterface $httpClient,
        private string $bundleId
    ) {}

    /**
     * Validates an Apple identity token (JWT) and returns standardized user data.
     *
     * @throws \RuntimeException If token validation fails or user info is incomplete
     */
    public function validateAppleToken(string $identityToken, array $clientData = []): array
    {
        $parts = explode('.', $identityToken);
        if (count($parts) !== 3) {
            throw new \RuntimeException('Invalid Apple identity token format');
        }

        [$headerB64, $payloadB64, $signatureB64] = $parts;

        $header = json_decode($this->base64UrlDecode($headerB64), true);
        $payload = json_decode($this->base64UrlDecode($payloadB64), true);

        if (!is_array($header) || !is_array($payload)) {
            throw new \RuntimeException('Failed to parse Apple identity token');
        }

        // Validate standard claims
        $this->validateClaims($payload);

        // Verify JWT signature against Apple's public keys
        $this->verifySignature($headerB64, $payloadB64, $signatureB64, $header);

        $appleId = $payload['sub'] ?? null;
        if (!$appleId) {
            throw new \RuntimeException('Missing subject (appleId) in Apple token');
        }

        // Email from token; fall back to client-provided email on first sign-in
        $email = $payload['email'] ?? $clientData['email'] ?? null;

        // Names are not in the JWT — Apple only sends them once via the credential object
        $firstName = $clientData['firstName'] ?? '';
        $lastName = $clientData['lastName'] ?? '';

        // Use placeholder names when Apple doesn't provide them (repeat logins)
        if (empty($firstName)) {
            $firstName = 'Apple';
        }
        if (empty($lastName)) {
            $lastName = 'User';
        }

        if (empty($email)) {
            // Generate a private relay-style placeholder so the DB constraint is satisfied
            $email = $appleId . '@privaterelay.appleid.com';
        }

        return [
            'email'     => (string) $email,
            'appleId'   => (string) $appleId,
            'firstName' => (string) $firstName,
            'lastName'  => (string) $lastName,
        ];
    }

    private function validateClaims(array $payload): void
    {
        if (($payload['iss'] ?? '') !== self::APPLE_ISSUER) {
            throw new \RuntimeException('Invalid Apple token issuer');
        }

        if (($payload['exp'] ?? 0) < time()) {
            throw new \RuntimeException('Apple token has expired');
        }

        $aud = $payload['aud'] ?? '';
        // aud can be a string or array
        $audList = is_array($aud) ? $aud : [$aud];
        if (!in_array($this->bundleId, $audList, true)) {
            throw new \RuntimeException('Apple token audience does not match bundle ID');
        }
    }

    private function verifySignature(
        string $headerB64,
        string $payloadB64,
        string $signatureB64,
        array $header
    ): void {
        $kid = $header['kid'] ?? null;
        $alg = $header['alg'] ?? 'RS256';

        if (!$kid) {
            throw new \RuntimeException('Missing kid in Apple token header');
        }

        $jwks = $this->fetchAppleJwks();
        $publicKey = $this->findPublicKey($jwks, $kid, $alg);

        $data = $headerB64 . '.' . $payloadB64;
        $signature = $this->base64UrlDecode($signatureB64);

        $result = openssl_verify($data, $signature, $publicKey, OPENSSL_ALGO_SHA256);

        if ($result !== 1) {
            throw new \RuntimeException('Apple token signature verification failed');
        }
    }

    private function fetchAppleJwks(): array
    {
        $response = $this->httpClient->request('GET', self::APPLE_JWKS_URL);
        $data = $response->toArray();

        if (!isset($data['keys']) || !is_array($data['keys'])) {
            throw new \RuntimeException('Failed to fetch Apple public keys');
        }

        return $data['keys'];
    }

    private function findPublicKey(array $keys, string $kid, string $alg): \OpenSSLAsymmetricKey
    {
        foreach ($keys as $key) {
            if (($key['kid'] ?? '') === $kid && ($key['alg'] ?? '') === $alg) {
                return $this->buildRsaPublicKey($key);
            }
        }

        throw new \RuntimeException("No matching Apple public key found for kid: $kid");
    }

    private function buildRsaPublicKey(array $jwk): \OpenSSLAsymmetricKey
    {
        if (!isset($jwk['n'], $jwk['e'])) {
            throw new \RuntimeException('Invalid JWK: missing n or e');
        }

        $n = $this->base64UrlDecode($jwk['n']);
        $e = $this->base64UrlDecode($jwk['e']);

        // Encode as DER ASN.1 RSA public key then wrap in PEM
        $pem = $this->rsaKeyToPem($n, $e);

        $key = openssl_pkey_get_public($pem);
        if ($key === false) {
            throw new \RuntimeException('Failed to construct RSA public key from Apple JWK');
        }

        return $key;
    }

    /**
     * Encodes RSA modulus + exponent to a PEM public key via DER/ASN.1.
     */
    private function rsaKeyToPem(string $n, string $e): string
    {
        $modulus = $this->encodeAsn1Integer($n);
        $exponent = $this->encodeAsn1Integer($e);

        $sequence = "\x30" . $this->asn1Length(strlen($modulus) + strlen($exponent))
            . $modulus . $exponent;

        // RSA OID: 1.2.840.113549.1.1.1
        $oid = "\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00";

        $bitString = "\x03" . $this->asn1Length(strlen($sequence) + 1) . "\x00" . $sequence;

        $subjectPublicKeyInfo = "\x30" . $this->asn1Length(strlen($oid) + strlen($bitString))
            . $oid . $bitString;

        return "-----BEGIN PUBLIC KEY-----\n"
            . chunk_split(base64_encode($subjectPublicKeyInfo), 64, "\n")
            . "-----END PUBLIC KEY-----\n";
    }

    private function encodeAsn1Integer(string $bytes): string
    {
        // Strip leading null bytes then re-add one if high bit is set (positive int)
        $bytes = ltrim($bytes, "\x00");
        if (ord($bytes[0]) > 0x7f) {
            $bytes = "\x00" . $bytes;
        }
        return "\x02" . $this->asn1Length(strlen($bytes)) . $bytes;
    }

    private function asn1Length(int $length): string
    {
        if ($length < 128) {
            return chr($length);
        }
        $lengthBytes = '';
        $temp = $length;
        while ($temp > 0) {
            $lengthBytes = chr($temp & 0xff) . $lengthBytes;
            $temp >>= 8;
        }
        return chr(0x80 | strlen($lengthBytes)) . $lengthBytes;
    }

    private function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'));
    }
}
