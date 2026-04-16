<?php

namespace App\DTO;

use OpenApi\Attributes as OA;
use JsonSerializable;

#[OA\Schema(
    title: "Dish Allergen",
    description: "Represents an allergen assigned to a dish, including specification if required.",
    required: ["id", "specification", "dishId", "allergenId", "allergenNameFr", "allergenNameEn", "requiresSpecification"],
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174000"),
        new OA\Property(property: "specification", type: "string", nullable: true, example: "May contain traces of nuts"),
        new OA\Property(property: "dishId", type: "string", format: "uuid", example: "987e6543-e21b-45d3-b789-123456789abc"),
        new OA\Property(property: "allergenId", type: "string", format: "uuid", example: "555e1234-d56c-78f9-0123-456789abcdef"),
        new OA\Property(property: "allergenNameFr", type: "string", example: "Arachides"),
        new OA\Property(property: "allergenNameEn", type: "string", example: "Peanuts"),
    ]
)]
class DishAllergenDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly ?string $specification;
    public readonly string $dishId;
    public readonly string $allergenId;
    public readonly string $allergenNameFr;
    public readonly string $allergenNameEn;

    public function __construct(
        string $id,
        ?string $specification,
        string $dishId,
        string $allergenId,
        string $allergenNameFr,
        string $allergenNameEn,
    ) {
        $this->id = $id;
        $this->specification = $specification;
        $this->dishId = $dishId;
        $this->allergenId = $allergenId;
        $this->allergenNameFr = $allergenNameFr;
        $this->allergenNameEn = $allergenNameEn;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'specification' => $this->specification,
            'dishId' => $this->dishId,
            'allergenId' => $this->allergenId,
            'allergenNameFr' => $this->allergenNameFr,
            'allergenNameEn' => $this->allergenNameEn,
        ];
    }
}
