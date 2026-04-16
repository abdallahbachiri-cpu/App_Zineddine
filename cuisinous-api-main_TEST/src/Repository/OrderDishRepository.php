<?php

namespace App\Repository;

use App\Entity\Dish;
use App\Entity\Order;
use App\Entity\OrderDish;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<OrderDish>
 */
class OrderDishRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, OrderDish::class);
    }

    public function orderContainsDish(Order $order, Dish $dish): bool
    {
        return $this->createQueryBuilder('od')
            ->select('COUNT(od.id)')
            ->join('od.cartDish', 'cd')
            ->where('od.order = :order')
            ->andWhere('cd.dish = :dish')
            ->setParameter('order', $order)
            ->setParameter('dish', $dish)
            ->getQuery()
            ->getSingleScalarResult() > 0;
    }
}
