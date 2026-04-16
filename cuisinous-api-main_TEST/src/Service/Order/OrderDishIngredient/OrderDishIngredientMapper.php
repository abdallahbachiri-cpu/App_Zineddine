<?php

namespace App\Service\Order\OrderDishIngredient;

use App\DTO\OrderDishIngredientDTO;
use App\Entity\OrderDishIngredient;
use App\Service\DishIngredient\DishIngredientMapper;

class OrderDishIngredientMapper
{
    public function __construct(
        private readonly DishIngredientMapper $dishIngredientMapper,
    ) {}

    public function mapToDTO(OrderDishIngredient $orderDishIngredient): OrderDishIngredientDTO
    {
        $cartDishIngredient = $orderDishIngredient->getCartDishIngredient();
        $dishIngredientDTO = $this->dishIngredientMapper->mapToDTO(
            $cartDishIngredient->getDishIngredient()
        );

        return new OrderDishIngredientDTO(
            id: $orderDishIngredient->getId(),
            orderDishId: $orderDishIngredient->getOrderDish()->getId(),
            dishIngredient: $dishIngredientDTO,
            price: $orderDishIngredient->getPrice(),
            quantity: $orderDishIngredient->getQuantity(),
            createdAt: $orderDishIngredient->getCreatedAt(),
            updatedAt: $orderDishIngredient->getUpdatedAt()
        );
    }

    /**
     * @param OrderDishIngredient[] $orderDishIngredients
     * @return OrderDishIngredientDTO[]
     */
    public function mapToDTOs(array $orderDishIngredients): array
    {
        return array_map([$this, 'mapToDTO'], $orderDishIngredients);
    }
}
