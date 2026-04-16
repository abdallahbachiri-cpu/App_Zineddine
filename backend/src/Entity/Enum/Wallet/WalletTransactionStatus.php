<?php

namespace App\Entity\Enum\Wallet;

enum WalletTransactionStatus: string
{
    case PENDING = 'pending';
    case COMPLETED = 'completed';
    case FAILED = 'failed';
}