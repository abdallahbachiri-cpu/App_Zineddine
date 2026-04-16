<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    title: "Dish Rating DTO",
    description: "Represents a rating and review for a dish.",
)]
class DishRatingDTO implements JsonSerializable
{
    #[Groups(["output"])]
    public readonly string $id;
    
    #[Groups(["output"])]
    public readonly string $dishId;
    
    #[Groups(["output"])]
    public readonly string $dishName;
    
    #[Groups(["output"])]
    public readonly string $buyerId;
    
    #[Groups(["output"])]
    public readonly string $buyerName;

    #[Groups(["output"])]
    public readonly ?string $buyerProfileImageUrl;
    
    #[Groups(["output"])]
    public readonly string $orderId;
    
    #[Groups(["output"])]
    public readonly string $orderNumber;

    #[Groups(["input", "output"])]
    public readonly int $rating;

    #[Groups(["input", "output"])]
    public readonly ?string $comment;

    #[Groups(["output"])]
    public readonly \DateTimeImmutable $createdAt;

    #[Groups(["output"])]
    public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $dishId,
        string $dishName,
        string $buyerId,
        string $buyerName,
        string $orderId,
        string $orderNumber,
        int $rating,
        ?string $buyerProfileImageUrl,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt = null,
        ?string $comment = null,

    ) {
        $this->id = $id;
        $this->dishId = $dishId;
        $this->dishName = $dishName;
        $this->buyerId = $buyerId;
        $this->buyerName = $buyerName;
        $this->orderId = $orderId;
        $this->orderNumber = $orderNumber;
        $this->rating = $rating;
        $this->comment = $comment;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->buyerProfileImageUrl = $buyerProfileImageUrl;
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
            'dishId' => $this->dishId,
            'dishName' => $this->dishName,
            'buyerId' => $this->buyerId,
            'buyerName' => $this->buyerName,
            'buyerProfileImageUrl' => $this->buyerProfileImageUrl,
            'orderId' => $this->orderId,
            'orderNumber' => $this->orderNumber,
            'rating' => $this->rating,
            'comment' => $this->comment,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}