<?php
namespace App\DTO;

use App\DTO\OrderDishIngredientDTO;
use DateTimeImmutable;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

#[OA\Schema(
    title: "Order Dish DTO",
    description: "Represents a dish in an order with its prices and ingredients.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the order dish"),
        new OA\Property(property: "orderId", type: "string", format: "uuid", description: "ID of the parent order"),
        new OA\Property(property: "dish", ref: new Model(type: DishDTO::class), description: "Original dish information"),
        new OA\Property(property: "unitPrice", type: "string", format: "decimal", description: "Unit price of the dish"),
        new OA\Property(property: "baseSubtotalPrice", type: "string", format: "decimal", description: "Base subtotal (unitPrice × quantity)"),
        new OA\Property(property: "totalPrice", type: "string", format: "decimal", description: "Total price including ingredients"),
        new OA\Property(property: "quantity", type: "integer", minimum: 1, description: "Quantity ordered"),
        new OA\Property(
            property: "ingredients",
            type: "array",
            description: "List of ingredients in the ordered dish",
            items: new OA\Items(ref: new Model(type: OrderDishIngredientDTO::class))
        ),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Creation timestamp"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update timestamp")
    ],
    type: "object"
)]
class OrderDishDTO implements \JsonSerializable
{
    public readonly string $id;

    public readonly string $orderId;

    // public readonly CartDishDTO $cartDish;
    public readonly DishDTO $dish;

    /** @var OrderDishIngredientDTO[] */
    public readonly array $ingredients;

    public readonly string $unitPrice;

    public readonly string $baseSubtotalPrice;

    public readonly string $totalPrice;

    public readonly int $quantity;

    public readonly DateTimeImmutable $createdAt;

    public readonly ?DateTimeImmutable $updatedAt;

    /**
     * @param OrderDishIngredientDTO[] $ingredients
     */
    public function __construct(
        string $id,
        string $orderId,
        // CartDishDTO $cartDish,
        DishDTO $dish,
        array $ingredients,
        string $unitPrice,
        string $baseSubtotalPrice,
        string $totalPrice,
        int $quantity,
        DateTimeImmutable $createdAt,
        ?DateTimeImmutable $updatedAt
    ) {
        $this->id = $id;
        $this->orderId = $orderId;
        // $this->cartDish = $cartDish;
        $this->dish = $dish;
        $this->ingredients = $ingredients;
        $this->unitPrice = $unitPrice;
        $this->baseSubtotalPrice = $baseSubtotalPrice;
        $this->totalPrice = $totalPrice;
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
            'orderId' => $this->orderId,
            // 'cartDish' => $this->cartDish,
            'dish' => $this->dish,
            'ingredients' => $this->ingredients,
            'unitPrice' => $this->unitPrice,
            'baseSubtotalPrice' => $this->baseSubtotalPrice,
            'totalPrice' => $this->totalPrice,
            'quantity' => $this->quantity,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}