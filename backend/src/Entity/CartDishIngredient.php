<?php

namespace App\Entity;
use App\Entity\Abstract\BaseEntity;
use App\Repository\CartDishIngredientRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CartDishIngredientRepository::class)]
class CartDishIngredient extends BaseEntity
{
    public function __construct(CartDish $cartDish, DishIngredient $dishIngredient, int $quantity = 1)
    {
        $this->cartDish = $cartDish;
        $this->dishIngredient = $dishIngredient;
        $this->quantity = max(1, $quantity);
        $cartDish->addIngredient($this);
    }

    #[ORM\ManyToOne(targetEntity: CartDish::class, inversedBy: 'ingredients')]
    #[ORM\JoinColumn(nullable: false, onDelete: "CASCADE")]
    private CartDish $cartDish;

    #[ORM\ManyToOne(targetEntity: DishIngredient::class)]
    #[ORM\JoinColumn(nullable: false)]
    private DishIngredient $dishIngredient;

    #[ORM\Column(type: 'integer')]
    private int $quantity = 1;

    public function getCartDish(): CartDish
    {
        return $this->cartDish;
    }

    // public function setCartDish(CartDish $cartDish): self
    // {
    //     $this->cartDish = $cartDish;
    //     return $this;
    // }

    public function getDishIngredient(): DishIngredient
    {
        return $this->dishIngredient;
    }

    // public function setDishIngredient(DishIngredient $dishIngredient): self
    // {
    //     $this->dishIngredient = $dishIngredient;
    //     return $this;
    // }

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): self
    {
        $this->quantity = max(1, $quantity);
        return $this;
    }
}
