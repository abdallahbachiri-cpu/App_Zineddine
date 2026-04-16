<?php
namespace App\Service\Wallet\WalletTransaction;

use App\DTO\WalletDTO;
use App\DTO\WalletTransactionDTO;
use App\Entity\Wallet;
use App\Entity\WalletTransaction;

class WalletTransactionMapper
{
    public function mapToDTO(WalletTransaction $transaction): WalletTransactionDTO
    {
        return new WalletTransactionDTO(
            id: $transaction->getId(),
            walletId: $transaction->getWallet()->getId(),
            currency: $transaction->getCurrency(),
            amount: $transaction->getAmount(),
            grossAmount: $transaction->getGrossAmount(),
            commissionAmount: $transaction->getCommissionAmount(),
            commissionRate: $transaction->getCommissionRate(),
            type: $transaction->getType()->value,
            status: $transaction->getStatus()->value,
            availableAt: $transaction->getAvailableAt(),
            note: $transaction->getNote(),
            createdAt: $transaction->getCreatedAt()
        );
    }

    public function mapToDTOs(array $transactions): array
    {
        return array_map(
            fn(WalletTransaction $transaction) => $this->mapToDTO($transaction),
            $transactions
        );
    }
}