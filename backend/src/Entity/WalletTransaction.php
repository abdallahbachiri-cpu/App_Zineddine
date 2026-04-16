<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Entity\Enum\Wallet\WalletTransactionStatus;
use App\Entity\Enum\Wallet\WalletTransactionType;
use App\Repository\WalletTransactionRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: WalletTransactionRepository::class)]
class WalletTransaction extends BaseEntity
{
    #[ORM\ManyToOne(inversedBy: 'transactions')]
    #[ORM\JoinColumn(nullable: false)]
    private Wallet $wallet;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $amount; // net amount

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    private ?string $grossAmount = null; // gross amount before commissions (net + commissions) on income transactions

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    private ?string $commissionAmount = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    private ?string $commissionRate = null;

    #[ORM\Column(type: 'string', enumType: WalletTransactionType::class)]
    private WalletTransactionType $type;

    #[ORM\Column(type: 'string', enumType: WalletTransactionStatus::class)]
    private WalletTransactionStatus $status = WalletTransactionStatus::PENDING;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $stripePayoutId = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $availableAt = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $note = null;

    #[ORM\ManyToOne(targetEntity: Order::class)]
    #[ORM\JoinColumn(nullable: true, onDelete: 'SET NULL')]
    private ?Order $order = null;

    public function getWallet(): Wallet
    {
        return $this->wallet;
    }

    public function setWallet(Wallet $wallet): static
    {
        $this->wallet = $wallet;

        return $this;
    }

    public function getAmount(): string
    {
        return $this->amount;
    }

    public function setAmount(string $amount): static
    {
        $this->amount = $amount;

        return $this;
    }

    public function getType(): WalletTransactionType
    {
        return $this->type;
    }

    public function setType(WalletTransactionType $type): static
    {
        $this->type = $type;

        return $this;
    }

    public function getStatus(): WalletTransactionStatus
    {
        return $this->status;
    }

    public function setStatus(WalletTransactionStatus $status): static
    {
        $this->status = $status;

        return $this;
    }

    public function getAvailableAt(): ?\DateTimeImmutable
    {
        return $this->availableAt;
    }

    public function setAvailableAt(?\DateTimeImmutable $availableAt): static
    {
        $this->availableAt = $availableAt;

        return $this;
    }

    public function getNote(): ?string
    {
        return $this->note;
    }

    public function setNote(?string $note): static
    {
        $this->note = $note;

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

    public function getStripePayoutId(): ?string
    {
        return $this->stripePayoutId;
    }
    public function setStripePayoutId(?string $stripePayoutId): static
    {
        $this->stripePayoutId = $stripePayoutId;

        return $this;
    }

    public function getOrder(): ?Order
    {
        return $this->order;
    }

    public function setOrder(?Order $order): static
    {
        $this->order = $order;
        return $this;
    }

    public function getGrossAmount(): ?string
    {
        return $this->grossAmount;
    }

    public function setGrossAmount(?string $grossAmount): static
    {
        $this->grossAmount = $grossAmount;
        return $this;
    }

    public function getCommissionAmount(): ?string
    {
        return $this->commissionAmount;
    }

    public function setCommissionAmount(?string $commissionAmount): static
    {
        $this->commissionAmount = $commissionAmount;
        return $this;
    }

    public function getCommissionRate(): ?string
    {
        return $this->commissionRate;
    }

    public function setCommissionRate(?string $commissionRate): static
    {
        $this->commissionRate = $commissionRate;
        return $this;
    }
}
