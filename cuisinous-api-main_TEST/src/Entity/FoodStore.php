<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Entity\Enum\StoreDeliveryOption;
use App\Entity\Enum\StoreType;
use App\Repository\FoodStoreRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\ORM\Mapping as ORM;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: FoodStoreRepository::class)]
class FoodStore extends BaseEntity
{

    public const SEARCHABLE_FIELDS = ['name', 'description'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'name'];
    public const FILTERABLE_FIELDS = ['country', 'city', 'state', 'zipCode'];

    #[ORM\OneToOne(targetEntity: User::class, inversedBy: 'foodStore')]
    #[ORM\JoinColumn(name: 'seller_id', referencedColumnName: 'id', nullable: false, onDelete: 'CASCADE')]
    private $seller;

    #[ORM\Column(type: 'string', length: 255, unique: true)]
    private string $name;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $description = null;

    #[ORM\ManyToOne(targetEntity: Media::class, cascade: ['persist'])]
    #[ORM\JoinColumn(nullable: true, onDelete: 'SET NULL')]
    private ?Media $profileImage = null;
    //instead of oneToOne because in the future we can have multiple stores of same seller that share the same picture

    #[ORM\OneToMany(mappedBy: 'foodStore', targetEntity: Dish::class)]
    private Collection $dishes;

    #[ORM\OneToOne(targetEntity: Location::class, inversedBy: 'foodStore', cascade: ['persist', 'remove'])]
    #[ORM\JoinColumn(nullable: true, onDelete: 'SET NULL')]
    private ?Location $location = null;

    #[ORM\OneToOne(mappedBy: 'foodStore', cascade: ['persist', 'remove'])]
    private ?Wallet $wallet = null;

    #[ORM\OneToOne(mappedBy: 'foodStore', targetEntity: BankAccount::class, cascade: ['persist', 'remove'])]
    private ?BankAccount $bankAccount = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeAccountId = null;

    #[ORM\Column(type: 'boolean')]
    private bool $isActive = false;

    #[ORM\Column(enumType: StoreType::class, options: ["default" => "home"])]
    private StoreType $type = StoreType::Home;

    #[ORM\Column(enumType: StoreDeliveryOption::class, options: ["default" => "pickup_only"])]
    private StoreDeliveryOption $deliveryOption = StoreDeliveryOption::PickupOnly;

    #[ORM\OneToMany(mappedBy: 'foodStore', targetEntity: Ingredient::class)]
    private Collection $ingredients;

    #[ORM\OneToMany(mappedBy: 'foodStore', targetEntity: FoodStoreVerificationRequest::class)]
    private Collection $verificationRequests;

    #[ORM\Column(type: 'boolean', options: ['default' => false])]
    private bool $vendorAgreementAccepted = false;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $vendorAgreementAcceptedAt = null;


    public function __construct()
    {
        $this->dishes = new ArrayCollection();
        $this->ingredients = new ArrayCollection();
        $this->verificationRequests = new ArrayCollection();
    }

    public function getSeller(): User
    {
        return $this->seller;
    }

    public function setSeller(User $seller): self
    {
        $this->seller = $seller;

        return $this;
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

    // public function getAddress(): ?Location
    // {
    //     return $this->seller->getDefaultAddress();
    // }

    public function getProfileImage(): ?Media
    {
        return $this->profileImage;
    }

    public function setProfileImage(?Media $profileImage): self
    {
        $this->profileImage = $profileImage;
        return $this;
    }

    public function addDish(Dish $dish): self
    {
        if (!$this->dishes->contains($dish)) {
            $this->dishes[] = $dish;
            $dish->setFoodStore($this);
        }
        return $this;
    }

    public function removeDish(Dish $dish): self
    {
        $this->dishes->removeElement($dish);
        return $this;
    }

    public function getDishes(): Collection
    {
        return $this->dishes;
    }

    public function getLocation(): ?Location
    {
        return $this->location;
    }

    public function setLocation(?Location $location): self
    {
        $this->location = $location;
        return $this;
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function setActive(bool $isActive): self
    {
        $this->isActive = $isActive;

        return $this;
    }

    public function suspend(): self
    {
        $this->isActive = false;

        return $this;
    }

    public function activate(): self
    {
        $this->isActive = true;

        return $this;
    }

    public function getType(): StoreType
    {
        return $this->type;
    }

    public function setType(StoreType $type): self
    {
        $this->type = $type;

        return $this;
    }

    public function getWallet(): ?Wallet
    {
        return $this->wallet;
    }

    public function setWallet(Wallet $wallet): static
    {
        if ($wallet->getFoodStore() !== $this) {
            $wallet->setFoodStore($this);
        }

        $this->wallet = $wallet;

        return $this;
    }

    public function getDeliveryOption(): StoreDeliveryOption
    {
        return $this->deliveryOption;
    }

    public function setDeliveryOption(StoreDeliveryOption $deliveryOption): self
    {
        $this->deliveryOption = $deliveryOption;
        return $this;
    }

    // public function getBankAccount(): ?BankAccount
    // {
    //     return $this->bankAccount;
    // }

    // public function setBankAccount(BankAccount $bankAccount): static
    // {
    //     if ($bankAccount->getFoodStore() !== $this) {
    //         $bankAccount->setFoodStore($this);
    //     }

    //     $this->bankAccount = $bankAccount;

    //     return $this;
    // }

    public function getStripeAccountId(): ?string
    {
        return $this->stripeAccountId;
    }

    public function setStripeAccountId(?string $stripeAccountId): self
    {
        $this->stripeAccountId = $stripeAccountId;
        return $this;
    }

    public function getIngredients(): Collection
    {
        return $this->ingredients;
    }

    public function addIngredient(Ingredient $ingredient): self
    {
        if (!$this->ingredients->contains($ingredient)) {
            $this->ingredients[] = $ingredient;
            $ingredient->setFoodStore($this);
        }

        return $this;
    }

    public function isVendorAgreementAccepted(): bool
    {
        return $this->vendorAgreementAccepted;
    }

    public function setVendorAgreementAccepted(bool $vendorAgreementAccepted): self
    {
        $this->vendorAgreementAccepted = $vendorAgreementAccepted;

        return $this;
    }


    public function getVendorAgreementAcceptedAt(): ?\DateTimeImmutable
    {
        return $this->vendorAgreementAcceptedAt;
    }

    public function setVendorAgreementAcceptedAt(?\DateTimeImmutable $vendorAgreementAcceptedAt): self
    {
        $this->vendorAgreementAcceptedAt = $vendorAgreementAcceptedAt;

        return $this;
    }
}
