<?php

namespace App\Entity\Enum\Wallet;

enum WalletTransactionType: string
{
    case ORDER_INCOME = 'order_income';
    case TIP_INCOME = 'tip_income';
    case REFUND = 'refund';
    case WITHDRAWAL = 'withdrawal';
}