<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Helper\MoneyHelper;
use App\Repository\DishRepository;
use Brick\Math\BigDecimal;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DishRepository::class)]
class Dish extends BaseEntity
{
    public const SEARCHABLE_FIELDS = ['name', 'description'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'name', 'price', 'cachedAverageRating'];

    #[ORM\Column(type: 'string', length: 255)]
    private string $name;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $description = null;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $price; //base price

    #[ORM\Column(type: 'boolean', options: ['default' => true])]
    private bool $available = true;

    #[ORM\ManyToOne(targetEntity: FoodStore::class, inversedBy: 'dishes')]
    #[ORM\JoinColumn(nullable: false)]
    private FoodStore $foodStore;

    #[ORM\OneToMany(mappedBy: 'dish', targetEntity: DishIngredient::class, cascade: ['persist', 'remove'])]
    private Collection $dishIngredients;

    #[ORM\ManyToMany(targetEntity: Media::class, cascade: ['persist'])]
    #[ORM\JoinTable(name: 'dish_media')]
    private Collection $gallery;

    #[ORM\ManyToMany(targetEntity: Category::class, inversedBy: 'dishes')]
    #[ORM\JoinTable(name: 'dish_categories')]
    private Collection $categories;

    #[ORM\OneToMany(mappedBy: 'dish', targetEntity: DishAllergen::class, cascade: ['persist', 'remove'])]
    private Collection $dishAllergens;

    #[ORM\OneToMany(mappedBy: 'dish', targetEntity: DishRating::class, cascade: ['remove'])]
    private Collection $ratings;

    #[ORM\Column(type: 'float', precision: 2, options: ['default' => 0])]
    private float $cachedAverageRating = 0;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $deletedAt = null;

    public function __construct()
    {
        $this->dishIngredients = new ArrayCollection();
        $this->dishAllergens = new ArrayCollection();
        $this->gallery = new ArrayCollection();
        $this->categories = new ArrayCollection();
        $this->ratings = new ArrayCollection();
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): self
    {
        $this->name = $name;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): self
    {
        $this->description = $description;

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

    public function getBasePrice(): string
    {
        return $this->price;
    }

    public function getDecimalBasePrice(): BigDecimal
    {
        return BigDecimal::of($this->price);
    }

    public function setBasePrice(float|string $price): self
    {
        $this->price = MoneyHelper::normalize((float) abs($price));
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

    public function getDishIngredients(): Collection
    {
        return $this->dishIngredients;
    }

    public function addDishIngredient(DishIngredient $dishIngredient): self
    {
        if (!$this->dishIngredients->contains($dishIngredient)) {
            $this->dishIngredients->add($dishIngredient);
            $dishIngredient->setDish($this);
        }
        return $this;
    }

    public function getGallery(): Collection
    {
        return $this->gallery;
    }

    public function addMedia(Media $media): self
    {
        if (!$this->gallery->contains($media)) {
            $this->gallery->add($media);
        }
        return $this;
    }

    public function removeMedia(Media $media): self
    {
        $this->gallery->removeElement($media);
        return $this;
    }

    /**
     * @return Collection<int, Category>
     */
    public function getCategories(): Collection
    {
        return $this->categories;
    }

    public function addCategory(Category $category): self
    {
        if (!$this->categories->contains($category)) {
            $this->categories->add($category);
            $category->addDish($this);
        }

        return $this;
    }

    public function removeCategory(Category $category): self
    {
        if ($this->categories->removeElement($category)) {
            $category->removeDish($this);
        }

        return $this;
    }

    public function getDishAllergens(): Collection
    {
        return $this->dishAllergens;
    }

    public function addDishAllergen(DishAllergen $dishAllergen): self
    {
        if (!$this->dishAllergens->contains($dishAllergen)) {
            $this->dishAllergens->add($dishAllergen);
            $dishAllergen->setDish($this);
        }
        return $this;
    }

    public function removeDishAllergen(DishAllergen $dishAllergen): self
    {
        $this->dishAllergens->removeElement($dishAllergen);
        return $this;
    }

    public function getRatings(): Collection
    {
        return $this->ratings;
    }

    public function getCachedAverageRating(): float
    {
        return $this->cachedAverageRating;
    }

    public function setCachedAverageRating(float $cachedAverageRating): self
    {
        $this->cachedAverageRating = $cachedAverageRating;
        return $this;
    }

    public function getDeletedAt(): ?\DateTimeImmutable
    {
        return $this->deletedAt;
    }

    public function softDelete(): self
    {
        $this->deletedAt = new \DateTimeImmutable();
        return $this;
    }

    public function isDeleted(): bool
    {
        return $this->deletedAt !== null;
    }
}
