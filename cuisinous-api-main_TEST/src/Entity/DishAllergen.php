<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\DishAllergenRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DishAllergenRepository::class)]
#[ORM\Table(name: 'dish_allergens')]
class DishAllergen extends BaseEntity
{
    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $specification = null;

    #[ORM\ManyToOne(targetEntity: Dish::class, inversedBy: 'dishAllergens')]
    private Dish $dish;

    #[ORM\ManyToOne(targetEntity: Allergen::class, inversedBy: 'dishAllergens')]
    private Allergen $allergen;

    public function getSpecification(): ?string
    {
        return $this->specification;
    }

    public function setSpecification(?string $specification): self
    {
        $this->specification = $specification;
        return $this;
    }

    public function getDish(): Dish
    {
        return $this->dish;
    }

    public function setDish(Dish $dish): self
    {
        $this->dish = $dish;
        return $this;
    }

    public function getAllergen(): Allergen
    {
        return $this->allergen;
    }

    public function setAllergen(Allergen $allergen): self
    {
        $this->allergen = $allergen;
        return $this;
    }
}
