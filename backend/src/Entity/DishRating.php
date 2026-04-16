<?php

namespace App\Entity;

use App\Repository\DishRatingRepository;
use App\Entity\Abstract\BaseEntity;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: DishRatingRepository::class)]
class DishRating extends BaseEntity
{
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'rating'];
    public const SEARCHABLE_FIELDS = ['comment'];
    
    #[ORM\ManyToOne(targetEntity: Dish::class, inversedBy: 'ratings')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private Dish $dish;

    #[ORM\ManyToOne(targetEntity: User::class, inversedBy: 'dishRatings')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private User $buyer;

    #[ORM\ManyToOne(targetEntity: Order::class, inversedBy: 'dishRatings')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private Order $order;

    #[ORM\Column(type: 'smallint')]
    #[Assert\Range(
        min: 1,
        max: 5,
        notInRangeMessage: 'Rating must be between {{ min }} and {{ max }} stars.'
    )]
    private int $rating;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Assert\Length(
        max: 1000,
        maxMessage: 'Review cannot be longer than {{ limit }} characters.'
    )]
    private ?string $comment = null;


    public function __construct(Dish $dish, User $buyer, Order $order, int $rating, ?string $comment = null)
    {
        $this->dish = $dish;
        $this->buyer = $buyer;
        $this->order = $order;
        $this->setRating($rating);
        $this->comment = $comment;
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

    public function getBuyer(): User
    {
        return $this->buyer;
    }

    public function setBuyer(User $buyer): self
    {
        $this->buyer = $buyer;
        return $this;
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

    public function getRating(): int
    {
        return $this->rating;
    }

    public function setRating(int $rating): self
    {
        if ($rating < 1 || $rating > 5) {
            throw new \InvalidArgumentException('Rating must be between 1 and 5 stars');
        }

        $this->rating = $rating;
        return $this;
    }

    public function getComment(): ?string
    {
        return $this->comment;
    }

    public function setComment(?string $comment): self
    {
        $this->comment = $comment;
        return $this;
    }
}
