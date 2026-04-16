<?php

namespace App\Service\FoodStore;

use App\DTO\FoodStoreVerificationRequestDTO;
use App\Entity\FoodStoreVerificationRequest;
use App\Entity\Media;
use App\Service\Media\MediaMapper;

class FoodStoreVerificationRequestMapper
{
    public function __construct(
        // private MediaMapper $mediaMapper
    ) {}

    public function mapToDTO(FoodStoreVerificationRequest $request): FoodStoreVerificationRequestDTO
    {
        $documentIds = array_map(
            fn(Media $media) => $media->getId(),
            $request->getDocuments()->toArray()
        );

        return new FoodStoreVerificationRequestDTO(
            $request->getId(),
            $request->getFoodStore()->getId(),
            $request->getFoodStore()->getName(),
            $request->getStatus(),
            $documentIds,
            $request->getCreatedAt(),
            $request->getUpdatedAt(),
            $request->getAdminComment(),
            $request->getVerifiedBy()?->getId(),
            $request->getVerifiedBy()?->getFullName()
        );
    }

    public function mapToDTOs(array $requests): array
    {
        return array_map([$this, 'mapToDTO'], $requests);
    }
}