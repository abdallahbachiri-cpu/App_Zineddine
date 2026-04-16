<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Helper\MoneyHelper;
use App\Repository\DishIngredientRepository;
use Brick\Math\BigDecimal;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DishIngredientRepository::class)]
class DishIngredient extends BaseEntity
{
    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';
    
    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)] 
    private string $price = '0.00';

    #[ORM\Column(type: 'boolean', options: ['default' => true])]
    private bool $available = true;

    #[ORM\Column(type: 'boolean', options: ['default' => false])]
    private bool $isSupplement = false;

    #[ORM\ManyToOne(targetEntity: Dish::class, inversedBy: 'dishIngredients')]
    private Dish $dish;

    #[ORM\ManyToOne(targetEntity: Ingredient::class, inversedBy: 'dishIngredients')]
    private Ingredient $ingredient;

    public function getPrice(): string
    {
        return $this->price;
    }

    public function getDecimalPrice(): BigDecimal
    {
        return BigDecimal::of($this->price);
    }

    public function setPrice(float|string $price): self
    {
        if (!$this->isSupplement) {
            $this->price = '0.00';
        } else {
            $this->price = MoneyHelper::normalize((float) abs($price));
        }
        return $this;
    }

    public function isAvailable(): bool
    {
        return $this->available;
    }

    public function setAvailable(bool $available): self
    {
        $this->available = $available;
        return $this;
    }

    public function isSupplement(): bool
    {
        return $this->isSupplement;
    }

    public function setIsSupplement(bool $isSupplement): self
    {
        $this->isSupplement = $isSupplement;
        if (!$isSupplement && $this->price !== "0.00") {
            $this->price = "0.00";
        }
        return $this;
    }

    // public function setIsSupplement(bool $isSupplement, float|string|null $price = null): self
    // {
    //     $this->isSupplement = $isSupplement;

    //     if ($isSupplement) {
    //         $this->price = MoneyHelper::normalize((float) abs($price ?? 0.00));
    //     } else {
    //         $this->price = '0.00';
    //     }

    //     return $this;
    // }


    public function getDish(): Dish
    {
        return $this->dish;
    }

    public function setDish(Dish $dish): self
    {
        $this->dish = $dish;
        return $this;
    }

    public function getIngredient(): Ingredient
    {
        return $this->ingredient;
    }

    public function setIngredient(Ingredient $ingredient): self
    {
        $this->ingredient = $ingredient;
        return $this;
    }
}
