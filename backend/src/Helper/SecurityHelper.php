<?php

namespace App\Helper;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Security Helper
 * 
 * Provides utility methods for common security best practices:
 * - Input sanitization and validation
 * - Output encoding
 * - CORS header management
 * - Security header utilities
 */
class SecurityHelper
{
    /**
     * Sanitize and validate email addresses
     */
    public static function sanitizeEmail(?string $email): ?string
    {
        if ($email === null) {
            return null;
        }

        $email = trim($email);
        
        if (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
            throw new \InvalidArgumentException('Invalid email address format.');
        }

        return strtolower($email);
    }

    /**
     * Sanitize and validate URLs
     */
    public static function sanitizeUrl(?string $url, array $allowedHosts = []): ?string
    {
        if ($url === null) {
            return null;
        }

        $url = trim($url);
        
        if (filter_var($url, FILTER_VALIDATE_URL) === false) {
            throw new \InvalidArgumentException('Invalid URL format.');
        }

        // Check against allowed hosts if specified
        if (!empty($allowedHosts)) {
            $host = parse_url($url, PHP_URL_HOST);
            if ($host === false || !in_array($host, $allowedHosts, true)) {
                throw new \InvalidArgumentException('URL host is not allowed.');
            }
        }

        return $url;
    }

    /**
     * Sanitize string input - trim and remove potentially harmful characters
     */
    public static function sanitizeString(?string $input, int $maxLength = 1000): ?string
    {
        if ($input === null) {
            return null;
        }

        $input = trim($input);
        
        if (strlen($input) > $maxLength) {
            throw new \InvalidArgumentException("Input exceeds maximum length of {$maxLength} characters.");
        }

        // Remove null bytes
        return str_replace("\0", '', $input);
    }

    /**
     * Sanitize integer input
     */
    public static function sanitizeInteger($value, int $min = 0, ?int $max = null): ?int
    {
        if ($value === null) {
            return null;
        }

        $int = filter_var($value, FILTER_VALIDATE_INT, [
            'options' => [
                'min_range' => $min,
                'max_range' => $max,
            ]
        ]);

        if ($int === false) {
            throw new \InvalidArgumentException("Invalid integer. Must be between {$min}" . ($max ? " and {$max}" : ''));
        }

        return $int;
    }

    /**
     * HTML escape output
     */
    public static function escapeHtml(?string $text): ?string
    {
        if ($text === null) {
            return null;
        }

        return htmlspecialchars($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }

    /**
     * JSON encode with security options
     */
    public static function jsonEncode($data): string
    {
        return json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    }

    /**
     * Check if request origin is allowed (CORS validation)
     */
    public static function isOriginAllowed(Request $request, array $allowedOrigins): bool
    {
        $origin = $request->headers->get('Origin');
        
        if ($origin === null) {
            return true; // Same-origin requests don't have Origin header
        }

        return in_array($origin, $allowedOrigins, true);
    }

    /**
     * Add security headers to response
     */
    public static function addSecurityHeaders(Response $response, array $options = []): Response
    {
        $defaults = [
            'csp' => "default-src 'self'",
            'hsts' => 'max-age=31536000; includeSubDomains',
            'x_content_type' => 'nosniff',
            'x_frame' => 'DENY',
            'x_xss' => '1; mode=block',
            'referrer_policy' => 'strict-origin-when-cross-origin',
        ];

        $options = array_merge($defaults, $options);

        // Content Security Policy
        if ($options['csp']) {
            $response->headers->set('Content-Security-Policy', $options['csp']);
        }

        // HTTP Strict Transport Security
        if ($options['hsts']) {
            $response->headers->set('Strict-Transport-Security', $options['hsts']);
        }

        // Prevent MIME type sniffing
        if ($options['x_content_type']) {
            $response->headers->set('X-Content-Type-Options', $options['x_content_type']);
        }

        // Prevent clickjacking (X-Frame-Options)
        if ($options['x_frame']) {
            $response->headers->set('X-Frame-Options', $options['x_frame']);
        }

        // XSS Protection
        if ($options['x_xss']) {
            $response->headers->set('X-XSS-Protection', $options['x_xss']);
        }

        // Referrer Policy
        if ($options['referrer_policy']) {
            $response->headers->set('Referrer-Policy', $options['referrer_policy']);
        }

        // Permissions Policy (replacement for Feature-Policy)
        $response->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');

        return $response;
    }

    /**
     * Add rate limit headers to response
     */
    public static function addRateLimitHeaders(Response $response, array $rateLimitInfo): Response
    {
        if (!empty($rateLimitInfo)) {
            $response->headers->set('X-RateLimit-Limit', (string)$rateLimitInfo['limit']);
            $response->headers->set('X-RateLimit-Remaining', (string)$rateLimitInfo['remaining']);
        }

        return $response;
    }

    /**
     * Validate request content type
     */
    public static function validateContentType(Request $request, string $expectedType = 'application/json'): bool
    {
        $contentType = $request->headers->get('Content-Type', '');
        
        return strpos($contentType, $expectedType) === 0;
    }

    /**
     * Generate secure random token
     */
    public static function generateToken(int $length = 32): string
    {
        return bin2hex(random_bytes($length));
    }

    /**
     * Check if request is from a trusted IP
     */
    public static function isTrustedIp(Request $request, array $trustedIps): bool
    {
        $ip = $request->getClientIp();
        
        return in_array($ip, $trustedIps, true);
    }

    /**
     * Get safe request method
     */
    public static function getSafeMethod(Request $request): string
    {
        $method = strtoupper($request->getMethod());
        
        // Only allow standard HTTP methods
        $allowed = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD'];
        
        if (!in_array($method, $allowed, true)) {
            throw new \InvalidArgumentException("Invalid HTTP method: {$method}");
        }

        return $method;
    }
}
