<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

/**
 * Issues Mercure subscriber JWT tokens for authenticated dashboard users.
 *
 * The React frontend calls GET /api/mercure/token after login to obtain
 * a signed JWT it can attach to EventSource subscriptions.
 *
 * NOTE: requires symfony/mercure-bundle — run:
 *   composer require symfony/mercure-bundle
 */
#[IsGranted('IS_AUTHENTICATED_FULLY')]
class MercureController extends AbstractController
{
    public function __construct(
        private readonly Security $security
    ) {}

    #[Route('/api/mercure/token', name: 'mercure_token', methods: ['GET'])]
    public function getToken(Request $request): JsonResponse
    {
        $user = $this->security->getUser();

        // Build the list of topics this user may subscribe to
        $topics = ['/orders/all'];  // admin & seller both subscribe to the global feed

        $mercureSecret = $_ENV['MERCURE_JWT_SECRET'] ?? 'CuisinousSecretKey2024!';
        $hubUrl        = $_ENV['MERCURE_PUBLIC_URL'] ?? 'http://localhost:3001/.well-known/mercure';

        $token = $this->generateSubscriberJwt($topics, $mercureSecret);

        return new JsonResponse([
            'token'  => $token,
            'hubUrl' => $hubUrl,
        ]);
    }

    /**
     * Generates a HS256-signed JWT accepted by the Mercure hub as a subscriber token.
     * No external library required — uses PHP's native hash_hmac.
     */
    private function generateSubscriberJwt(array $topics, string $secret): string
    {
        $header  = $this->base64UrlEncode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
        $payload = $this->base64UrlEncode(json_encode([
            'mercure' => ['subscribe' => $topics],
            'iat'     => time(),
            'exp'     => time() + 3600,
        ]));

        $signature = $this->base64UrlEncode(
            hash_hmac('sha256', "{$header}.{$payload}", $secret, true)
        );

        return "{$header}.{$payload}.{$signature}";
    }

    private function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
