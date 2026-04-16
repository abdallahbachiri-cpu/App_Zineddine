<?php

namespace App\Service\Payout;

use App\DTO\PayoutConfigDTO;
use App\Entity\PayoutConfiguration;

class PayoutConfigMapper
{
    public function mapToDTO(PayoutConfiguration $config): PayoutConfigDTO
    {
        return new PayoutConfigDTO(
            $config->getCommissionRate(),
            $config->getMinimumPayout(),
            $config->getMaximumPayout(),
            $config->getPayoutCooldownHours(),
        );
    }
}
