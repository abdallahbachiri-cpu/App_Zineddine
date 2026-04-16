<?php

namespace App\DTO;

use App\Entity\Enum\Wallet\WalletTransactionStatus;
use App\Entity\Enum\Wallet\WalletTransactionType;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    schema: "WalletTransactionDTO",
    title: "Wallet Transaction DTO",
    description: "Represents a transaction in a food store's wallet.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the transaction"),
        new OA\Property(property: "walletId", type: "string", format: "uuid", description: "Associated wallet ID"),
        new OA\Property(property: "type", type: "string", enum: ["order_income", "tip_income", "refund", "withdrawal"], description: "Type of transaction"),
        new OA\Property(property: "status", type: "string", enum: ["pending", "completed", "failed"], description: "Transaction status"),
        new OA\Property(property: "amount", type: "string", format: "decimal", description: "Transaction amount (net)"),
        new OA\Property(property: "grossAmount", type: "string", format: "decimal", nullable: true, description: "Gross amount before commission"),
        new OA\Property(property: "commissionAmount", type: "string", format: "decimal", nullable: true, description: "Commission amount deducted"),
        new OA\Property(property: "commissionRate", type: "string", format: "decimal", nullable: true, description: "Applied Commission rate percentage"),
        new OA\Property(property: "currency", type: "string", description: "Currency code", example: "CAD"),
        new OA\Property(property: "availableAt", type: "string", format: "date-time", nullable: true, description: "When the funds will be available"),
        new OA\Property(property: "note", type: "string", nullable: true, description: "Optional note about the transaction"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Transaction creation timestamp")
    ],
    type: "object"
)]
class WalletTransactionDTO implements JsonSerializable
{
    public readonly string $id;

    public readonly string $walletId;

    public readonly string $currency;

    public readonly string $amount;

    public readonly ?string $grossAmount;

    public readonly ?string $commissionAmount;

    public readonly ?string $commissionRate;

    public readonly string $type;

    public readonly string $status;

    public readonly ?string $availableAt;

    public readonly ?string $note;

    public readonly \DateTimeImmutable $createdAt;

    public function __construct(
        string $id,
        string $walletId,
        string $currency,
        string $amount,
        ?string $grossAmount,
        ?string $commissionAmount,
        ?string $commissionRate,
        string $type,
        string $status,
        ?\DateTimeImmutable $availableAt,
        ?string $note,
        \DateTimeImmutable $createdAt
    ) {
        $this->id = $id;
        $this->walletId = $walletId;
        $this->currency = $currency;
        $this->amount = $amount;
        $this->grossAmount = $grossAmount;
        $this->commissionAmount = $commissionAmount;
        $this->commissionRate = $commissionRate;
        $this->type = $type;
        $this->status = $status;
        $this->availableAt = $availableAt?->format('Y-m-d\TH:i:sP');
        $this->note = $note;
        $this->createdAt = $createdAt;
    }

    public function getFormattedCreatedAt(): string
    {
        return $this->createdAt->format('Y-m-d\TH:i:sP');
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'walletId' => $this->walletId,
            'currency' => $this->currency,
            'amount' => $this->amount,
            'grossAmount' => $this->grossAmount,
            'commissionAmount' => $this->commissionAmount,
            'commissionRate' => $this->commissionRate,
            'type' => $this->type,
            'status' => $this->status,
            'availableAt' => $this->availableAt,
            'note' => $this->note,
            'createdAt' => $this->getFormattedCreatedAt(),
        ];
    }
}
