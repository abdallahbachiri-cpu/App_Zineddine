<?php

namespace App\Service;

use Google\Client as GoogleClient;
use Google\Service\Oauth2 as OAuth2;
use stdClass;

class GoogleOAuthService
{
    private GoogleClient $googleClient;

    public function __construct(string $clientId, string $clientSecret)
    {
        $this->googleClient = new GoogleClient();
        $this->googleClient->setClientId($clientId);
        $this->googleClient->setClientSecret($clientSecret);
        $this->googleClient->addScope(OAuth2::USERINFO_PROFILE);
        $this->googleClient->addScope(OAuth2::USERINFO_EMAIL);

        // Only disable SSL verification in dev environments
        if (getenv('APP_ENV') === 'dev') {
            $this->googleClient->setHttpClient(
                new \GuzzleHttp\Client([
                    'verify' => false, // Disables SSL certificate verification
                ])
            );
        }
    }

    public function getClient(): GoogleClient
    {
        return $this->googleClient;
    }

    public function createAuthUrl(): string
    {
        return $this->googleClient->createAuthUrl();
    }

    public function fetchAccessToken(string $code): string
    {
        $accessToken = $this->googleClient->fetchAccessTokenWithAuthCode($code);

        if (isset($accessToken['error'])) {
            throw new \Exception('Error fetching access token: ' . $accessToken['error']);
        }

        return $accessToken['access_token'];
    }

    public function fetchUserInfo(string $accessToken): stdClass
    {
        $this->googleClient->setAccessToken($accessToken);
        $oauth2Service = new OAuth2($this->googleClient);

        return $oauth2Service->userinfo_v2_me->get()->toSimpleObject();
    }

    /**
     * Validates Google token and returns standardized user data
     * 
     * @throws \RuntimeException If token validation fails or user info is incomplete
     */
    public function validateGoogleToken(string $googleToken): array
    {
        try {
            // Fetch user info from Google
            $userInfo = $this->fetchUserInfo($googleToken);

            // Validate required fields
            if (!isset($userInfo->email, $userInfo->id, $userInfo->given_name)) {
                throw new \RuntimeException('Incomplete user info from Google');
            }

            // Return standardized data structure
            return [
                'email' => (string) $userInfo->email,
                'googleId' => $userInfo->id,
                'firstName' => (string) $userInfo->given_name ?? '',
                'lastName' => (string) $userInfo->family_name ?? '',
                'avatar' => $userInfo->picture ?? null,
                'locale' => (isset($userInfo->locale) && is_string($userInfo->locale)) ? strtolower(substr($userInfo->locale, 0, 2)) : 'en',
            ];
        } catch (\Exception $e) {
            throw new \RuntimeException('Google authentication failed: ' . $e->getMessage());
        }
    }
}
