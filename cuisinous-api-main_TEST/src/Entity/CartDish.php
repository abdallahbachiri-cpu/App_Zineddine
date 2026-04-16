<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\CartDishRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CartDishRepository::class)]
class CartDish extends BaseEntity
{
    public function __construct(Cart $cart, Dish $dish, int $quantity = 1)
    {
        $this->cart = $cart;
        $this->dish = $dish;
        $this->quantity = max(1, $quantity);
        $this->ingredients = new ArrayCollection();
    }
    
    #[ORM\ManyToOne(targetEntity: Cart::class, inversedBy: 'dishes')]
    #[ORM\JoinColumn(nullable: false, onDelete: "CASCADE")]
    private Cart $cart;

    #[ORM\ManyToOne(targetEntity: Dish::class)]
    #[ORM\JoinColumn(nullable: false)]
    private Dish $dish;

    #[ORM\Column(type: 'integer')]
    private int $quantity = 1;

    #[ORM\OneToMany(mappedBy: 'cartDish', targetEntity: CartDishIngredient::class, cascade: ['persist', 'remove'])]
    private Collection $ingredients;

    public function getCart(): Cart
    {
        return $this->cart;
    }

    public function setCart(Cart $cart): self
    {
        $this->cart = $cart;
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

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): self
    {
        $this->quantity = max(1, $quantity);
        return $this;
    }

    public function getIngredients(): Collection
    {
        return $this->ingredients;
    }

    public function addIngredient(CartDishIngredient $ingredient): self
    {
        if (!$this->ingredients->contains($ingredient)) {
            $this->ingredients[] = $ingredient;
        }

        return $this;
    }

    public function removeIngredient(CartDishIngredient $ingredient): self
    {
        $this->ingredients->removeElement($ingredient);
        return $this;
    }
    
}
