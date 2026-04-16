<?php

namespace App\Service\Ingredient;

use App\DTO\IngredientDTO;
use App\Entity\Ingredient;

class IngredientMapper
{
    public function mapToDTO(Ingredient $ingredient): IngredientDTO
    {
        return new IngredientDTO(
            $ingredient->getId(),
            $ingredient->getNameFr(),
            $ingredient->getNameEn(),
            $ingredient->getFoodStore()->getId()
        );
    }

    public function mapToDTOs(array $ingredients): array
    {
        return array_map([$this, 'mapToDTO'], $ingredients);
    }
}