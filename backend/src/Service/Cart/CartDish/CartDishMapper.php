<?php

namespace App\Service\Cart\CartDish;

use App\DTO\CartDishDTO;
use App\Entity\CartDish;
use App\Helper\MoneyHelper;
use App\Service\Cart\CartDishIngredient\CartDishIngredientMapper;
use App\Service\Cart\CartService;
use App\Service\Dish\DishMapper;

class CartDishMapper
{
    public function __construct(
        private DishMapper $dishMapper,
        private CartDishIngredientMapper $cartDishIngredientMapper,
        private CartService $cartService
    ){}
    public function mapToDTO(CartDish $cartDish): CartDishDTO
    {
        $prices = $this->cartService->calculateCartDishPrices($cartDish);

        return new CartDishDTO(
            id: $cartDish->getId(),
            cartId: $cartDish->getCart()->getId(),
            dish: $this->dishMapper->mapToDTO($cartDish->getDish()),
            quantity: $cartDish->getQuantity(),
            createdAt: $cartDish->getCreatedAt(),
            updatedAt: $cartDish->getUpdatedAt(),
            ingredients: $this->cartDishIngredientMapper->mapToDTOs($cartDish->getIngredients()->toArray()),
            dishUnitPrice: MoneyHelper::decimalToString($prices['dishUnitPrice']),
            dishSubtotal: MoneyHelper::decimalToString($prices['dishSubtotal']),
            totalIngredientPrice: MoneyHelper::decimalToString($prices['totalIngredientPrice']),
            totalPrice: MoneyHelper::decimalToString($prices['totalPrice'])
        );
    }
    public function mapToDTOs(array $cartDishes): array
    {
        return array_map([$this, 'mapToDTO'], $cartDishes);
    }
}
