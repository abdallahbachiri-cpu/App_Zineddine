<?php

namespace App\Entity\Enum;

enum OrderTipPaymentStatus: string
{
    case Processing = 'processing';
    case Paid = 'paid';
    case Failed = 'failed';
}
