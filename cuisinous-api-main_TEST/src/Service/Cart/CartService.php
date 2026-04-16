<?php

namespace App\Service\Cart;

use App\DTO\CartDishDTO;
use App\Entity\CartDish;
use App\Entity\CartDishIngredient;
use App\Helper\MoneyHelper;
use App\Service\Tax\TaxCalculatorService;
use Brick\Math\BigDecimal;

class CartService
{
    public function __construct(
        private TaxCalculatorService $taxCalculator
    ) {}

    public function calculateCartDishPrices(CartDish $cartDish): array
    {
        $quantity = $cartDish->getQuantity();

        $dishUnitPrice = MoneyHelper::decimal($cartDish->getDish()->getBasePrice());
        $dishSubtotal = $dishUnitPrice->multipliedBy($quantity);

        $ingredientPrice = array_reduce(
            $cartDish->getIngredients()->toArray(), // cartDishIngredients
            function (BigDecimal $sum, mixed $ingredient): BigDecimal {
                if (!$ingredient instanceof CartDishIngredient || !$ingredient->getDishIngredient()->isSupplement()) {
                    // If the ingredient is not a supplement, skip it
                    return $sum;
                }

                $ingredientPrice = MoneyHelper::decimal($ingredient->getDishIngredient()->getPrice());
                $ingredientQty = $ingredient->getQuantity();

                return $sum->plus($ingredientPrice->multipliedBy($ingredientQty));
            },
            BigDecimal::of('0.00')
        );

        $totalIngredientPrice = $ingredientPrice->multipliedBy($quantity);
        $totalPrice = $dishSubtotal->plus($totalIngredientPrice);

        return [
            'dishUnitPrice' => $dishUnitPrice,
            'dishSubtotal' => $dishSubtotal,
            'totalIngredientPrice' => $totalIngredientPrice,
            'totalPrice' => $totalPrice,
        ];
    }
    public function calculateCartTotalPrice(array $cartDishesDTOs, string $region = 'quebec'): array
    {
        // $region = $cart->getBuyer()->getDefaultAddress()?->getState() ?? $region;
        $subtotal = "0.00";
        foreach ($cartDishesDTOs as $cartDishDTO) {
            if ($cartDishDTO instanceof CartDishDTO) {
                $subtotal = MoneyHelper::add($subtotal, $cartDishDTO->totalPrice);
            }
        }
        // --- TAXES ---
        $taxData = $this->taxCalculator->calculate($subtotal, $region);

        return [
            'subtotal'    => $subtotal,
            'taxTotal'    => $taxData['taxTotal'],
            'grossTotal'  => $taxData['grossTotal'],
            'appliedTaxes' => $taxData['appliedTaxes'],
        ];
    }
}
