<?php

namespace App\Entity\Enum;

enum OrderDeliveryMethod: string
{
    case Pickup = 'pickup';     // Buyer will come to pick up the order
    case Delivery = 'delivery'; // Seller will deliver the order
}