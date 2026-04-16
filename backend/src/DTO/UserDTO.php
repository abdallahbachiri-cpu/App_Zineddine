<?php

namespace App\DTO;

use JsonSerializable;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\Serializer\Annotation\Groups;


#[OA\Schema(
    title: "User DTO",
    description: "Represents a user with detailed profile information.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "User ID"),
        new OA\Property(property: "firstName", type: "string", description: "User's first name"),
        new OA\Property(property: "lastName", type: "string", description: "User's last name"),
        new OA\Property(property: "middleName", type: "string", nullable: true, description: "User's middle name"),
        new OA\Property(property: "email", type: "string", format: "email", nullable: true, description: "User's email address"),
        new OA\Property(property: "type", type: "string", nullable: true, description: "User type"),
        new OA\Property(property: "roles", type: "array", items: new OA\Items(type: "string"), description: "User roles"),
        new OA\Property(property: "phoneNumber", type: "string", nullable: true, description: "Phone number"),
        new OA\Property(property: "isActive", type: "boolean", description: "Whether the user is active"),
        new OA\Property(property: "isPhoneConfirmed", type: "boolean", description: "Whether the phone number is confirmed"),
        new OA\Property(property: "isDeleted", type: "boolean", description: "Whether the user is deleted"),
        new OA\Property(property: "createdAt", type: "string", format: "date-time", description: "User creation date"),
        new OA\Property(property: "updatedAt", type: "string", format: "date-time", nullable: true, description: "Last update date"),
        new OA\Property(property: "deletedAt", type: "string", format: "date-time", nullable: true, description: "Deletion date"),
        new OA\Property(property: "defaultAddress", ref: new Model(type: LocationDTO::class, groups: ['output']), nullable: true, description: "User's default address"),
        new OA\Property(property: "isEmailConfirmed", type: "boolean", description: "Whether the email is confirmed"),
        new OA\Property(property: "isRegisteredFromGoogle", type: "boolean", description: "Whether the user registered via Google OAuth"),
        new OA\Property(property: "needsGoogleOnboarding", type: "boolean", description: "Whether the user needs to complete Google onboarding"),
        new OA\Property(property: "fullName", type: "string", description: "User's full name (derived)"),
        new OA\Property(property: "status", type: "string", enum: ["active", "inactive", "deleted"], description: "User's current status"),
        new OA\Property(property: "profileImageUrl", type: "string", nullable: true, format: "url", description: "URL of the user's profile image"),
        new OA\Property(property: "locale", type: "string", enum: ["en", "fr"], default: "en", description: "User's preferred locale")
    ]
)]
class UserDTO implements JsonSerializable
{
    #[Groups(["default"])]
    public readonly string $id;
    #[Groups(["default"])]
    public readonly string $firstName;
    #[Groups(["default"])]
    public readonly string $lastName;
    #[Groups(["default"])]
    public readonly ?string $middleName;

    #[Groups(["default"])]
    public readonly ?string $email;

    #[Groups(["default"])]
    public readonly ?string $type;

    #[Groups(["default"])]
    public readonly array $roles;
    #[Groups(["default"])]
    public readonly ?string $phoneNumber;

    public readonly string $locale;

    #[Groups(["default"])]
    public readonly bool $isActive;
    #[Groups(["default"])]
    public readonly bool $isPhoneConfirmed;
    #[Groups(["default"])]
    public readonly bool $isEmailConfirmed;
    #[Groups(["default"])]
    public readonly bool $isDeleted;

    #[Groups(["default"])]
    public readonly \DateTimeImmutable $createdAt;
    #[Groups(["default"])]
    public readonly ?\DateTimeImmutable $updatedAt;
    #[Groups(["default"])]
    public readonly ?\DateTimeImmutable $deletedAt;

    #[Groups(["default"])]
    public readonly ?LocationDTO $defaultAddress;

    #[Groups(["default", "output"])]
    public readonly ?string $profileImageUrl;

    #[Groups(["default"])]
    public readonly bool $needsGoogleOnboarding;

    #[Groups(["default"])]
    public readonly bool $isRegisteredFromGoogle;

    // Constructor updated to allow flexible DateTimeImmutable input
    public function __construct(
        string $id,
        string $firstName,
        string $lastName,
        string $locale,
        array $roles,
        bool $isActive,
        bool $isPhoneConfirmed,
        bool $isEmailConfirmed,
        bool $isDeleted,
        bool $isRegisteredFromGoogle,
        bool $needsGoogleOnboarding,
        \DateTimeImmutable $createdAt,
        ?\DateTimeImmutable $updatedAt,
        ?string $email = null,
        ?string $type = null,
        ?string $middleName = null,
        ?string $phoneNumber = null,
        ?\DateTimeImmutable $deletedAt = null,
        ?LocationDTO $defaultAddress = null,
        ?string $profileImageUrl = null
    ) {
        $this->id = $id;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->middleName = $middleName;
        $this->email = $email;
        $this->type = $type;
        $this->roles = $roles;
        $this->phoneNumber = $phoneNumber;
        $this->isActive = $isActive;
        $this->isPhoneConfirmed = $isPhoneConfirmed;
        $this->isEmailConfirmed = $isEmailConfirmed;
        $this->isDeleted = $isDeleted;
        
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->deletedAt = $deletedAt;
        $this->defaultAddress = $defaultAddress;
        $this->profileImageUrl = $profileImageUrl;

        $this->locale = $locale;
        $this->isRegisteredFromGoogle = $isRegisteredFromGoogle;
        $this->needsGoogleOnboarding = $needsGoogleOnboarding;
    }

    // Format the full name
    public function getFullName(): string
    {
        return implode(' ', array_filter(array_map('trim', [$this->firstName, $this->middleName, $this->lastName])));
    }

    // Determine the status (active, inactive, or deleted)
    public function getStatus(): string
    {
        return $this->isDeleted ? 'deleted' : ($this->isActive ? 'active' : 'inactive');
    }

    // Return formatted creation date
    public function getFormattedCreatedAt(): string
    {
        return $this->createdAt->format('Y-m-d\TH:i:sP');
    }

    // Return formatted update date
    public function getFormattedUpdatedAt(): ?string
    {
        return $this->updatedAt?->format('Y-m-d\TH:i:sP');
    }

    // Return formatted deletion date (nullable)
    public function getFormattedDeletedAt(): ?string
    {
        return $this->deletedAt?->format('Y-m-d\TH:i:sP');
    }

    public function getNormalizedPhoneNumber(): ?string
    {
        return $this->phoneNumber ? preg_replace('/\D+/', '', $this->phoneNumber) : null;
    }



    // JSON serialization logic
    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'firstName' => $this->firstName,
            'lastName' => $this->lastName,
            'middleName' => $this->middleName,
            'email' => $this->email,
            'type' => $this->type,
            'locale' => $this->locale,
            'roles' => $this->roles,
            'phoneNumber' => $this->phoneNumber,
            'isActive' => $this->isActive,
            'isPhoneConfirmed' => $this->isPhoneConfirmed,
            'isEmailConfirmed' => $this->isEmailConfirmed,
            'isRegisteredFromGoogle' => $this->isRegisteredFromGoogle,
            'needsGoogleOnboarding' => $this->needsGoogleOnboarding,
            'isDeleted' => $this->isDeleted,
            'createdAt' => $this->getFormattedCreatedAt(),
            'updatedAt' => $this->getFormattedUpdatedAt(),
            'deletedAt' => $this->getFormattedDeletedAt(),
            'fullName' => $this->getFullName(),
            'status' => $this->getStatus(),
            'defaultAddress' => $this->defaultAddress?->jsonSerialize(),
            'profileImageUrl' => $this->profileImageUrl,
        ];
    }
}