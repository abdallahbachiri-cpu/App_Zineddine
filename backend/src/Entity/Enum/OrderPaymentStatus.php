<?php

namespace App\Entity\Enum;

enum OrderPaymentStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Paid = 'paid';
    case Failed = 'failed';
    case RefundRequested = 'refund_requested';
    case Refunded = 'refunded';
    case RefundFailed = 'refund_failed';

    // case PENDING = 'pending';
    // case PROCESSING = 'processing';
    // case PAID = 'paid';
    // case FAILED = 'failed';
    // case REFUND_REQUESTED = 'refund_requested';
    // case REFUNDED = 'refunded';
    // case REFUND_FAILED = 'refund_failed';
}
