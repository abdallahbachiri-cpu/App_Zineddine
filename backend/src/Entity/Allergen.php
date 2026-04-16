<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\AllergenRepository;
use Doctrine\ORM\Mapping as ORM;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: AllergenRepository::class)]
#[ORM\Table(name: 'allergens')]
class Allergen extends BaseEntity
{
    public const SEARCHABLE_FIELDS = ['nameFr', 'nameEn'];

    #[ORM\Column(type: 'string', length: 100)]
    private string $nameFr;

    #[ORM\Column(type: 'string', length: 100)]
    private string $nameEn;

    #[ORM\Column(type: 'boolean', options: ['default' => false])]
    private bool $requiresSpecification = false;

    #[ORM\OneToMany(mappedBy: 'allergen', targetEntity: DishAllergen::class, cascade: ['persist', 'remove'])]
    private Collection $dishAllergens;

    public function __construct()
    {
        $this->dishAllergens = new ArrayCollection();
    }

    public function getNameFr(): string
    {
        return $this->nameFr;
    }

    public function setNameFr(string $nameFr): self
    {
        $this->nameFr = $nameFr;
        return $this;
    }

    public function getNameEn(): string
    {
        return $this->nameEn;
    }

    public function setNameEn(string $nameEn): self
    {
        $this->nameEn = $nameEn;
        return $this;
    }

    public function getName(string $locale): string
    {
        return $locale === 'fr' ? $this->nameFr : $this->nameEn;
    }

    public function setRequiresSpecification(bool $requiresSpecification): self
    {
        $this->requiresSpecification = $requiresSpecification;
        return $this;
    }

    public function getRequiresSpecification(): bool
    {
        return $this->requiresSpecification;
    }

    public function getDishAllergens(): Collection
    {
        return $this->dishAllergens;
    }


    public function __toString(): string
    {
        return $this->nameEn;
    }
}
