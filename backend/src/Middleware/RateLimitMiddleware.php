<?php

namespace App\Middleware;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\RateLimiter\RateLimiterFactory;
use Symfony\Component\RateLimiter\Exception\RateLimitExceededException;
use Symfony\Component\HttpKernel\Event\RequestEvent;

/**
 * Rate Limiting Middleware
 * 
 * Applies rate limiting to various API endpoints based on their routes.
 * Uses different strategies for authentication, general API, and admin endpoints.
 */
class RateLimitMiddleware
{
    public function __construct(
        private RateLimiterFactory $authLimiter,
        private RateLimiterFactory $passwordResetLimiter,
        private RateLimiterFactory $emailConfirmationLimiter,
        private RateLimiterFactory $apiLimiter,
        private RateLimiterFactory $buyerLimiter,
        private RateLimiterFactory $sellerLimiter,
        private RateLimiterFactory $adminLimiter,
        private RateLimiterFactory $searchLimiter,
        private RateLimiterFactory $webhookLimiter,
    ) {}

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $request = $event->getRequest();
        $pathInfo = $request->getPathInfo();
        $limiter = null;

        // Determine which rate limiter to apply based on the route
        if (preg_match('#^/api/auth/login#', $pathInfo) || preg_match('#^/api/auth/register#', $pathInfo)) {
            $limiter = $this->authLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/user/password-reset#', $pathInfo)) {
            $limiter = $this->passwordResetLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/user/email-confirmation#', $pathInfo)) {
            $limiter = $this->emailConfirmationLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/webhook/stripe#', $pathInfo)) {
            $limiter = $this->webhookLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/admin#', $pathInfo)) {
            $limiter = $this->adminLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/seller#', $pathInfo)) {
            $limiter = $this->sellerLimiter->create($this->getClientIdentifier($request));
        } elseif (preg_match('#^/api/buyer#', $pathInfo)) {
            // Search endpoints within buyer routes get stricter limiting
            if (preg_match('#^/api/buyer.*search#', $pathInfo)) {
                $limiter = $this->searchLimiter->create($this->getClientIdentifier($request));
            } else {
                $limiter = $this->buyerLimiter->create($this->getClientIdentifier($request));
            }
        } elseif (preg_match('#^/api#', $pathInfo) && !preg_match('#^/api/doc#', $pathInfo)) {
            // General API endpoints
            //TODO: use proper handling for search endpoints instead of this generic that may cause issues
            if (preg_match('#search#', $pathInfo)) {
                $limiter = $this->searchLimiter->create($this->getClientIdentifier($request));
            } else {
                $limiter = $this->apiLimiter->create($this->getClientIdentifier($request));
            }
        }

        // Apply rate limiting if a limiter was determined
        if ($limiter !== null) {
            try {
                $limit = $limiter->consume(1);

                $event->getRequest()->attributes->set('rate_limit', [
                    'limit' => $limit->getLimit(),
                    'remaining' => $limit->getRemainingTokens(),
                    'reset_at' => $limit->getRetryAfter(),
                ]);
            } catch (RateLimitExceededException $e) {
                $retryAfter = $e->getRetryAfter();
                $response = new Response(
                    json_encode([
                        'error' => 'Too many requests. Please try again later.',
                        'retry_after' => $retryAfter ? (int)$retryAfter->getTimestamp() : null,
                    ]),
                    Response::HTTP_TOO_MANY_REQUESTS,
                    ['Content-Type' => 'application/json']
                );

                $event->setResponse($response);
            }
        }
    }

    /**
     * Get client identifier for rate limiting.
     * Uses user ID if authenticated, otherwise uses IP address.
     */
    private function getClientIdentifier(Request $request): string
    {
        // Try to get authenticated user
        if ($request->attributes->has('user') && $request->attributes->get('user')) {
            return 'user_' . $request->attributes->get('user')->getId();
        }

        // Fall back to IP address
        return $request->getClientIp() ?? '0.0.0.0';
    }
}
