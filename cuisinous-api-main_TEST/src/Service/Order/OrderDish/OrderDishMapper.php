<?php

namespace App\Service\Order\OrderDish;

use App\DTO\OrderDishDTO;
use App\Entity\OrderDish;
use App\Service\Dish\DishMapper;
use App\Service\Order\OrderDishIngredient\OrderDishIngredientMapper;

class OrderDishMapper
{
    public function __construct(
        private readonly DishMapper $dishMapper,
        private readonly OrderDishIngredientMapper $orderDishIngredientMapper
    ) {}

    public function mapToDTO(OrderDish $orderDish): OrderDishDTO
    {
        $cartDish = $orderDish->getCartDish();
        $dishDTO = $this->dishMapper->mapToDTO($cartDish->getDish());

        $ingredientDTOs = $this->orderDishIngredientMapper->mapToDTOs(
            $orderDish->getIngredients()->toArray()
        );

        return new OrderDishDTO(
            id: $orderDish->getId(),
            orderId: $orderDish->getOrder()->getId(),
            dish: $dishDTO,
            ingredients: $ingredientDTOs,
            unitPrice: $orderDish->getUnitPrice(),
            baseSubtotalPrice: $orderDish->getBaseSubtotalPrice(),
            totalPrice: $orderDish->getTotalPrice(),
            quantity: $orderDish->getQuantity(),
            createdAt: $orderDish->getCreatedAt(),
            updatedAt: $orderDish->getUpdatedAt()
        );
    }

    /**
     * @param OrderDish[] $orderDishes
     * @return OrderDishDTO[]
     */
    public function mapToDTOs(array $orderDishes): array
    {
        return array_map([$this, 'mapToDTO'], $orderDishes);
    }
}
