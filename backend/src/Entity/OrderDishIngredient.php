<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Helper\MoneyHelper;
use App\Repository\OrderDishIngredientRepository;
use Brick\Math\BigDecimal;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: OrderDishIngredientRepository::class)]
class OrderDishIngredient extends BaseEntity
{
    #[ORM\ManyToOne(targetEntity: OrderDish::class, inversedBy: 'ingredients')]
    #[ORM\JoinColumn(nullable: false)]
    private OrderDish $orderDish;

    #[ORM\OneToOne(targetEntity: CartDishIngredient::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private CartDishIngredient $cartDishIngredient;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';
    
    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)] 
    private string $price;

    #[ORM\Column(type: 'integer')]
    private int $quantity = 1;

    public function __construct(OrderDish $orderDish, CartDishIngredient $cartDishIngredient, float|string $price, int $quantity = 1)
    {
        $this->orderDish = $orderDish;
        $this->cartDishIngredient = $cartDishIngredient;
        $this->setPrice($price);
        $this->quantity = max(1, $quantity);
    }

    public function getOrderDish(): OrderDish
    {
        return $this->orderDish;
    }

    public function setOrderDish(OrderDish $orderDish): self
    {
        $this->orderDish = $orderDish;
        return $this;
    }

    public function getCartDishIngredient(): CartDishIngredient
    {
        return $this->cartDishIngredient;
    }

    public function setCartDishIngredient(CartDishIngredient $cartDishIngredient): self
    {
        $this->cartDishIngredient = $cartDishIngredient;
        return $this;
    }

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
        $this->price = MoneyHelper::normalize((float) abs($price));
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

}
