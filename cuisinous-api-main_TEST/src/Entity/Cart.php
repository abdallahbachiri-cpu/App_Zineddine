<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\CartRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CartRepository::class)]
class Cart extends BaseEntity
{
    public function __construct(User $buyer)
    {
        $this->buyer = $buyer;
        $this->dishes = new ArrayCollection();
    }

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: "CASCADE")]
    private User $buyer;

    #[ORM\Column(type: 'boolean', options: ['default' => false])]
    private bool $archived = false;

    #[ORM\OneToMany(mappedBy: 'cart', targetEntity: CartDish::class, cascade: ['persist', 'remove'])]
    private Collection $dishes;

    public function getBuyer(): User
    {
        return $this->buyer;
    }

    public function isArchived(): bool
    {
        return $this->archived;
    }

    public function setArchived(bool $archived): self
    {
        $this->archived = $archived;
        return $this;
    }

    public function getDishes(): Collection
    {
        return $this->dishes;
    }

    public function addDish(CartDish $dish): self
    {
        if (!$this->dishes->contains($dish)) {
            $this->dishes[] = $dish;
            $dish->setCart($this);
        }
        return $this;
    }

    public function removeDish(CartDish $dish): self
    {
        $this->dishes->removeElement($dish);
        return $this;
    }
}
