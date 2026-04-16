<?php

namespace App\Repository;

use App\Entity\DishRating;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<DishRating>
 */
class DishRatingRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, DishRating::class);
    }

    public function findFilteredRatings(
        ?string $dishId,
        ?string $buyerId,
        ?string $orderId,
        ?string $search,
        string $sortBy,
        string $sortOrder,
        int $limit,
        int $offset,
        array $filters = []
    ): array {
        $qb = $this->createQueryBuilder('r')
            ->leftJoin('r.dish', 'd')
            ->leftJoin('r.buyer', 'b')
            ->leftJoin('r.order', 'o');
    
        if ($dishId) {
            $qb->andWhere('r.dish = :dishId')
                ->setParameter('dishId', $dishId);
        }
    
        if ($buyerId) {
            $qb->andWhere('r.buyer = :buyerId')
                ->setParameter('buyerId', $buyerId);
        }
    
        if ($orderId) {
            $qb->andWhere('r.order = :orderId')
                ->setParameter('orderId', $orderId);
        }
    
        if ($search) {
            $search = strtolower($search);
            $qb->andWhere('d.name LIKE :search OR b.email LIKE :search OR o.orderNumber LIKE :search')
                ->setParameter('search', '%' . $search . '%');
        }
    
        // Add any additional filters
        if (isset($filters['minRating'])) {
            $qb->andWhere('r.rating >= :minRating')
                ->setParameter('minRating', $filters['minRating']);
        }
    
        if (isset($filters['maxRating'])) {
            $qb->andWhere('r.rating <= :maxRating')
                ->setParameter('maxRating', $filters['maxRating']);
        }

        if (isset($filters['foodStoreId'])) {
            $qb->andWhere('d.foodStore = :foodStoreId')
                ->setParameter('foodStoreId', $filters['foodStoreId']);
        }
    
    
        $qb->orderBy("r.$sortBy", $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset);
    
        return $qb->getQuery()->getResult();
    }
    
    public function countFilteredRatings(
        ?string $dishId,
        ?string $buyerId,
        ?string $orderId,
        ?string $search,
        array $filters = []
    ): int {
        $qb = $this->createQueryBuilder('r')
            ->select('COUNT(r.id)')
            ->leftJoin('r.dish', 'd')
            ->leftJoin('r.buyer', 'b')
            ->leftJoin('r.order', 'o');
    
            if ($dishId) {
                $qb->andWhere('r.dish = :dishId')
                    ->setParameter('dishId', $dishId);
            }
        
            if ($buyerId) {
                $qb->andWhere('r.buyer = :buyerId')
                    ->setParameter('buyerId', $buyerId);
            }
        
            if ($orderId) {
                $qb->andWhere('r.order = :orderId')
                    ->setParameter('orderId', $orderId);
            }
        
            if ($search) {
                $search = strtolower($search);
                $qb->andWhere('d.name LIKE :search OR b.email LIKE :search OR o.orderNumber LIKE :search')
                    ->setParameter('search', '%' . $search . '%');
            }
        
            // Add any additional filters
            if (isset($filters['minRating'])) {
                $qb->andWhere('r.rating >= :minRating')
                    ->setParameter('minRating', $filters['minRating']);
            }
        
            if (isset($filters['maxRating'])) {
                $qb->andWhere('r.rating <= :maxRating')
                    ->setParameter('maxRating', $filters['maxRating']);
            }

            if (isset($filters['foodStoreId'])) {
                $qb->andWhere('d.foodStore = :foodStoreId')
                    ->setParameter('foodStoreId', $filters['foodStoreId']);
            }
    
        return (int) $qb->getQuery()->getSingleScalarResult();
    }
}
