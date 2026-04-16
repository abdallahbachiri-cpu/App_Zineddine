<?php

namespace App\Service\Allergen;

use App\DTO\AllergenDTO;
use App\Entity\Allergen;

class AllergenMapper
{
    public function mapToDTO(Allergen $allergen): AllergenDTO
    {
        return new AllergenDTO(
            $allergen->getId(),
            $allergen->getNameFr(),
            $allergen->getNameEn(),
            $allergen->getRequiresSpecification(),
        );
    }

    public function mapToDTOs(array $allergens): array
    {
        return array_map([$this, 'mapToDTO'], $allergens);
    }
}
