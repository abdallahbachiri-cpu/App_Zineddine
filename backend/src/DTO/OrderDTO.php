<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;


#[OA\Schema(
    title: "Order DTO",
    description: "Represents an order with basic information.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the order"),
        new OA\Property(property: "cartId", type: "string", format: "uuid", description: "Associated cart ID"),
        new OA\Property(property: "buyerId", type: "string", format: "uuid", description: "ID of the buyer"),
        new OA\Property(property: "buyerFullName", type: "string", description: "Full name of the buyer"),
        new OA\Property(property: "storeId", type: "string", format: "uuid", description: "ID of the food store"),
        new OA\Property(property: "storeName", type: "string", description: "Name of the food store"),
        new OA\Property(property: "orderNumber", type: "string", description: "Unique order reference number"),
        new OA\Property(property: "confirmationCode", type: "string", nullable: true, description: "Order confirmation code (only visible to buyer)"),
        new OA\Property(property: "status", type: "string", enum: ["pending", "confirmed", "cancelled", "completed"], description: "Current order status"),
        new OA\Property(property: "paymentStatus", type: "string", enum: ["pending", "processing", "paid", "failed", "refund_requested", "refunded", "refund_failed"], description: "Payment status"),
        new OA\Property(property: "deliveryStatus", type: "string", enum: ["pending", "transit", "delivered"], description: "Delivery status"),
        new OA\Property(property: "deliveryMethod", type: "string", enum: ["pickup", "delivery"], description: "Delivery method"),
        new OA\Property(property: "totalPrice", type: "string", format: "decimal", description: "Total order price"),
        new OA\Property(property: "taxTotal", type: "string", format: "decimal", description: "Total tax amount"),
        new OA\Property(property: "grossTotal", type: "string", format: "decimal", description: "Gross total including taxes"),
        new OA\Property(property: "appliedTaxes", type: "object", description: "Applied taxes breakdown"),
        new OA\Property(property: "tipAmount", type: "string", format: "decimal", nullable: true, description: "Tip amount for the order"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Order creation timestamp"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update timestamp")
    ],
    type: "object"
)]
class OrderDTO implements JsonSerializable
{
    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $id;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $cartId;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $buyerId;
    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $buyerFullName;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $storeId;
    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $storeName;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $orderNumber;

    #[Groups(['default', 'buyer'])]
    public readonly ?string $confirmationCode;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $status;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $paymentStatus;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly ?string $tipPaymentStatus;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $deliveryStatus;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $totalPrice;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $taxTotal;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $grossTotal;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly array $appliedTaxes;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly ?string $tipAmount;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly string $deliveryMethod;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly \DateTimeImmutable $createdAt;

    #[Groups(['default', 'buyer', 'seller'])]
    public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $cartId,
        string $buyerId,
        string $buyerFullName,
        string $storeId,
        string $storeName,
        string $orderNumber,
        ?string $confirmationCode,
        string $status,
        string $paymentStatus,
        string $deliveryStatus,
        string $deliveryMethod,
        string $totalPrice,
        string $taxTotal,
        string $grossTotal,
        array $appliedTaxes,
        ?string $tipAmount,
        ?string $tipPaymentStatus,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
    ) {
        $this->id = $id;
        $this->cartId = $cartId;
        $this->buyerId = $buyerId;
        $this->buyerFullName = $buyerFullName;
        $this->storeId = $storeId;
        $this->storeName = $storeName;
        $this->orderNumber = $orderNumber;
        $this->confirmationCode = $confirmationCode;
        $this->status = $status;
        $this->paymentStatus = $paymentStatus;
        $this->deliveryStatus = $deliveryStatus;
        $this->totalPrice = $totalPrice;
        $this->taxTotal = $taxTotal;
        $this->grossTotal = $grossTotal;
        $this->appliedTaxes = $appliedTaxes;
        $this->tipAmount = $tipAmount;
        $this->tipPaymentStatus = $tipPaymentStatus;
        $this->deliveryMethod = $deliveryMethod;
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
            'cartId' => $this->cartId,
            'buyerId' => $this->buyerId,
            'buyerFullName' => $this->buyerFullName,
            'storeId' => $this->storeId,
            'storeName' => $this->storeName,
            'orderNumber' => $this->orderNumber,
            'confirmationCode' => $this->confirmationCode,
            'status' => $this->status,
            'paymentStatus' => $this->paymentStatus,
            'deliveryStatus' => $this->deliveryStatus,
            'deliveryMethod' => $this->deliveryMethod,
            'totalPrice' => $this->totalPrice,
            'taxTotal' => $this->taxTotal,
            'grossTotal' => $this->grossTotal,
            'appliedTaxes' => (object) $this->appliedTaxes,
            'tipAmount' => $this->tipAmount,
            'tipPaymentStatus' => $this->tipPaymentStatus,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}
