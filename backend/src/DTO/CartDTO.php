<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    title: "Cart DTO",
    description: "Represents a buyer's cart (unarchived) with cart dishes and total price.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the cart"),
        new OA\Property(property: "totalPrice", type: "string", format: "decimal", description: "Total price of all cart dishes"),
        new OA\Property(
            property: "dishes",
            type: "array",
            description: "List of dishes in the cart",
            items: new OA\Items(ref: new Model(type: CartDishDTO::class, groups: ['output']))
        ),
    ],
    type: "object"
)]
class CartDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $totalPrice;

    public readonly string $taxTotal;

    public readonly string $grossTotal;

    public readonly array $appliedTaxes;

    /** @var CartDishDTO[] */
    public readonly array $cartDishes;

    public function __construct(
        string $id,
        string $totalPrice,
        string $taxTotal,
        string $grossTotal,
        array $appliedTaxes,
        array $cartDishes
    ) {
        $this->id = $id;
        $this->totalPrice = $totalPrice;
        $this->taxTotal = $taxTotal;
        $this->grossTotal = $grossTotal;
        $this->appliedTaxes = $appliedTaxes;
        $this->cartDishes = $cartDishes;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'totalPrice' => $this->totalPrice,
            'taxTotal' => $this->taxTotal,
            'grossTotal' => $this->grossTotal,
            'appliedTaxes' => (object) $this->appliedTaxes,
            'dishes' => $this->cartDishes
        ];
    }
}
