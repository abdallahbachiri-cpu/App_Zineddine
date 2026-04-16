<?php

namespace App\DTO;

use App\Helper\MoneyHelper;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

#[OA\Schema(
    title: "Dish Detail DTO",
    description: "Represents a dish offered by a food store. (full detail)",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier for the dish"),
        new OA\Property(property: "name", type: "string", description: "Name of the dish", minLength: 3, maxLength: 255),
        new OA\Property(property: "foodStoreId", type: "string", format: "uuid", description: "Unique identifier of the associated food store"),
        new OA\Property(property: "foodStoreName", type: "string", description: "Name of the associated food store"),
        new OA\Property(property: "foodStoreProfileImageUrl", type: "string", nullable: true, format: "url", description: "URL of the food store's profile image"),
        new OA\Property(property: "foodStoreAddress", ref: new Model(type: LocationDTO::class), nullable: true, description: "Address of the food store"),
        new OA\Property(property: "description", type: "string", nullable: true, description: "Optional description of the dish", minLength: 3, maxLength: 1500),
        new OA\Property(property: "price", type: "string", format: "decimal", description: "Price of the dish", minimum: 0),
        new OA\Property(property: "available", type: "boolean", description: "Indicates whether the dish is available", default: true),
        new OA\Property(property: "averageRating", type: "number", format: "float", description: "Average rating of the dish", minimum: 0, maximum: 5),
        new OA\Property(property: "ratingCount", type: "integer", description: "Number of ratings for the dish", minimum: 0),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Timestamp when the dish was created"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Timestamp when the dish was last updated"),
        new OA\Property(
            property: "gallery",
            type: "array",
            description: "List of media files related to the dish",
            items: new OA\Items(ref: new Model(type: MediaDTO::class, groups: ['output']))
        ),
        new OA\Property(
            property: "ingredients",
            type: "array",
            description: "List of ingredients related to the dish (DishIngredientDTO)",
            items: new OA\Items(ref: new Model(type: DishIngredientDTO::class))
        ),
        new OA\Property(
            property: "categories",
            type: "array",
            description: "List of categories for the dish",
            items: new OA\Items(ref: new Model(type: CategoryDTO::class))
        ),
        new OA\Property(
            property: "allergens",
            type: "array",
            description: "List of allergens for the dish (DishAllergenDTO)",
            items: new OA\Items(ref: new Model(type: DishAllergenDTO::class))
        )
    ],
    required: ["name", "price", "foodStoreId"],
    type: "object"
)]
class DishDetailDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $name;
    public readonly string $foodStoreId;
    public readonly string $foodStoreName;
    public readonly ?string $foodStoreProfileImageUrl;
    public readonly ?LocationDTO $foodStoreAddress;
    public readonly ?string $description;
    public readonly string $price;
    public readonly bool $available;
    public readonly \DateTimeImmutable $createdAt;
    public readonly ?\DateTimeImmutable $updatedAt;
    /** @var MediaDTO[] */
    public readonly array $gallery;

    /** @var DishIngredientDTO[] */
    public readonly array $ingredients;

    /** @var CategoryDTO[] */
    public readonly array $categories;

    /** @var DishAllergenDTO[] */
    public readonly array $allergens;

    public readonly float $averageRating;
    public readonly int $ratingCount;

    public function __construct(
        string $id,
        string $name,
        string $price,
        bool $available,
        string $foodStoreId,
        string $foodStoreName,
        ?string $foodStoreProfileImageUrl,
        ?LocationDTO $foodStoreAddress,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        array $gallery = [],
        array $ingredients = [],
        array $categories = [],
        array $allergens = [],
        ?string $description = null,
        float $averageRating = 0.0,
        int $ratingCount = 0
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->price = $price;
        $this->available = $available;
        $this->foodStoreId = $foodStoreId;
        $this->foodStoreName = $foodStoreName;
        $this->foodStoreProfileImageUrl = $foodStoreProfileImageUrl;
        $this->foodStoreAddress = $foodStoreAddress;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->description = $description;
        $this->gallery = $gallery;
        $this->ingredients = $ingredients;
        $this->categories = $categories;
        $this->allergens = $allergens;
        $this->averageRating = $averageRating;
        $this->ratingCount = $ratingCount;
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
            'foodStoreProfileImageUrl' => $this->foodStoreProfileImageUrl,
            'foodStoreAddress' => $this->foodStoreAddress?->jsonSerialize(),
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
            'averageRating' => $this->averageRating,
            'ratingCount' => $this->ratingCount,
            'gallery' => $this->gallery,
            'ingredients' => $this->ingredients,
            'categories' => $this->categories,
            'allergens' => $this->allergens,
        ];
    }
}
