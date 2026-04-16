<?php

namespace App\DTO;


use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

#[OA\Schema(
    title: "Order Detail DTO",
    description: "Represents a detailed order with all related information.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the order"),
        new OA\Property(property: "cartId", type: "string", format: "uuid", description: "Associated cart ID"),
        new OA\Property(property: "buyer", ref: new Model(type: UserDTO::class), description: "Buyer information"),
        new OA\Property(property: "store", ref: new Model(type: FoodStoreDTO::class), description: "Food store information"),
        new OA\Property(property: "location", ref: new Model(type: LocationDTO::class), description: "Delivery location"),
        new OA\Property(property: "orderNumber", type: "string", description: "Unique order reference number"),
        new OA\Property(property: "confirmationCode", type: "string", nullable: true, description: "Order confirmation code (only visible to buyer)"),
        new OA\Property(property: "status", type: "string", enum: ["pending", "confirmed", "cancelled", "completed"], description: "Current order status"),
        new OA\Property(property: "paymentStatus", type: "string", enum: ["pending", "processing", "paid", "failed", "refund_requested", "refunded", "refund_failed"], description: "Payment status"),
        new OA\Property(property: "tipPaymentStatus", type: "string", enum: ["processing", "paid", "failed"], nullable: true, description: "Tip payment status"),
        new OA\Property(property: "deliveryStatus", type: "string", enum: ["pending", "transit", "delivered"], description: "Delivery status"),
        new OA\Property(property: "deliveryMethod", type: "string", enum: ["pickup", "delivery"], description: "Delivery method"),
        new OA\Property(property: "totalPrice", type: "string", format: "decimal", description: "Total order price"),
        new OA\Property(property: "taxTotal", type: "string", format: "decimal", description: "Total tax amount"),
        new OA\Property(property: "grossTotal", type: "string", format: "decimal", description: "Gross total including taxes"),
        new OA\Property(property: "appliedTaxes", type: "object", description: "Applied taxes breakdown"),
        new OA\Property(property: "tipAmount", type: "string", format: "decimal", nullable: true, description: "Tip amount for the order"),
        new OA\Property(
            property: "dishes",
            type: "array",
            description: "List of ordered dishes",
            items: new OA\Items(ref: new Model(type: OrderDishDTO::class))
        ),
        new OA\Property(property: "buyerNote", type: "string", nullable: true, description: "Additional notes from the buyer"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Order creation timestamp"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update timestamp")
    ],
    type: "object"
)]
class OrderDetailDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $cartId;

    public readonly UserDTO $buyer;

    public readonly FoodStoreDTO $store;

    public readonly LocationDTO $location;

    public readonly string $orderNumber;

    public readonly ?string $confirmationCode;

    public readonly string $status;

    public readonly string $paymentStatus;

    public readonly ?string $tipPaymentStatus;

    public readonly string $deliveryStatus;

    public readonly string $deliveryMethod;

    public readonly string $totalPrice;

    public readonly string $taxTotal;

    public readonly string $grossTotal;

    public readonly array $appliedTaxes;

    public readonly ?string $tipAmount;

    /** @var OrderDishDTO[] */
    public readonly array $dishes;

    public readonly \DateTimeImmutable $createdAt;

    public readonly ?\DateTimeImmutable $updatedAt;

    public readonly ?string $buyerNote;

    public function __construct(
        string $id,
        string $cartId,
        UserDTO $buyer,
        FoodStoreDTO $store,
        LocationDTO $location,
        string $orderNumber,
        ?string $confirmationCode,
        string $status,
        string $paymentStatus,
        ?string $tipPaymentStatus,
        string $deliveryStatus,
        string $deliveryMethod,
        string $totalPrice,
        string $taxTotal,
        string $grossTotal,
        array $appliedTaxes,
        ?string $tipAmount,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        array $dishes = [],
        ?string $buyerNote = null,
    ) {
        $this->id = $id;
        $this->cartId = $cartId;
        $this->buyer = $buyer;
        $this->store = $store;
        $this->location = $location;
        $this->orderNumber = $orderNumber;
        $this->confirmationCode = $confirmationCode;
        $this->status = $status;
        $this->paymentStatus = $paymentStatus;
        $this->tipPaymentStatus = $tipPaymentStatus;
        $this->deliveryStatus = $deliveryStatus;
        $this->deliveryMethod = $deliveryMethod;
        $this->totalPrice = $totalPrice;
        $this->taxTotal = $taxTotal;
        $this->grossTotal = $grossTotal;
        $this->appliedTaxes = $appliedTaxes;
        $this->tipAmount = $tipAmount;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->dishes = $dishes;
        $this->buyerNote = $buyerNote;
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
            'cartId' => $this->cartId,
            'orderNumber' => $this->orderNumber,
            'confirmationCode' => $this->confirmationCode,
            'status' => $this->status,
            'paymentStatus' => $this->paymentStatus,
            'tipPaymentStatus' => $this->tipPaymentStatus,
            'deliveryStatus' => $this->deliveryStatus,
            'deliveryMethod' => $this->deliveryMethod,
            'totalPrice' => $this->totalPrice,
            'taxTotal' => $this->taxTotal,
            'grossTotal' => $this->grossTotal,
            'appliedTaxes' => $this->appliedTaxes,
            'tipAmount' => $this->tipAmount,
            'buyerNote' => $this->buyerNote,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
            'buyer' => $this->buyer,
            'store' => $this->store,
            'location' => $this->location,
            'dishes' => $this->dishes,
        ];
    }
}
