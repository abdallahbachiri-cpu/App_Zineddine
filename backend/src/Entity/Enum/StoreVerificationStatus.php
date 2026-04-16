<?php

namespace App\Entity\Enum;

enum StoreVerificationStatus: string
{
    case Pending = 'pending';
    case Rejected = 'rejected';
    case Approved = 'approved';
}