<?php

namespace App\Service\FoodStore;

use App\DTO\FoodStoreDTO;
use App\Entity\FoodStore;
use App\Entity\Location;
use App\Service\Location\LocationMapper;

class FoodStoreMapper
{
    private LocationMapper $locationMapper;

    public function __construct(LocationMapper $locationMapper)
    {
        $this->locationMapper = $locationMapper;
    }

    public function mapToDTO(FoodStore $foodStore): FoodStoreDTO
    {
        $foodStoreLocation = $foodStore->getLocation();
        if ($foodStoreLocation instanceof Location) {
            $foodStoreLocationDTO = $this->locationMapper->mapToDTO($foodStoreLocation);
        } else {
            $foodStoreLocationDTO = null;
        }
        $isStripeConnected = $foodStore->getStripeAccountId() !== null;
        return new FoodStoreDTO(
            $foodStore->getId(),
            $foodStore->getName(),
            $foodStore->getSeller()->getId(),
            $foodStore->isActive(),
            $foodStore->getType()->value,
            $foodStore->getDeliveryOption()->value,
            $foodStore->getCreatedAt(),
            $foodStore->getUpdatedAt(),
            $foodStore->getDescription(),
            $foodStoreLocationDTO,
            $foodStore->getProfileImage() ? $foodStore->getProfileImage()->getUrl() : null,
            $isStripeConnected,
            $foodStore->isVendorAgreementAccepted(),
            $foodStore->getVendorAgreementAcceptedAt(),
            $foodStore->getCommissionRate(),
            $foodStore->isCommissionOverride()
        );
    }

    // Map an array of FoodStore entities to an array of FoodStoreDTOs
    public function mapToDTOs(array $foodStores): array
    {
        return array_map([$this, 'mapToDTO'], $foodStores);
    }
}
