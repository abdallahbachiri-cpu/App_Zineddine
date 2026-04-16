<?php

namespace App\DTO;

use App\Entity\Enum\StoreVerificationStatus;
use JsonSerializable;
use OpenApi\Attributes as OA;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    title: "Food Store Verification Request DTO",
    description: "Represents a verification request for a food store.",
)]
class FoodStoreVerificationRequestDTO implements JsonSerializable
{
    #[Groups(["default", "output"])]
    public readonly string $id;
    
    #[Groups(["default", "output"])]
    public readonly string $foodStoreId;
    
    #[Groups(["default", "output"])]
    public readonly string $foodStoreName;
    
    #[Groups(["default", "output"])]
    public readonly string $status;
    
    #[Groups(["default", "output"])]
    public readonly ?string $adminComment;
    
    #[Groups(["default", "output"])]
    public readonly array $documentIds;
    
    #[Groups(["default", "output"])]
    public readonly ?string $verifiedById;
    
    #[Groups(["default", "output"])]
    public readonly ?string $verifiedByName;
    
    #[Groups(["default", "output"])]
    public readonly \DateTimeImmutable $createdAt;
    
    #[Groups(["default", "output"])]
    public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $foodStoreId,
        string $foodStoreName,
        StoreVerificationStatus $status,
        array $documentIds,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt = null,
        ?string $adminComment = null,
        ?string $verifiedById = null,
        ?string $verifiedByName = null
    ) {
        $this->id = $id;
        $this->foodStoreId = $foodStoreId;
        $this->foodStoreName = $foodStoreName;
        $this->status = $status->value;
        $this->adminComment = $adminComment;
        $this->documentIds = $documentIds;
        $this->verifiedById = $verifiedById;
        $this->verifiedByName = $verifiedByName;
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
            'foodStoreName' => $this->foodStoreName,
            'status' => $this->status,
            'adminComment' => $this->adminComment,
            'documentIds' => $this->documentIds,
            'verifiedById' => $this->verifiedById,
            'verifiedByName' => $this->verifiedByName,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}