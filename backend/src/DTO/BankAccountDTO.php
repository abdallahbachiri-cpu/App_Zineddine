<?php
namespace App\DTO;

use JsonSerializable;

class BankAccountDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $foodStoreId;
    public readonly string $accountHolderName;
    public readonly string $formattedTransit;
    public readonly string $institutionNumber;
    public readonly string $maskedAccountNumber;
    public readonly bool $isVerified;
    public readonly ?\DateTimeImmutable $verifiedAt;
    public readonly \DateTimeImmutable $createdAt;
    public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $foodStoreId,
        string $accountHolderName,
        string $formattedTransit,
        string $institutionNumber,
        string $maskedAccountNumber,
        bool $isVerified,
        ?\DateTimeImmutable $verifiedAt,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
    ) {
        $this->id = $id;
        $this->foodStoreId = $foodStoreId;
        $this->accountHolderName = $accountHolderName;
        $this->formattedTransit = $formattedTransit;
        $this->institutionNumber = $institutionNumber;
        $this->maskedAccountNumber = $maskedAccountNumber;
        $this->isVerified = $isVerified;
        $this->verifiedAt = $verifiedAt;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'foodStoreId' => $this->foodStoreId,
            'accountHolderName' => $this->accountHolderName,
            'formattedTransit' => $this->formattedTransit,
            'institutionNumber' => $this->institutionNumber,
            'maskedAccountNumber' => $this->maskedAccountNumber,
            'isVerified' => $this->isVerified,
            'verifiedAt' => $this->verifiedAt?->format('Y-m-d\TH:i:sP'),
            'createdAt' => $this->createdAt->format('Y-m-d\TH:i:sP'),
            'updatedAt' => $this->updatedAt?->format('Y-m-d\TH:i:sP'),
        ];
    }
}