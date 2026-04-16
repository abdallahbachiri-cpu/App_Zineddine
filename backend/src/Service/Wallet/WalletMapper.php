<?php

namespace App\Service\Wallet;

use App\DTO\WalletDTO;
use App\Entity\Wallet;


class WalletMapper
{
    public function mapToDTO(Wallet $wallet): WalletDTO
    {
        return new WalletDTO(
            id: $wallet->getId(),
            foodStoreId: $wallet->getFoodStore()->getId(),
            currency: $wallet->getCurrency(),
            availableBalance: $wallet->getAvailableBalance(),
            isActive: $wallet->isActive(),
            createdAt: $wallet->getCreatedAt(),
            updatedAt: $wallet->getUpdatedAt()
        );
    }

    public function mapToDTOs(array $wallets): array
    {
        return array_map([$this, 'mapToDTO'], $wallets);
    }
}
