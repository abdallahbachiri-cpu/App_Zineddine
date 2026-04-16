<?php

namespace App\Entity\Abstract;

use App\Entity\Traits\Timestampable;
use App\Entity\Traits\Uuidable;
use Doctrine\ORM\Mapping as ORM;

#[ORM\MappedSuperclass]
#[ORM\HasLifecycleCallbacks]
abstract class BaseEntity
{
    use Timestampable;
    use Uuidable;
}
