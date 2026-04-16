<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: "WalletDTO",
    title: "Wallet DTO",
    description: "Represents a food store's wallet with balance information.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the wallet"),
        new OA\Property(property: "foodStoreId", type: "string", format: "uuid", description: "Associated food store ID"),
        new OA\Property(property: "currency", type: "string", description: "Currency code (e.g., USD, CAD)", example: "CAD"),
        new OA\Property(property: "availableBalance", type: "string", format: "decimal", description: "Available balance in the wallet"),
        new OA\Property(property: "isActive", type: "boolean", description: "Whether the wallet is active and can process payouts", example: true),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Wallet creation timestamp"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update timestamp")
    ],
    type: "object"
)]
class WalletDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $foodStoreId;

    public readonly string $currency;

    public readonly string $availableBalance;

    public readonly bool $isActive;

    public readonly \DateTimeImmutable $createdAt;

    public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $foodStoreId,
        string $currency,
        string $availableBalance,
        bool $isActive,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
    ) {
        $this->id = $id;
        $this->foodStoreId = $foodStoreId;
        $this->currency = $currency;
        $this->availableBalance = $availableBalance;
        $this->isActive = $isActive;
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
            'foodStoreId' => $this->foodStoreId,
            'currency' => $this->currency,
            'availableBalance' => $this->availableBalance,
            'isActive' => $this->isActive,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}
