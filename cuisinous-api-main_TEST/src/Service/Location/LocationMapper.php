<?php

namespace App\Service\Location;

use App\DTO\LocationDTO;
use App\Entity\Location;

class LocationMapper
{
    public function mapToDTO(Location $location): LocationDTO
    {
        return new LocationDTO(
            $location->getId(),
            $location->getLatitude(),
            $location->getLongitude(),
            $location->getStreet(),
            $location->getCity(),
            $location->getState(),
            $location->getZipCode(),
            $location->getCountry(),
            $location->getAdditionalDetails()
        );
    }

    // Map an array of Location entities to an array of LocationDTOs
    public function mapToDTOs(array $locations): array
    {
        return array_map([$this, 'mapToDTO'], $locations);
    }
}
