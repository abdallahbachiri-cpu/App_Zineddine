<?php

namespace App\Entity\Enum;

enum StoreDeliveryOption: string
{
    case PickupOnly = 'pickup_only';       // Only allows pickup
    // case DeliveryOnly = 'delivery_only';   // Only allows delivery
    case Both = 'both';                    // Allows both pickup and delivery
}