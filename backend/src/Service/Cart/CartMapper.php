<?php

namespace App\Service\Cart;

use App\DTO\CartDTO;
use App\Entity\Cart;
use App\Service\Cart\CartDish\CartDishMapper;

class CartMapper
{
    public function __construct(
        private CartDishMapper $cartDishMapper,
        private CartService $cartService
    ) {}

    // public function mapToDTO(Cart $cart): CartDTO
    // {
    //     $cartDishes = $cart->getDishes();
    //     $cartDishesDTOs = $this->cartDishMapper->mapToDTOs($cartDishes->toArray());

    //     $totalPrice = array_sum(array_map(fn(CartDishDTO $dto) => $dto->totalPrice, $cartDishesDTOs));

    //     return new CartDTO(
    //         id: $cart->getId(),
    //         totalPrice: $totalPrice,
    //         cartDishes: $cartDishesDTOs
    //     );
    // }

    public function mapToDTO(Cart $cart, array $cartDishes): CartDTO
    {
        $cartDishesDTOs = $this->cartDishMapper->mapToDTOs($cartDishes);

        $pricing = $this->cartService->calculateCartTotalPrice($cartDishesDTOs);

        return new CartDTO(
            id: $cart->getId(),
            totalPrice: $pricing['subtotal'],
            taxTotal: $pricing['taxTotal'],
            grossTotal: $pricing['grossTotal'],
            appliedTaxes: $pricing['appliedTaxes'],
            cartDishes: $cartDishesDTOs,
        );
    }
}
