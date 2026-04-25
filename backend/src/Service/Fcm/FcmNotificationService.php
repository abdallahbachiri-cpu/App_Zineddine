<?php

namespace App\Service\Fcm;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class FcmNotificationService
{
    public function __construct(
        private HttpClientInterface $httpClient,
        private string $projectId,
        private string $credentialsPath
    ) {
    }

    private function getAccessToken(): string
    {
        $sa = json_decode(file_get_contents($this->credentialsPath), true);
        if (!$sa || !isset($sa['private_key'])) {
            throw new \RuntimeException('Invalid Firebase service account JSON at: ' . $this->credentialsPath);
        }

        $now = time() - 300; // subtract 5 min to compensate for local clock skew vs Google NTP
        $header  = $this->base64url(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $payload = $this->base64url(json_encode([
            'iss'   => $sa['client_email'],
            'sub'   => $sa['client_email'],
            'aud'   => 'https://oauth2.googleapis.com/token',
            'iat'   => $now,
            'exp'   => $now + 3600,
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        ]));

        $signingInput = "$header.$payload";
        $privateKey   = openssl_pkey_get_private($sa['private_key']);
        openssl_sign($signingInput, $signature, $privateKey, 'sha256WithRSAEncryption');
        $jwt = "$signingInput." . $this->base64url($signature);

        $response = $this->httpClient->request('POST', 'https://oauth2.googleapis.com/token', [
            'body' => [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'  => $jwt,
            ],
        ]);

        $data = $response->toArray(false);
        if (empty($data['access_token'])) {
            throw new \RuntimeException('Failed to fetch FCM access token: ' . json_encode($data));
        }

        return $data['access_token'];
    }

    private function base64url(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    public function sendNotification(string $deviceToken, string $title, string $body, array $data = []): void
    {
        $url = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
        $accessToken = $this->getAccessToken();

        $message = [
            'token' => $deviceToken,
            'notification' => [
                'title' => $title,
                'body'  => $body,
            ],
        ];

        // Attach data payload — Flutter reads notification.data['key'] to get the order ID
        if (!empty($data)) {
            // FCM data values must all be strings
            $message['data'] = array_map('strval', $data);
        }

        $options = [
            'auth_bearer' => $accessToken,
            'json' => [
                'message' => $message,
            ],
        ];

        // Bypass SSL verification for local Windows dev environment
        $appEnv = $_ENV['APP_ENV'] ?? getenv('APP_ENV') ?: 'prod';
        if ($appEnv === 'dev') {
            $options['verify_peer'] = false;
            $options['verify_host'] = false;
        }

        $response = $this->httpClient->request('POST', $url, $options);
        $response->getContent();
    }
}
?>