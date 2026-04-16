<?php

namespace App\Service\DishIngredient;

use App\DTO\DishIngredientDTO;
use App\Entity\DishIngredient;

class DishIngredientMapper
{
    public function mapToDTO(DishIngredient $dishIngredient): DishIngredientDTO
    {
        return new DishIngredientDTO(
            $dishIngredient->getId(),
            $dishIngredient->getPrice(),
            $dishIngredient->isAvailable(),
            $dishIngredient->isSupplement(),
            $dishIngredient->getDish()->getId(),
            $dishIngredient->getIngredient()->getId(),
            $dishIngredient->getIngredient()->getNameFr(),
            $dishIngredient->getIngredient()->getNameEn()
        );
    }

    public function mapToDTOs(array $dishIngredients): array
    {
        return array_map([$this, 'mapToDTO'], $dishIngredients);
    }
}