<?php

namespace App\Helper;
use Brick\Math\BigDecimal;
use Brick\Math\Exception\MathException;
use Brick\Math\Exception\NumberFormatException;
use Brick\Math\RoundingMode;
use InvalidArgumentException;

class MoneyHelper
{
    private const SCALE = 2;
    private const ROUNDING_MODE = RoundingMode::HALF_UP;


    /**
     * Normalize amount for storage (e.g., DB) — always returns string like "12.34"
     */
    public static function normalize(float|string $amount): string
    {
        return self::decimal($amount)->toScale(self::SCALE, self::ROUNDING_MODE)->__toString();
    }

    /**
     * Format amount for display — always returns string like "12.34"
     */
    public static function format(float|string $amount): string
    {
        return self::normalize($amount); // Same logic for now
    }

    /**
     * Convert amount to BigDecimal safely
     */
    public static function decimal(float|string $amount): BigDecimal
    {
        try {
            // Prevent float precision bugs by casting to string first
            if (is_float($amount)) {
                $amount = number_format($amount, 10, '.', ''); // preserve precision safely
            }

            return BigDecimal::of($amount);
        } catch (NumberFormatException $e) {
            throw new InvalidArgumentException("Invalid amount format: " . $amount, 0, $e);
        }
    }

    /**
     * Convert BigDecimal amount to string safely
     */
    public static function decimalToString(BigDecimal $amount): string
    {
        return $amount->toScale(self::SCALE, self::ROUNDING_MODE)->__toString();
    }

    /**
     * Add two amounts and return string (e.g. "12.34")
     */
    public static function add(float|string $a, float|string $b): string
    {
        return self::decimal($a)->plus(self::decimal($b))
            ->toScale(self::SCALE, self::ROUNDING_MODE)
            ->__toString();
    }

    /**
     * Subtract b from a and return string
     */
    public static function subtract(float|string $a, float|string $b): string
    {
        return self::decimal($a)->minus(self::decimal($b))
            ->toScale(self::SCALE, self::ROUNDING_MODE)
            ->__toString();
    }

    /**
     * Multiply a * b and return string
     */
    public static function multiply(float|string $a, float|string $b): string
    {
        try {
            return self::decimal($a)->multipliedBy(self::decimal($b))
                ->toScale(self::SCALE, self::ROUNDING_MODE)
                ->__toString();
        } catch (MathException $e) {
            throw new InvalidArgumentException("Invalid multiplication input: $a * $b", 0, $e);
        }
    }

    /**
     * Divide a / b and return string
     */
    public static function divide(float|string $a, float|string $b): string
    {
        try {
            return self::decimal($a)->dividedBy(self::decimal($b), self::SCALE, self::ROUNDING_MODE)
                ->__toString();
        } catch (MathException $e) {
            throw new InvalidArgumentException("Division error: $a / $b", 0, $e);
        }
    }

    /**
     * Convert amount to Stripe format (in cents) — always returns int
     */
    public static function toStripeAmount(float|string $amount): int
    {
        return (int) self::decimal($amount)
        ->toScale(self::SCALE, self::ROUNDING_MODE)
        ->multipliedBy(100)
        ->toScale(0, self::ROUNDING_MODE)
        ->__toString();
    }

    /**
     * Check if amount is greater than zero
     */
    public static function isGreaterThanZero(float|string $amount): bool
    {
        return self::decimal($amount)->isGreaterThan(BigDecimal::zero());
    }

    /**
     * Compare two monetary amounts.
     * Returns:
     * -1 if a < b
     *  0 if a == b
     *  1 if a > b
     */
    public static function compare(float|string $a, float|string $b): int
    {
        $decimalA = self::decimal($a);
        $decimalB = self::decimal($b);
        
        return $decimalA->compareTo($decimalB);
    }

    /**
     * Check if amount a is equal to amount b
    */
    public static function equals(float|string $a, float|string $b): bool
    {
        return self::compare($a, $b) === 0;
    }

    /**
     * Check if amount a is less than amount b
     */
    public static function isLessThan(float|string $a, float|string $b): bool
    {
        return self::compare($a, $b) < 0;
    }

    /**
     * Check if amount a is less than or equal to amount b
     */
    public static function isLessThanOrEqual(float|string $a, float|string $b): bool
    {
        return self::compare($a, $b) <= 0;
    }

    /**
     * Check if amount a is greater than amount b
     */
    public static function isGreaterThan(float|string $a, float|string $b): bool
    {
        return self::compare($a, $b) > 0;
    }

    /**
     * Check if amount a is greater than or equal to amount b
     */
    public static function isGreaterThanOrEqual(float|string $a, float|string $b): bool
    {
        return self::compare($a, $b) >= 0;
    }



}
