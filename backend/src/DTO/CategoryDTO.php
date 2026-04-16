<?php

namespace App\DTO;

use OpenApi\Attributes as OA;
use JsonSerializable;

#[OA\Schema(
    title: "Category DTO",
    description: "Category details",
    required: ["id", "type", "nameFr", "nameEn"],
    properties: [
        new OA\Property(property: "id", type: "string", example: "123e4567-e89b-12d3-a456-426614174000"),
        new OA\Property(property: "type", type: "string", example: "dietary"),
        new OA\Property(property: "nameFr", type: "string", example: "Végétalien"),
        new OA\Property(property: "nameEn", type: "string", example: "Vegan"),
    ]
)]
class CategoryDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $type;
    public readonly string $nameFr;
    public readonly string $nameEn;

    public function __construct(
        string $id,
        string $type,
        string $nameFr,
        string $nameEn,
    ) {
        $this->id = $id;
        $this->type = $type;
        $this->nameFr = $nameFr;
        $this->nameEn = $nameEn;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'nameFr' => $this->nameFr,
            'nameEn' => $this->nameEn,
        ];
    }
}