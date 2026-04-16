<?php

namespace App\Service\Cart\CartDishIngredient;

use App\DTO\CartDishIngredientDTO;
use App\Entity\CartDishIngredient;
use App\Service\DishIngredient\DishIngredientMapper;

class CartDishIngredientMapper
{
    public function __construct(
        private DishIngredientMapper $dishIngredientMapper
    ) {}

    public function mapToDTO(CartDishIngredient $cartDishIngredient): CartDishIngredientDTO
    {
        return new CartDishIngredientDTO(
            $cartDishIngredient->getId(),
            $cartDishIngredient->getCartDish()->getId(),
            $this->dishIngredientMapper->mapToDTO($cartDishIngredient->getDishIngredient()),
            $cartDishIngredient->getQuantity()
        );
    }

    public function mapToDTOs(array $cartDishIngredients): array
    {
        return array_map([$this, 'mapToDTO'], $cartDishIngredients);
    }
}
