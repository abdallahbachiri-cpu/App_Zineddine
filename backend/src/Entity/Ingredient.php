<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\IngredientRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;


#[ORM\Entity(repositoryClass: IngredientRepository::class)]
class Ingredient extends BaseEntity
{
    public const SEARCHABLE_FIELDS = ['nameFr', 'nameEn'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'nameFr', 'nameEn'];

    #[ORM\Column(type: 'string', length: 255)]
    private string $nameFr;

    #[ORM\Column(type: 'string', length: 255)]
    private string $nameEn;

    #[ORM\ManyToOne(targetEntity: FoodStore::class, inversedBy: 'ingredients')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private FoodStore $foodStore;

    #[ORM\OneToMany(mappedBy: 'ingredient', targetEntity: DishIngredient::class, cascade: ['persist', 'remove'])]
    private Collection $dishIngredients;

    public function __construct()
    {
        $this->dishIngredients = new ArrayCollection();
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

    public function getFoodStore(): FoodStore
    {
        return $this->foodStore;
    }

    public function setFoodStore(FoodStore $foodStore): self
    {
        $this->foodStore = $foodStore;
        return $this;
    }

    public function getDishIngredients(): Collection
    {
        return $this->dishIngredients;
    }
}
