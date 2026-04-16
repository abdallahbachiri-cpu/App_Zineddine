<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Helper\MoneyHelper;
use App\Repository\WalletRepository;
use Brick\Math\BigDecimal;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: WalletRepository::class)]
class Wallet extends BaseEntity
{
    public function __construct(FoodStore $foodStore)
    {
        $this->foodStore = $foodStore;
        $this->transactions = new ArrayCollection();
    }

    #[ORM\OneToOne(inversedBy: 'wallet', cascade: ['persist', 'remove'])]
    #[ORM\JoinColumn(nullable: false)]
    private FoodStore $foodStore;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $availableBalance = '0.00';

    // #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    // private string $pendingBalance = '0.00';

    #[ORM\OneToMany(mappedBy: 'wallet', targetEntity: WalletTransaction::class, cascade: ['persist', 'remove'])]
    private Collection $transactions;

    #[ORM\Column(type: 'boolean')]
    private bool $isActive = true;



    public function getFoodStore(): FoodStore
    {
        return $this->foodStore;
    }

    public function setFoodStore(FoodStore $foodStore): static
    {
        $this->foodStore = $foodStore;

        return $this;
    }

    public function getAvailableBalance(): string
    {
        return $this->availableBalance;
    }


    public function getDecimalAvailableBalance(): BigDecimal
    {
        return BigDecimal::of($this->availableBalance);
    }

    public function setAvailableBalance(string $availableBalance): static
    {
        $this->availableBalance = $availableBalance;

        return $this;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }

    public function setCurrency(string $currency): self
    {
        $this->currency = $currency;
        return $this;
    }

    /**
     * @return Collection<int, WalletTransaction>
     */
    public function getTransactions(): Collection
    {
        return $this->transactions;
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): static
    {
        $this->isActive = $isActive;
        return $this;
    }


    /**
     * Deduct amount from wallet balance
     * 
     * @param string|float $amount Amount to deduct (e.g. "12.34")
     * @throws InvalidArgumentException If insufficient balance or invalid amount
     */
    public function deduct(string|float $amount): self
    {
        $amountDecimal = MoneyHelper::decimal($amount);

        if ($amountDecimal->isLessThanOrEqualTo(0)) {
            throw new \InvalidArgumentException('Deduct amount must be positive');
        }

        $currentBalance = MoneyHelper::decimal($this->availableBalance);

        if ($currentBalance->isLessThan($amountDecimal)) {
            throw new \InvalidArgumentException('Insufficient wallet balance');
        }

        // Subtract and update balance
        $this->availableBalance = MoneyHelper::subtract($this->availableBalance, $amount);

        return $this;
    }

    /**
     * Add amount to wallet balance
     * 
     * @param string|float $amount Amount to add (e.g. "12.34")
     * @throws InvalidArgumentException If amount is invalid (zero or negative)
     */
    public function add(string|float $amount): self
    {
        $amountDecimal = MoneyHelper::decimal($amount);

        if ($amountDecimal->isLessThanOrEqualTo(0)) {
            throw new \InvalidArgumentException('Add amount must be positive');
        }

        // Add and update balance
        $this->availableBalance = MoneyHelper::add($this->availableBalance, $amount);

        return $this;
    }


    /**
     * Check if wallet has sufficient balance
     */
    public function hasSufficientBalance(string|float $amount): bool
    {
        $requiredAmount = MoneyHelper::decimal($amount);
        $currentBalance = MoneyHelper::decimal($this->availableBalance);

        return $currentBalance->isGreaterThanOrEqualTo($requiredAmount);
    }

    // public function getPendingBalance(): string
    // {
    //     return $this->pendingBalance;
    // }

    // public function setPendingBalance(string $pendingBalance): static
    // {
    //     $this->pendingBalance = $pendingBalance;

    //     return $this;
    // }

}
