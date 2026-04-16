<?php

namespace App\DTO;

use App\Helper\MoneyHelper;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    title: "Dish DTO",
    description: "Represents a dish offered by a food store.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier for the dish"),
        new OA\Property(property: "name", type: "string", description: "Name of the dish", minLength: 3, maxLength: 255),
        new OA\Property(property: "foodStoreId", type: "string", format: "uuid", description: "Unique identifier of the associated food store"),
        new OA\Property(property: "foodStoreName", type: "string", description: "Name of the associated food store"),
        new OA\Property(property: "description", type: "string", nullable: true, description: "Optional description of the dish", minLength: 3, maxLength: 1500),
        new OA\Property(property: "price", type: "number", format: "float", description: "Price of the dish", minimum: 0),
        new OA\Property(property: "available", type: "boolean", description: "Indicates whether the dish is currently available", default: true),
        new OA\Property(property: "averageRating", type: "number", format: "float", description: "Average rating of the dish", minimum: 0, maximum: 5),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Timestamp when the dish was created"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Timestamp when the dish was last updated"),
        new OA\Property(
            property: "gallery",
            type: "array",
            description: "List of media files related to the dish",
            items: new OA\Items(ref: new Model(type: MediaDTO::class, groups: ['output']))
        )
    ],
    required: ["name", "price"],
    type: "object"
)]
class DishDTO implements JsonSerializable
{
    #[Groups(["output"])]
    public readonly string $id;
    #[Groups(["input", "output"])]
    public readonly string $name;
    #[Groups(["output"])]
    public readonly string $foodStoreId;
    #[Groups(["output"])]
    public readonly string $foodStoreName;
    #[Groups(["input", "output"])]
    public readonly ?string $description;
    #[Groups(["input", "output"])]
    public readonly string $price;
    #[Groups(["input", "output"])]
    public readonly bool $available;


    #[Groups(["output"])]
    public readonly float $averageRating;

    // #[Groups(["output"])]
    // public readonly int $ratingCount;

    #[Groups(["output"])]
    public readonly \DateTimeImmutable $createdAt;
    #[Groups(["output"])]
    public readonly ?\DateTimeImmutable $updatedAt;

    #[Groups(["output"])]
    /** @var MediaDTO[] */
    public readonly array $gallery;

    public function __construct(
        string $id,
        string $name,
        string $price,
        bool $available,
        string $foodStoreId,
        string $foodStoreName,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        array $gallery = [],
        ?string $description = null,
        float $averageRating = 0.0,
        // int $ratingCount = 0
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->price = $price;
        $this->available = $available;
        $this->foodStoreId = $foodStoreId;
        $this->foodStoreName = $foodStoreName;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->description = $description;
        $this->gallery = $gallery;
        $this->averageRating = $averageRating;
        // $this->ratingCount = $ratingCount;
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
            'name' => $this->name,
            'description' => $this->description,
            'price' => $this->price,
            'available' => $this->available,
            'foodStoreId' => $this->foodStoreId,
            'foodStoreName' => $this->foodStoreName,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
            'averageRating' => $this->averageRating,
            // 'ratingCount' => $this->ratingCount,
            'gallery' => $this->gallery,
        ];
    }
}