<?php

namespace App\Service\Tax;

use App\Helper\MoneyHelper;

class TaxCalculatorService
{
    /**
     * Calculate taxes using MoneyHelper (Brick\Math-based)
     *
     * Returns:
     * [
     *    'taxTotal' => string,
     *    'grossTotal' => string,
     *    'appliedTaxes' => [
     *        'TPS' => ['rate' => 0.05, 'amount' => '2.00'],
     *        'TVQ' => ['rate' => 0.09975, 'amount' => '5.49']
     *    ]
     * ]
     */
    public function calculate(string|float $subtotal, string $region = 'quebec'): array
    {
        $subtotal = MoneyHelper::normalize($subtotal);

        $taxes  = TaxConfig::forRegion($region);

        $amounts = [];
        $taxTotal = "0.00";

        foreach ($taxes as $code => $tax) {
            $rate = $tax['rate'];
            $isCompound = $tax['isCompound'] ?? false;

            $base = $subtotal;

            if ($isCompound) {
                // sum of subtotal + all previously calculated taxes
                $previousTaxTotal = array_reduce($amounts, function ($carry, $item) {
                    return MoneyHelper::add($carry, $item['amount']);
                }, "0.00");

                $base = MoneyHelper::add($subtotal, $previousTaxTotal);
            }
            $taxAmount = MoneyHelper::multiply($base, $rate);

            $amounts[$code] = [
                'rate' => $rate,
                'amount' => MoneyHelper::normalize($taxAmount),
            ];

            $taxTotal = MoneyHelper::add($taxTotal, $taxAmount);
        }

        $grossTotal = MoneyHelper::add($subtotal, $taxTotal);

        $rates = array_map(fn($t) => $t['rate'], $taxes);

        return [
            'taxTotal'      => MoneyHelper::normalize($taxTotal),
            'grossTotal'    => MoneyHelper::normalize($grossTotal),
            'appliedTaxes'  => [
                'rates'   => $rates,
                'amounts' => $amounts,
            ]
        ];
    }
}
