<?php
namespace App\Exception;

class OrderRefundException extends \RuntimeException
{
    public function __construct(
        string $message,
        private string $stripeCode,
        \Throwable $previous = null
    ) {
        parent::__construct($message, 0, $previous);
    }

    public function getStripeCode(): string
    {
        return $this->stripeCode;
    }
}