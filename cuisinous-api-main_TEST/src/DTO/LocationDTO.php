<?php

namespace App\DTO;

use OpenApi\Attributes as OA;
use JsonSerializable;
use Symfony\Component\Serializer\Attribute\Groups;

#[OA\Schema(
    title: "Location DTO",
    description: "Represents a location with optional address details.",
)]
class LocationDTO implements JsonSerializable
{
    #[Groups(["output"])]
    public readonly string $id;
    #[Groups(["input", "output"])]
    public readonly float $latitude;
    #[Groups(["input", "output"])]
    public readonly float $longitude;
    #[Groups(["input", "output"])]
    public readonly ?string $street;
    #[Groups(["input", "output"])]
    public readonly ?string $city;
    #[Groups(["input", "output"])]
    public readonly ?string $state;
    #[Groups(["input", "output"])]
    public readonly ?string $zipCode;
    #[Groups(["input", "output"])]
    public readonly ?string $country;
    #[Groups(["input", "output"])]
    public readonly ?string $additionalDetails;

    public function __construct(
        string $id,
        float $latitude,
        float $longitude,
        ?string $street = null,
        ?string $city = null,
        ?string $state = null,
        ?string $zipCode = null,
        ?string $country = null,
        ?string $additionalDetails = null
    ) {
        $this->id = $id;
        $this->latitude = $latitude;
        $this->longitude = $longitude;
        $this->street = $street;
        $this->city = $city;
        $this->state = $state;
        $this->zipCode = $zipCode;
        $this->country = $country;
        $this->additionalDetails = $additionalDetails;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'street' => $this->street,
            'city' => $this->city,
            'state' => $this->state,
            'zipCode' => $this->zipCode,
            'country' => $this->country,
            'additionalDetails' => $this->additionalDetails,
        ];
    }
}
