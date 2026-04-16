<?php
namespace App\Exception;

use App\Helper\ValidationHelper;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Validator\ConstraintViolationListInterface;
use Symfony\Component\HttpKernel\Exception\HttpException;

class ValidationException extends HttpException
{
    private array $errors;

    public function __construct(ConstraintViolationListInterface $violations)
    {
        parent::__construct(JsonResponse::HTTP_BAD_REQUEST, 'Validation failed');
        $this->errors = ValidationHelper::formatErrors($violations);
    }

    public function getErrors(): array
    {
        return $this->errors;
    }
}
