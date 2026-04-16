<?php

namespace App\EventListener;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\RateLimiter\RateLimiterFactory;
use Symfony\Component\RateLimiter\Exception\RateLimitExceededException;
use Psr\Container\ContainerInterface;
use Psr\Log\LoggerInterface;

/**
 * Rate Limiting Event Listener
 * 
 * Applies rate limiting to API endpoints based on request routes.
 * Prevents brute force attacks, DoS, and resource exhaustion.
 */
class RateLimitListener
{
    private array $limiters = [];

    public function __construct(
        private ContainerInterface $rateLimiters,
        private ?LoggerInterface $logger = null,
    ) {}

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $request = $event->getRequest();
        $pathInfo = $request->getPathInfo();
        $limiterName = $this->determineLimiterName($pathInfo);

        if ($limiterName === null || !$this->rateLimiters->has($limiterName)) {
            return;
        }

        $clientId = $this->getClientIdentifier($request);
        $limiterFactory = $this->rateLimiters->get($limiterName);
        $limiter = $limiterFactory->create($clientId);

        try {
            // First, check if the request would be allowed (without consuming)
            $limit = $limiter->consume(0);
            
            // Check if we have tokens available
            if ($limit->getRemainingTokens() <= 0) {
                // No tokens available - create a fake exception with the limit info
                $retryAfter = $limit->getRetryAfter();
                $response = new Response(
                    json_encode([
                        'error' => 'Too many requests. Please try again later.',
                        'retry_after' => $retryAfter ? $retryAfter->format('c') : null,
                    ]),
                    Response::HTTP_TOO_MANY_REQUESTS,
                    ['Content-Type' => 'application/json']
                );

                $event->setResponse($response);
                return;
            }

            // Now consume 1 token since we passed the check
            $limit = $limiter->consume(1);

            $this->logger?->debug('Rate limit check passed', [
                'client_id' => $clientId,
                'limiter' => $limiterName,
                'limit' => $limit->getLimit(),
                'remaining' => $limit->getRemainingTokens(),
                'path' => $pathInfo,
            ]);

            // Store rate limit info in request attributes for response headers
            $request->attributes->set('rate_limit', [
                'limit' => $limit->getLimit(),
                'remaining' => $limit->getRemainingTokens(),
            ]);
        } catch (RateLimitExceededException $e) {
            $this->logger?->warning('Rate limit exceeded', [
                'client_id' => $clientId,
                'limiter' => $limiterName,
                'path' => $pathInfo,
                'exception' => $e->getMessage(),
            ]);

            $retryAfter = $e->getRetryAfter();
            $response = new Response(
                json_encode([
                    'error' => 'Too many requests. Please try again later.',
                    'retry_after' => $retryAfter ? $retryAfter->format('c') : null,
                ]),
                Response::HTTP_TOO_MANY_REQUESTS,
                ['Content-Type' => 'application/json']
            );

            $event->setResponse($response);
        }
    }

    /**
     * Determine which rate limiter name to use based on request path
     */
    private function determineLimiterName(string $pathInfo): ?string
    {
        // Authentication endpoints - strict limiting
        if (preg_match('#^/api/auth/(login|register)#', $pathInfo)) {
            return 'limiter_auth_limiter';
        }

        // Password reset - very strict
        if (preg_match('#^/api/user/password-reset#', $pathInfo)) {
            return 'limiter_password_reset_limiter';
        }

        // Email confirmation
        if (preg_match('#^/api/user/email-confirmation#', $pathInfo)) {
            return 'limiter_email_confirmation_limiter';
        }

        // Webhooks
        if (preg_match('#^/api/webhook/stripe#', $pathInfo)) {
            return 'limiter_webhook_limiter';
        }

        // Admin endpoints
        if (preg_match('#^/api/admin#', $pathInfo)) {
            return 'limiter_admin_limiter';
        }

        // Seller endpoints
        if (preg_match('#^/api/seller#', $pathInfo)) {
            return 'limiter_seller_limiter';
        }

        // Buyer endpoints
        if (preg_match('#^/api/buyer#', $pathInfo)) {
            // Search within buyer gets stricter limiting
            if (preg_match('#search#', $pathInfo)) {
                return 'limiter_search_limiter';
            }
            return 'limiter_buyer_limiter';
        }

        // General API endpoints
        if (preg_match('#^/api#', $pathInfo) && !preg_match('#^/api/doc#', $pathInfo)) {
            if (preg_match('#search#', $pathInfo)) {
                return 'limiter_search_limiter';
            }
            return 'limiter_api_limiter';
        }

        return null;
    }

    /**
     * Get unique identifier for rate limiting
     * Uses user ID if authenticated, otherwise IP address
     */
    private function getClientIdentifier(Request $request): string
    {
        // If user is authenticated, use their ID
        $user = $request->attributes->get('_user');
        if ($user !== null && method_exists($user, 'getId')) {
            return 'user_' . $user->getId();
        }

        // Fall back to IP address with a consistent format
        $ip = $request->getClientIp();
        
        // Handle X-Forwarded-For header for proxies
        if (empty($ip)) {
            $ip = $request->headers->get('X-Forwarded-For');
            if (!empty($ip)) {
                // Take the first IP in case of multiple
                $ips = explode(',', $ip);
                $ip = trim($ips[0]);
            }
        }

        return 'ip_' . ($ip ?? '0.0.0.0');
    }
}
