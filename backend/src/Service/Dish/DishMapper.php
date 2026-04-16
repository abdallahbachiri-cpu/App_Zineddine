<?php

namespace App\Service\Dish;

use App\DTO\DishDetailDTO;
use App\DTO\DishDTO;
use App\Entity\Dish;
use App\Entity\Location;
use App\Service\Category\CategoryMapper;
use App\Service\DishAllergen\DishAllergenMapper;
use App\Service\DishIngredient\DishIngredientMapper;
use App\Service\Location\LocationMapper;
use App\Service\Media\MediaMapper;

class DishMapper
{
    public function __construct(
        private MediaMapper $mediaMapper,
        private DishIngredientMapper $dishIngredientMapper,
        private DishAllergenMapper $dishAllergenMapper,
        private CategoryMapper $categoryMapper,
        private LocationMapper $locationMapper,
    ) {}

    public function mapToDTO(Dish $dish): DishDTO
    {
        return new DishDTO(
            $dish->getId(),
            $dish->getName(),
            $dish->getBasePrice(),
            $dish->isAvailable(),
            $dish->getFoodStore()->getId(),
            $dish->getFoodStore()->getName(),
            $dish->getCreatedAt(),
            $dish->getUpdatedAt(),
            $this->mediaMapper->mapToDTOs($dish->getGallery()->toArray()),
            $dish->getDescription(),
            $dish->getCachedAverageRating(),
        );
    }

    // Map an array of Dish entities to an array of DishDTOs
    public function mapToDTOs(array $dishes): array
    {
        return array_map([$this, 'mapToDTO'], $dishes);
    }

    public function mapToDetailDTO(Dish $dish): DishDetailDTO
    {
        $foodStoreLocation = $dish->getFoodStore()->getLocation();
        if ($foodStoreLocation instanceof Location) {
            $foodStoreLocationDTO = $this->locationMapper->mapToDTO($foodStoreLocation);
        } else {
            $foodStoreLocationDTO = null;
        }
        return new DishDetailDTO(
            $dish->getId(),
            $dish->getName(),
            $dish->getBasePrice(),
            $dish->isAvailable(),
            $dish->getFoodStore()->getId(),
            $dish->getFoodStore()->getName(),
            $dish->getFoodStore()->getProfileImage()?->getUrl(),
            $foodStoreLocationDTO,
            $dish->getCreatedAt(),
            $dish->getUpdatedAt(),
            $this->mediaMapper->mapToDTOs($dish->getGallery()->toArray()),
            $this->dishIngredientMapper->mapToDTOs($dish->getDishIngredients()->toArray()),
            $this->categoryMapper->mapToDTOs($dish->getCategories()->toArray()),
            $this->dishAllergenMapper->mapToDTOs($dish->getDishAllergens()->toArray()),
            $dish->getDescription(),
            $dish->getCachedAverageRating(),
            $dish->getRatings()->count()
        );
    }

    // Map an array of Dish entities to an array of DishDTOs
    public function mapToDetailDTOs(array $dishes): array
    {
        return array_map([$this, 'mapToDetailDTO'], $dishes);
    }
}
