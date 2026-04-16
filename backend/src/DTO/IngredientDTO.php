<?php

namespace App\DTO;
use OpenApi\Attributes as OA;
use JsonSerializable;

#[OA\Schema(
    schema: "IngredientDTO",
    title: "Ingredient",
    description: "Ingredient details with multilingual names",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the ingredient"),
        new OA\Property(property: "nameFr", type: "string", description: "French name of the ingredient", example: "Tomate"),
        new OA\Property(property: "nameEn", type: "string", description: "English name of the ingredient", example: "Tomato"),
        new OA\Property(property: "storeId", type: "string", format: "uuid", description: "ID of the store this ingredient belongs to")
    ],
    required: ["nameFr", "nameEn", "storeId"]
)]
class IngredientDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $nameFr;
    public readonly string $nameEn;
    public readonly string $storeId;

    public function __construct(
        string $id,
        string $nameFr,
        string $nameEn,
        string $storeId
    ) {
        $this->id = $id;
        $this->nameFr = $nameFr;
        $this->nameEn = $nameEn;
        $this->storeId = $storeId;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'nameFr' => $this->nameFr,
            'nameEn' => $this->nameEn,
            'storeId' => $this->storeId,
        ];
    }
}
