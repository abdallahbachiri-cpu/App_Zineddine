<?php

namespace App\DTO;

use OpenApi\Attributes as OA;
use JsonSerializable;

#[OA\Schema(
    title: "Allergen DTO",
    description: "Allergen details",
    required: ["id", "nameFr", "nameEn", "requiresSpecification"],
    properties: [
        new OA\Property(property: "id", type: "string", example: "123e4567-e89b-12d3-a456-426614174000"),
        new OA\Property(property: "nameFr", type: "string", example: "Arachides"),
        new OA\Property(property: "nameEn", type: "string", example: "Peanuts"),
        new OA\Property(property: "requiresSpecification", type: "boolean", example: false),
    ]
)]
class AllergenDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $nameFr;
    public readonly string $nameEn;
    public readonly bool $requiresSpecification;

    public function __construct(
        string $id,
        string $nameFr,
        string $nameEn,
        bool $requiresSpecification = false,
    ) {
        $this->id = $id;
        $this->nameFr = $nameFr;
        $this->nameEn = $nameEn;
        $this->requiresSpecification = $requiresSpecification;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'nameFr' => $this->nameFr,
            'nameEn' => $this->nameEn,
            'requiresSpecification' => $this->requiresSpecification,
        ];
    }
}
