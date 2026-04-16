<?php
namespace App\Service\BankAccount;

use App\DTO\BankAccountDTO;
use App\Entity\BankAccount;

class BankAccountMapper
{
    public function mapToDTO(BankAccount $bankAccount): BankAccountDTO
    {
        return new BankAccountDTO(
            id: $bankAccount->getId(),
            foodStoreId: $bankAccount->getFoodStore()->getId(),
            accountHolderName: $bankAccount->getAccountHolderName(),
            formattedTransit: $bankAccount->getFormattedTransit(),
            institutionNumber: $bankAccount->getInstitutionNumber(),
            maskedAccountNumber: $bankAccount->getMaskedAccountNumber(),
            isVerified: $bankAccount->isVerified(),
            verifiedAt: $bankAccount->getVerifiedAt(),
            createdAt: $bankAccount->getCreatedAt(),
            updatedAt: $bankAccount->getUpdatedAt()
        );
    }
}