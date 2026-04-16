<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Helper\MoneyHelper;
use App\Repository\OrderDishRepository;
use Brick\Math\BigDecimal;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: OrderDishRepository::class)]
class OrderDish extends BaseEntity
{
    #[ORM\ManyToOne(targetEntity: Order::class, inversedBy: 'dishes')]
    #[ORM\JoinColumn(nullable: false)]
    private Order $order;

    #[ORM\OneToOne(targetEntity: CartDish::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private CartDish $cartDish;

    #[ORM\OneToMany(mappedBy: 'orderDish', targetEntity: OrderDishIngredient::class, cascade: ['persist', 'remove'])]
    private Collection $ingredients;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)] 
    private string $unitPrice;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)] 
    private string $baseSubtotalPrice; // unitPrice x quantity

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)] 
    private string $totalPrice; // Total price of the order dish including all ingredients

    #[ORM\Column(type: 'integer')]
    private int $quantity = 1;

    public function __construct(Order $order, CartDish $cartDish, float|string $unitPrice, float|string $baseSubtotalPrice, float|string $totalPrice, int $quantity = 1)
    {
        $this->order = $order;
        $this->cartDish = $cartDish;
        $this->setUnitPrice($unitPrice);
        $this->setBaseSubtotalPrice($baseSubtotalPrice);
        $this->setTotalPrice($totalPrice);
        $this->quantity = max(1, $quantity);
        $this->ingredients = new ArrayCollection();
    }

    public function getOrder(): Order
    {
        return $this->order;
    }

    public function setOrder(Order $order): self
    {
        $this->order = $order;
        return $this;
    }

    public function getCartDish(): CartDish
    {
        return $this->cartDish;
    }

    public function setCartDish(CartDish $cartDish): self
    {
        $this->cartDish = $cartDish;
        return $this;
    }

    public function getIngredients(): Collection
    {
        return $this->ingredients;
    }

    public function addIngredient(OrderDishIngredient $ingredient): self
    {
        if (!$this->ingredients->contains($ingredient)) {
            $this->ingredients[] = $ingredient;
            $ingredient->setOrderDish($this);
        }

        return $this;
    }

    public function removeIngredient(OrderDishIngredient $ingredient): self
    {
        $this->ingredients->removeElement($ingredient);
        return $this;
    }


    public function getUnitPrice(): string
    {
        return $this->unitPrice;
    }

    public function getDecimalUnitPrice(): BigDecimal
    {
        return BigDecimal::of($this->unitPrice);
    }

    public function setUnitPrice(float|string $price): self
    {
        $this->unitPrice = MoneyHelper::normalize((float) abs($price));
        return $this;
    }

    public function getBaseSubtotalPrice(): string
    {
        return $this->baseSubtotalPrice;
    }

    public function getDecimalBaseSubtotalPrice(): BigDecimal
    {
        return BigDecimal::of($this->baseSubtotalPrice);
    }

    public function setBaseSubtotalPrice(float|string $price): self
    {
        $this->baseSubtotalPrice = MoneyHelper::normalize((float) abs($price));
        return $this;
    }


    public function getTotalPrice(): string
    {
        return $this->totalPrice;
    }

    public function getDecimalTotalPrice(): BigDecimal
    {
        return BigDecimal::of($this->totalPrice);
    }


    public function setTotalPrice(float|string $price): self
    {
        $this->totalPrice = MoneyHelper::normalize((float) abs($price));
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
