<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\CategoryRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CategoryRepository::class)]
#[ORM\Table(name: 'categories')]
class Category extends BaseEntity
{
    public const SEARCHABLE_FIELDS = ['nameFr', 'nameEn'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'nameFr', 'nameEn', 'type'];
    public const ALLOWED_TYPES = ['cuisine', 'region', 'dietary', 'feature', 'mealType', 'allergenSafety'];
    // @TODO create CategoryType to make it dynamic
    #[ORM\Column(type: 'string', length: 50)]
    private string $type;

    #[ORM\Column(type: 'string', length: 100)]
    private string $nameFr;

    #[ORM\Column(type: 'string', length: 100)]
    private string $nameEn;

    #[ORM\ManyToMany(targetEntity: Dish::class, mappedBy: 'categories')]
    private Collection $dishes;

    public function __construct()
    {
        $this->dishes = new ArrayCollection();
    }

    public function getType(): string
    {
        return $this->type;
    }

    public function setType(string $type): self
    {
        $this->type = $type;
        return $this;
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

    /**
     * @return Collection|Dish[]
     */
    public function getDishes(): Collection
    {
        return $this->dishes;
    }

    public function addDish(Dish $dish): self
    {
        if (!$this->dishes->contains($dish)) {
            $this->dishes[] = $dish;
            $dish->addCategory($this);
        }
        return $this;
    }

    public function removeDish(Dish $dish): self
    {
        if ($this->dishes->removeElement($dish)) {
            $dish->removeCategory($this);
        }
        return $this;
    }

    public function __toString(): string
    {
        return $this->nameEn;
    }
}