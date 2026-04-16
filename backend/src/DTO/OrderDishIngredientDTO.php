<?php
namespace App\DTO;

use DateTimeImmutable;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

#[OA\Schema(
    title: "Order Dish Ingredient DTO",
    description: "Represents an ingredient in an ordered dish.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the order dish ingredient"),
        new OA\Property(property: "orderDishId", type: "string", format: "uuid", description: "ID of the parent order dish"),
        new OA\Property(property: "dishIngredient", ref: new Model(type: DishIngredientDTO::class), description: "Original dish ingredient information"),
        new OA\Property(property: "price", type: "string", format: "decimal", description: "Price of the ingredient in the order"),
        new OA\Property(property: "quantity", type: "integer", minimum: 1, description: "Quantity of the ingredient"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Creation timestamp"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update timestamp")
    ],
    type: "object"
)]
class OrderDishIngredientDTO implements \JsonSerializable
{
    public readonly string $id;

    public readonly string $orderDishId;

    public readonly DishIngredientDTO $dishIngredient;

    public readonly string $price;

    public readonly int $quantity;

    public readonly DateTimeImmutable $createdAt;

    public readonly ?DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $orderDishId,
        DishIngredientDTO $dishIngredient,
        string $price,
        int $quantity,
        DateTimeImmutable $createdAt,
        ?DateTimeImmutable $updatedAt,
    ) {
        $this->id = $id;
        $this->orderDishId = $orderDishId;
        $this->dishIngredient = $dishIngredient;
        $this->price = $price;
        $this->quantity = $quantity;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
    }

    public function getFormattedCreatedAt(): string
    {
        return $this->createdAt->format('Y-m-d\TH:i:sP');
    }

    public function getFormattedUpdatedAt(): ?string
    {
        return $this->updatedAt?->format('Y-m-d\TH:i:sP');
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'orderDishId' => $this->orderDishId,
            'dishIngredient' => $this->dishIngredient,
            'price' => $this->price,
            'quantity' => $this->quantity,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}