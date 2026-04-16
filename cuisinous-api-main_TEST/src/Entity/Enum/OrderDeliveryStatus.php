<?php

namespace App\Entity\Enum;

enum OrderDeliveryStatus: string
{
    case Pending = 'pending';
    case Transit = 'transit';
    case Delivered = 'delivered';
}