<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\BankAccountRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: BankAccountRepository::class)]
class BankAccount extends BaseEntity
{
    #[ORM\OneToOne(inversedBy: 'bankAccount', targetEntity: FoodStore::class)]
    #[ORM\JoinColumn(nullable: false)]
    private FoodStore $foodStore;

    public function __construct(FoodStore $foodStore)
    {
        $this->foodStore = $foodStore;
    }

    #[ORM\Column(length: 3, options: ['default' => 'CAD'])]
    #[Assert\Currency]
    private string $currency = 'CAD';

    #[ORM\Column(length: 100)]
    #[Assert\NotBlank]
    #[Assert\Length(max: 100)]
    private string $accountHolderName;

    #[ORM\Column(length: 5)]
    #[Assert\NotBlank]
    #[Assert\Length(exactly: 5)]
    #[Assert\Regex(pattern: '/^\d{5}$/')]
    private string $transitNumber;

    #[ORM\Column(length: 3)]
    #[Assert\NotBlank]
    #[Assert\Length(exactly: 3)]
    #[Assert\Regex(pattern: '/^\d{3}$/')]
    private string $institutionNumber;

    #[ORM\Column(length: 12)]
    #[Assert\NotBlank]
    #[Assert\Length(min: 7, max: 12)]
    #[Assert\Regex(pattern: '/^\d{7,12}$/')]
    private string $accountNumber;

    #[ORM\Column(length: 50, nullable: true)]
    private ?string $stripeBankToken = null;

    #[ORM\Column(length: 4, nullable: true)]
    private ?string $lastFourDigits = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $verifiedAt = null;

    #[ORM\Column(type: 'boolean', options: ['default' => false])]
    private bool $isDefault = false;

    public function getFoodStore(): FoodStore
    {
        return $this->foodStore;
    }

    public function setFoodStore(FoodStore $foodStore): self
    {
        $this->foodStore = $foodStore;
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

    public function getAccountHolderName(): string
    {
        return $this->accountHolderName;
    }

    public function setAccountHolderName(string $accountHolderName): self
    {
        $this->accountHolderName = $accountHolderName;
        return $this;
    }

    public function getTransitNumber(): string
    {
        return $this->transitNumber;
    }

    public function setTransitNumber(string $transitNumber): self
    {
        $this->transitNumber = preg_replace('/[^0-9]/', '', $transitNumber);
        return $this;
    }

    public function getInstitutionNumber(): string
    {
        return $this->institutionNumber;
    }

    public function setInstitutionNumber(string $institutionNumber): self
    {
        $this->institutionNumber = preg_replace('/[^0-9]/', '', $institutionNumber);
        return $this;
    }

    public function getAccountNumber(): string
    {
        return $this->accountNumber;
    }

    public function setAccountNumber(string $accountNumber): self
    {
        $this->accountNumber = preg_replace('/[^0-9]/', '', $accountNumber);
        return $this;
    }

    public function getStripeBankToken(): ?string
    {
        return $this->stripeBankToken;
    }

    public function setStripeBankToken(?string $stripeBankToken): self
    {
        $this->stripeBankToken = $stripeBankToken;
        return $this;
    }

    public function getLastFourDigits(): ?string
    {
        return $this->lastFourDigits;
    }

    public function setLastFourDigits(?string $lastFourDigits): self
    {
        $this->lastFourDigits = $lastFourDigits;
        return $this;
    }

    public function getVerifiedAt(): ?\DateTimeImmutable
    {
        return $this->verifiedAt;
    }

    public function setVerifiedAt(?\DateTimeImmutable $verifiedAt): self
    {
        $this->verifiedAt = $verifiedAt;
        return $this;
    }

    public function markAsVerified(): void
    {
        $this->verifiedAt = new \DateTimeImmutable();
    }

    public function isVerified(): bool
    {
        return $this->verifiedAt !== null;
    }

    public function isDefault(): bool
    {
        return $this->isDefault;
    }

    public function setIsDefault(bool $isDefault): self
    {
        $this->isDefault = $isDefault;
        return $this;
    }

    public function getFormattedTransit(): string
    {
        return substr($this->transitNumber, 0, 3) . '-' . substr($this->transitNumber, 3, 2);
    }

    public function getRoutingNumber(): string
    {
        return $this->transitNumber . $this->institutionNumber;
    }

    public function getMaskedAccountNumber(): string
    {
        return '••••' . $this->lastFourDigits;
    }
}
