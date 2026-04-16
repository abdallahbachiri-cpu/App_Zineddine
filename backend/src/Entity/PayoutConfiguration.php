<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\PayoutConfigurationRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: PayoutConfigurationRepository::class)]
class PayoutConfiguration extends BaseEntity
{
    #[ORM\Column(type: 'decimal', precision: 5, scale: 2)]
    private string $commissionRate = '0.20';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $minimumPayout = '5.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $maximumPayout = '500.00';

    #[ORM\Column(type: 'integer')]
    private int $payoutCooldownHours = 24;

    public function getCommissionRate(): string
    {
        return $this->commissionRate;
    }

    public function getMinimumPayout(): string
    {
        return $this->minimumPayout;
    }

    public function getMaximumPayout(): string
    {
        return $this->maximumPayout;
    }

    public function getPayoutCooldownHours(): int
    {
        return $this->payoutCooldownHours;
    }

    public function setCommissionRate(string $commissionRate): self
    {
        $this->commissionRate = $commissionRate;
        return $this;
    }

    public function setMinimumPayout(string $minimumPayout): self
    {
        $this->minimumPayout = $minimumPayout;
        return $this;
    }

    public function setMaximumPayout(string $maximumPayout): self
    {
        $this->maximumPayout = $maximumPayout;
        return $this;
    }

    public function setPayoutCooldownHours(int $payoutCooldownHours): self
    {
        $this->payoutCooldownHours = $payoutCooldownHours;
        return $this;
    }
}
