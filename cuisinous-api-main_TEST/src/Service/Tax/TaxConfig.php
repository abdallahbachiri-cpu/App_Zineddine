<?php

namespace App\Service\Tax;

final class TaxConfig
{
    // Québec rates
    private const QUEBEC = [
        'TPS' => ['rate' => "0.05", 'isCompound' => false],
        'TVQ' => ['rate' => "0.09975", 'isCompound' => false],
    ];

    // Ontario
    private const ONTARIO = [
        'HST' => ['rate' => "0.13", 'isCompound' => false],
    ];

    // BC
    private const BC = [
        'GST' => ['rate' => "0.05", 'isCompound' => false],
        'PST' => ['rate' => "0.07", 'isCompound' => false],
    ];

    /**
     * Return tax rates for a given region.
     * Usage: TaxConfig::forRegion('quebec')
     */
    public static function forRegion(string $region): array
    {
        return match (strtolower($region)) {
            'quebec', 'qc' => self::QUEBEC,
            'ontario', 'on' => self::ONTARIO,
            'bc', 'british_columbia' => self::BC,
            default => throw new \InvalidArgumentException("Unsupported region: $region"),
        };
    }
}
