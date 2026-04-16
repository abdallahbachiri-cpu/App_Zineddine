<?php

namespace App\EventListener;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Event\ExceptionEvent;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\Validator\Exception\ValidationFailedException;
use Symfony\Component\Validator\ConstraintViolationListInterface;
use Symfony\Component\HttpFoundation\RequestStack;

class ExceptionListener
{
    private RequestStack $requestStack;

    public function __construct(RequestStack $requestStack)
    {
        $this->requestStack = $requestStack;
    }

    public function onKernelException(ExceptionEvent $event)
    {
        $exception = $event->getThrowable();
        $response = $this->getExceptionResponse($exception);
        $event->setResponse($response);
        
    }

    private function getExceptionResponse(\Throwable $exception): JsonResponse
    {
        // Handle HTTP-specific exceptions (e.g., 404, 403, 400)
        if ($exception instanceof HttpExceptionInterface) {
            return $this->createJsonResponse($exception->getStatusCode(), $exception->getMessage());
        }

        // Handle 404 (Not Found)
        if ($exception instanceof NotFoundHttpException) {
            return $this->createJsonResponse(404, 'Resource not found.');
        }

        // Handle 403 (Forbidden)
        if ($exception instanceof AccessDeniedHttpException) {
            return $this->createJsonResponse(403, 'Access Denied.');
        }

        // Handle validation errors
        if ($exception instanceof ValidationFailedException) {
            return $this->handleValidationException($exception);
        }

        // Default fallback: Internal Server Error
        return $this->createJsonResponse(500, 'An unexpected error occurred.');
    }

    private function handleValidationException(ValidationFailedException $exception): JsonResponse
    {
        $errors = [];
        foreach ($exception->getViolations() as $violation) {
            $errors[] = [
                'field' => $violation->getPropertyPath(),
                'message' => $violation->getMessage(),
            ];
        }

        return $this->createJsonResponse(400, 'Validation failed.', $errors);
    }

    private function createJsonResponse(int $statusCode, string $message, array $errors = []): JsonResponse
    {
        $responseData = [
            'status' => $statusCode,
            'error' => $message,
        ];

        if (!empty($errors)) {
            $responseData['details'] = $errors;
        }

        return new JsonResponse($responseData, $statusCode);
    }
}
