<?php

namespace App\Service\DishAllergen;

use App\DTO\DishAllergenDTO;
use App\Entity\DishAllergen;

class DishAllergenMapper
{
    public function mapToDTO(DishAllergen $dishAllergen): DishAllergenDTO
    {
        return new DishAllergenDTO(
            $dishAllergen->getId(),
            $dishAllergen->getSpecification(),
            $dishAllergen->getDish()->getId(),
            $dishAllergen->getAllergen()->getId(),
            $dishAllergen->getAllergen()->getNameFr(),
            $dishAllergen->getAllergen()->getNameEn(),
        );
    }

    public function mapToDTOs(array $dishAllergens): array
    {
        return array_map([$this, 'mapToDTO'], $dishAllergens);
    }
}
