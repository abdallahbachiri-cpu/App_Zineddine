<?php

namespace App\Service\DishRating;

use App\DTO\DishRatingDTO;
use App\Entity\DishRating;

class DishRatingMapper
{
    public function mapToDTO(DishRating $dishRating): DishRatingDTO
    {
        return new DishRatingDTO(
            $dishRating->getId(),
            $dishRating->getDish()->getId(),
            $dishRating->getDish()->getName(),
            $dishRating->getBuyer()->getId(),
            $dishRating->getBuyer()->getFullName(),
            $dishRating->getOrder()->getId(),
            $dishRating->getOrder()->getOrderNumber(),
            $dishRating->getRating(),
            $dishRating->getBuyer()->getProfileImage() ? $dishRating->getBuyer()->getProfileImage()->getUrl() : null,
            $dishRating->getCreatedAt(),
            $dishRating->getUpdatedAt(),
            $dishRating->getComment(),
        );
    }

    public function mapToDTOs(array $dishIngredients): array
    {
        return array_map([$this, 'mapToDTO'], $dishIngredients);
    }
}