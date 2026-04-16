<?php

namespace App\DTO;

use JsonSerializable;

class PayoutConfigDTO implements JsonSerializable
{
    public readonly string $commissionRate;
    public readonly string $minimumPayout;
    public readonly string $maximumPayout;
    public readonly int $payoutCooldownHours;

    public function __construct(
        string $commissionRate,
        string $minimumPayout,
        string $maximumPayout,
        int $payoutCooldownHours,
    ) {
        $this->commissionRate = $commissionRate;
        $this->minimumPayout = $minimumPayout;
        $this->maximumPayout = $maximumPayout;
        $this->payoutCooldownHours = $payoutCooldownHours;
    }

    public function jsonSerialize(): array
    {
        return [
            'commissionRate' => $this->commissionRate,
            'minimumPayout' => $this->minimumPayout,
            'maximumPayout' => $this->maximumPayout,
            'payoutCooldownHours' => $this->payoutCooldownHours,
        ];
    }
}
