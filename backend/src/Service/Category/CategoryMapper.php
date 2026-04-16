<?php

namespace App\Service\Category;

use App\DTO\CategoryDTO;
use App\Entity\Category;

class CategoryMapper
{
    public function mapToDTO(Category $category): CategoryDTO
    {
        return new CategoryDTO(
            $category->getId(),
            $category->getType(),
            $category->getNameFr(),
            $category->getNameEn(),
        );
    }

    public function mapToDTOs(array $categories): array
    {
        return array_map([$this, 'mapToDTO'], $categories);
    }

}