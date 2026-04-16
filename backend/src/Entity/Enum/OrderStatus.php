<?php

namespace App\Entity\Enum;

enum OrderStatus: string
{
    case Pending = 'pending';       // Order placed but not yet confirmed
    case Confirmed = 'confirmed';   // Order confirmed by the seller, in preparation
    case Cancelled = 'cancelled';   // Order cancelled by seller or buyer
    case Ready = 'ready';   // Order ready for pickup
    case Completed = 'completed';   // Order marked as completed after final confirmation (e.g., using the code)
}
