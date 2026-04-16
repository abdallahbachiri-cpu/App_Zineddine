<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    schema: "CartDishDTO",
    title: "Cart Dish DTO",
    description: "Represents a dish in a buyer's cart.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier for the cart dish"),
        new OA\Property(property: "cartId", type: "string", format: "uuid", description: "Unique identifier of the cart"),
        new OA\Property(property: "dish", ref: new Model(type: DishDTO::class, groups: ['output'])),
        new OA\Property(property: "quantity", type: "integer", description: "Quantity of the dish in the cart"),
        new OA\Property(
            property: "ingredients",
            type: "array",
            description: "List of supplement ingredients added to the cart dish",
            items: new OA\Items(ref: new Model(type: CartDishIngredientDTO::class))
        ),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Timestamp when the cart dish was added"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Timestamp when the cart dish was last updated"),
        new OA\Property(property: "dishUnitPrice", type: "string", format: "decimal", description: "Base price of the dish"),
        new OA\Property(property: "dishSubtotal", type: "string", format: "decimal", description: "Subtotal price of the dish before ingredients, considering quantity"),
        new OA\Property(property: "totalIngredientPrice", type: "string", format: "decimal", description: "Total price of all added supplement ingredients"),
        new OA\Property(property: "totalPrice", type: "string", format: "decimal", description: "Final total price including dish and ingredients")
    ],
    type: "object"
)]
class CartDishDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $cartId;

    public readonly DishDTO $dish;

    public readonly int $quantity;

    /** @var CartDishIngredientDTO[] */
    public readonly array $ingredients;

    public readonly \DateTimeImmutable $createdAt;

    public readonly ?\DateTimeImmutable $updatedAt;

    public readonly string $dishUnitPrice;

    public readonly string $dishSubtotal;

    public readonly string $totalIngredientPrice;

    public readonly string $totalPrice;

    public function __construct(
        string $id,
        string $cartId,
        DishDTO $dish,
        int $quantity,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        /** @var CartDishIngredientDTO[] */
        string $dishUnitPrice,
        string $dishSubtotal,
        string $totalIngredientPrice,
        string $totalPrice,
        array $ingredients = [],
    ) {
        $this->id = $id;
        $this->cartId = $cartId;
        $this->dish = $dish;
        $this->quantity = $quantity;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->ingredients = $ingredients;
        $this->dishUnitPrice = $dishUnitPrice;
        $this->dishSubtotal = $dishSubtotal;
        $this->totalIngredientPrice = $totalIngredientPrice;
        $this->totalPrice = $totalPrice;
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
            'cartId' => $this->cartId,
            'dish' => $this->dish,
            'quantity' => $this->quantity,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
            'ingredients' => $this->ingredients,
            'dishUnitPrice' => $this->dishUnitPrice,
            'dishSubtotal' => $this->dishSubtotal,
            'totalIngredientPrice' => $this->totalIngredientPrice,
            'totalPrice' => $this->totalPrice
        ];
    }
}