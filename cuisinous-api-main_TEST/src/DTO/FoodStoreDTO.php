<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(
    title: "Food Store DTO",
    description: "Represents a food store with relevant details.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier of the food store"),
        new OA\Property(property: "name", type: "string", description: "Name of the food store"),
        new OA\Property(property: "description", type: "string", nullable: true, description: "Short description of the food store"),
        new OA\Property(property: "sellerId", type: "string", format: "uuid", description: "Unique identifier of the seller"),
        new OA\Property(property: "isActive", type: "boolean", description: "Whether the food store is active"),
        new OA\Property(
            property: "type",
            type: "string",
            enum: ["home", "professional"],
            description: "Type of food store (home-based or professional establishment)"
        ),
        new OA\Property(
            property: "deliveryOption",
            type: "string",
            enum: ["pickup_only", "both"],
            description: "Available delivery options (pickup only or both pickup and delivery)"
        ),
        new OA\Property(property: "isStripeConnected", type: "boolean", description: "Whether the store is connected to Stripe"),
        new OA\Property(property: "address", ref: new Model(type: LocationDTO::class, groups: ['output']), nullable: true, description: "Address of the food store"),
        new OA\Property(property: "profileImageUrl", type: "string", nullable: true, format: "url", description: "URL of the food store's profile image"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "Food store creation date"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update date"),
        new OA\Property(property: "vendorAgreementAccepted", type: "boolean", description: "Whether the vendor agreement has been accepted"),
        new OA\Property(property: "vendorAgreementAcceptedAt", type: "string", format: "date-time", nullable: true, description: "Date when the vendor agreement was accepted")
    ],
    type: "object"
)]

class FoodStoreDTO implements JsonSerializable
{
    #[Groups(["default", "output"])]
    public readonly string $id;
    #[Groups(["default", "input", "output"])]
    public readonly string $name;
    // @TODO make description translated
    #[Groups(["default", "input", "output"])]
    public readonly ?string $description;
    #[Groups(["default", "output"])]
    public readonly string $sellerId;
    #[Groups(["default", "output"])]
    public readonly bool $isActive;
    #[Groups(["default", "input", "output"])]
    public readonly string $type;
    #[Groups(["default", "input", "output"])]
    public readonly string $deliveryOption;
    #[Groups(["default", "input", "output"])]
    public readonly ?LocationDTO $address;
    #[Groups(["default", "output"])]
    public readonly \DateTimeImmutable $createdAt;
    #[Groups(["default", "output"])]
    public readonly ?\DateTimeImmutable $updatedAt;
    #[Groups(["default", "output"])]
    public readonly ?string $profileImageUrl;

    #[Groups(["default", "output"])]
    public readonly bool $isStripeConnected;
    #[Groups(["default", "output"])]
    public readonly bool $vendorAgreementAccepted;
    #[Groups(["default", "output"])]
    public readonly ?\DateTimeImmutable $vendorAgreementAcceptedAt;


    public function __construct(
        string $id,
        string $name,
        string $sellerId,
        bool $isActive,
        string $type,
        string $deliveryOption,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        ?string $description = null,
        ?LocationDTO $address = null,
        ?string $profileImageUrl = null,
        bool $isStripeConnected = false,
        bool $vendorAgreementAccepted = false,
        ?\DateTimeImmutable $vendorAgreementAcceptedAt = null
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->sellerId = $sellerId;
        $this->isActive = $isActive;
        $this->type = $type;
        $this->deliveryOption = $deliveryOption;

        $this->address = $address;
        $this->profileImageUrl = $profileImageUrl;

        $this->isStripeConnected = $isStripeConnected;
        $this->vendorAgreementAccepted = $vendorAgreementAccepted;
        $this->vendorAgreementAcceptedAt = $vendorAgreementAcceptedAt;

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
            'name' => $this->name,
            'sellerId' => $this->sellerId,
            'isActive' => $this->isActive,
            'type' => $this->type,
            'deliveryOption' => $this->deliveryOption,
            'description' => $this->description,
            'profileImageUrl' => $this->profileImageUrl,
            'isStripeConnected' => $this->isStripeConnected,
            'vendorAgreementAccepted' => $this->vendorAgreementAccepted,
            'vendorAgreementAcceptedAt' => $this->vendorAgreementAcceptedAt?->format('Y-m-d\TH:i:sP'),
            'address' => $this->address?->jsonSerialize(),
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}
