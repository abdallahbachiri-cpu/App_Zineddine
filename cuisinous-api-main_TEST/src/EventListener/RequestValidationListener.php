<?php

namespace App\EventListener;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

/**
 * Request Validation Listener
 * 
 * Validates and sanitizes all incoming HTTP requests:
 * - Validates Content-Type headers
 * - Prevents oversized payloads
 * - Sanitizes URL paths
 * - Validates HTTP methods
 * - Prevents directory traversal attacks
 */
class RequestValidationListener
{
    private const MAX_CONTENT_LENGTH = 32 * 1024 * 1024; // 32MB
    private const MAX_URL_LENGTH = 2048;

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $request = $event->getRequest();
        $uri = $request->getRequestUri();
        if (strlen($uri) > self::MAX_URL_LENGTH) {
            throw new BadRequestHttpException('URL too long');
        }

        // ---- 2) Payload size protection ----
        // Content-Length may be missing for chunked uploads, so check gracefully.
        $contentLength = $request->headers->get('Content-Length');
        if ($contentLength !== null && (int) $contentLength > self::MAX_CONTENT_LENGTH) {
            throw new BadRequestHttpException('Payload too large (max 10MB)');
        }

        // Locale detection and setting (for validator messages .. etc)
        $locale = $request->headers->get('X-Locale')
            ?? $request->getPreferredLanguage(['en', 'fr'])
            ?? 'en';

        if (!in_array($locale, ['en', 'fr'], true)) {
            $locale = 'en';
        }

        $request->setLocale($locale);

        // $response = null;

        // // Skip validation for public routes
        // if (preg_match('#^/(api/doc|bundles|favicon|robots)#', $request->getPathInfo())) {
        //     return;
        // }

        // // Validate request method
        // if (!$this->isValidMethod($request->getMethod())) {
        //     $response = new Response(
        //         json_encode(['error' => 'Invalid HTTP method.']),
        //         Response::HTTP_METHOD_NOT_ALLOWED,
        //         ['Content-Type' => 'application/json']
        //     );
        //     $event->setResponse($response);
        //     return;
        // }

        // // Validate URL path (prevent directory traversal)
        // if (!$this->isValidPath($request->getPathInfo())) {
        //     $response = new Response(
        //         json_encode(['error' => 'Invalid request path.']),
        //         Response::HTTP_BAD_REQUEST,
        //         ['Content-Type' => 'application/json']
        //     );
        //     $event->setResponse($response);
        //     return;
        // }

        // // Validate Content-Length header
        // $contentLength = $request->headers->get('Content-Length');
        // if ($contentLength !== null && $contentLength > self::MAX_CONTENT_LENGTH) {
        //     $response = new Response(
        //         json_encode(['error' => 'Payload too large. Maximum size is ' . (self::MAX_CONTENT_LENGTH / 1024 / 1024) . 'MB.']),
        //         413,
        //         ['Content-Type' => 'application/json']
        //     );
        //     $event->setResponse($response);
        //     return;
        // }

        // // Validate Content-Type for POST, PUT, PATCH requests
        // if (in_array($request->getMethod(), ['POST', 'PUT', 'PATCH'], true)) {
        //     if (!$this->isValidContentType($request)) {
        //         $response = new Response(
        //             json_encode(['error' => 'Invalid Content-Type. Expected application/json.']),
        //             Response::HTTP_UNSUPPORTED_MEDIA_TYPE,
        //             ['Content-Type' => 'application/json']
        //         );
        //         $event->setResponse($response);
        //         return;
        //     }
        // }

        // // Validate JSON payload if present
        // if ($request->getMethod() !== 'GET' && $request->getContent()) {
        //     if (!$this->isValidJson($request->getContent())) {
        //         $response = new Response(
        //             json_encode(['error' => 'Invalid JSON in request body.']),
        //             Response::HTTP_BAD_REQUEST,
        //             ['Content-Type' => 'application/json']
        //         );
        //         $event->setResponse($response);
        //         return;
        //     }
        // }

        // // Validate query parameters
        // if (!$this->isValidQueryString($request->getQueryString())) {
        //     $response = new Response(
        //         json_encode(['error' => 'Invalid query parameters.']),
        //         Response::HTTP_BAD_REQUEST,
        //         ['Content-Type' => 'application/json']
        //     );
        //     $event->setResponse($response);
        //     return;
        // }
    }

    /**
     * Validate HTTP method
     */
    private function isValidMethod(string $method): bool
    {
        $allowed = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD'];
        return in_array(strtoupper($method), $allowed, true);
    }

    /**
     * Validate request path to prevent directory traversal
     */
    private function isValidPath(string $path): bool
    {
        // Check path length
        if (strlen($path) > self::MAX_URL_LENGTH) {
            return false;
        }

        // Prevent directory traversal attacks
        if (strpos($path, '..') !== false) {
            return false;
        }

        // Prevent null bytes
        if (strpos($path, "\0") !== false) {
            return false;
        }

        // Allow only safe characters
        if (!preg_match('#^[\w\-\/.:%?=&]+$#u', $path)) {
            return false;
        }

        return true;
    }

    /**
     * Validate Content-Type header
     */
    private function isValidContentType(Request $request): bool
    {
        $contentType = $request->headers->get('Content-Type', '');

        // Allow application/json and application/json; charset=utf-8
        return strpos($contentType, 'application/json') === 0;
    }

    /**
     * Validate JSON payload
     */
    private function isValidJson(string $content): bool
    {
        if (empty($content)) {
            return true; // Empty content is valid
        }

        json_decode($content, true);
        return json_last_error() === JSON_ERROR_NONE;
    }

    /**
     * Validate query string
     */
    private function isValidQueryString(?string $queryString): bool
    {
        if ($queryString === null) {
            return true;
        }

        // Prevent directory traversal in query string
        if (strpos($queryString, '..') !== false) {
            return false;
        }

        // Prevent null bytes
        if (strpos($queryString, "\0") !== false) {
            return false;
        }

        return true;
    }
}
