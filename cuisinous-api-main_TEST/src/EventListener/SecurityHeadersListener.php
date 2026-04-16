<?php

namespace App\EventListener;

use App\Helper\SecurityHelper;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\Event\RequestEvent;

/**
 * Security Headers Event Listener
 * 
 * Adds security-related headers to all HTTP responses:
 * - Content Security Policy (CSP)
 * - HTTP Strict Transport Security (HSTS)
 * - X-Frame-Options (clickjacking prevention)
 * - X-Content-Type-Options (MIME type sniffing prevention)
 * - X-XSS-Protection (XSS protection)
 * - Referrer-Policy
 * - Permissions-Policy
 */
class SecurityHeadersListener
{
    /**
     * Add security headers to response
     */
    public function onKernelResponse(ResponseEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $response = $event->getResponse();
        $request = $event->getRequest();

        // Skip security headers for API documentation and public static content
        if (preg_match('#^/api/doc|^/bundles/#', $request->getPathInfo())) {
            return;
        }

        // Add rate limit headers from request attributes if available
        $rateLimit = $request->attributes->get('rate_limit');
        if ($rateLimit !== null) {
            SecurityHelper::addRateLimitHeaders($response, $rateLimit);
        }

        // Add comprehensive security headers
        SecurityHelper::addSecurityHeaders($response, [
            'csp' => "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",
            'hsts' => 'max-age=31536000; includeSubDomains; preload',
            'x_content_type' => 'nosniff',
            'x_frame' => 'DENY',
            'x_xss' => '1; mode=block',
            'referrer_policy' => 'strict-origin-when-cross-origin',
        ]);

        // Additional security headers
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('X-Frame-Options', 'DENY');
        
        // Prevent browser caching of sensitive content
        if (preg_match('#^/api/auth|^/api/user#', $request->getPathInfo())) {
            $response->headers->set('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
            $response->headers->set('Pragma', 'no-cache');
        }
    }
}
