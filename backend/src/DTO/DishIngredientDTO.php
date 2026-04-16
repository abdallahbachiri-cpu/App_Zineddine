<?php

namespace App\DTO;
use OpenApi\Attributes as OA;
use JsonSerializable;

#[OA\Schema(
    title: "Dish Ingredient",
    description: "Represents an ingredient assigned to a dish, including its availability, price, and type (isSupplement or not).",
    required: ["id", "price", "available", "isSupplement", "dishId", "ingredientId", "ingredientNameFr", "ingredientNameEn"],
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174000"),
        new OA\Property(property: "price", type: "string", format: "decimal", example: "1.5"),
        new OA\Property(property: "available", type: "boolean", example: true),
        new OA\Property(property: "isSupplement", type: "boolean", example: false),
        new OA\Property(property: "dishId", type: "string", format: "uuid", example: "987e6543-e21b-45d3-b789-123456789abc"),
        new OA\Property(property: "ingredientId", type: "string", format: "uuid", example: "555e1234-d56c-78f9-0123-456789abcdef"),
        new OA\Property(property: "ingredientNameFr", type: "string", example: "Tomate"),
        new OA\Property(property: "ingredientNameEn", type: "string", example: "Tomato"),
    ]
)]
class DishIngredientDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $price;
    public readonly bool $available;
    public readonly bool $isSupplement;
    public readonly string $dishId;
    public readonly string $ingredientId;
    
    public readonly string $ingredientNameFr;
    public readonly string $ingredientNameEn;

    public function __construct(
        string $id,
        string $price,
        bool $available,
        bool $isSupplement,
        string $dishId,
        string $ingredientId,
        string $ingredientNameFr,
        string $ingredientNameEn
    ) {
        $this->id = $id;
        $this->price = $price;
        $this->available = $available;
        $this->isSupplement = $isSupplement;
        $this->dishId = $dishId;
        $this->ingredientId = $ingredientId;
        $this->ingredientNameFr = $ingredientNameFr;
        $this->ingredientNameEn = $ingredientNameEn;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'price' => $this->price,
            'available' => $this->available,
            'isSupplement' => $this->isSupplement,
            'dishId' => $this->dishId,
            'ingredientId' => $this->ingredientId,
            'ingredientNameFr' => $this->ingredientNameFr,
            'ingredientNameEn' => $this->ingredientNameEn,
        ];
    }
}
