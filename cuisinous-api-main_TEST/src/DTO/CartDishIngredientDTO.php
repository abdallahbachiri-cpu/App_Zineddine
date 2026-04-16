<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    schema: "CartDishIngredientDTO",
    title: "Cart Dish Ingredient DTO",
    description: "Represents a supplement ingredient added to a dish in the cart.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier for the cart dish ingredient"),
        new OA\Property(property: "cartDishId", type: "string", format: "uuid", description: "Unique identifier of the cart dish"),
        new OA\Property(property: "ingredient", ref: "#/components/schemas/DishIngredientDTO"),
        new OA\Property(property: "quantity", type: "integer", description: "Quantity of the ingredient added to the cart dish"),
    ],
    type: "object"
)]
class CartDishIngredientDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $cartDishId;

    public readonly DishIngredientDTO $ingredient;

    public readonly int $quantity;

    public function __construct(
        string $id,
        string $cartDishId,
        DishIngredientDTO $ingredient,
        int $quantity
    ) {
        $this->id = $id;
        $this->cartDishId = $cartDishId;
        $this->ingredient = $ingredient;
        $this->quantity = $quantity;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'cartDishId' => $this->cartDishId,
            'ingredient' => $this->ingredient,
            'quantity' => $this->quantity,
        ];
    }
}
