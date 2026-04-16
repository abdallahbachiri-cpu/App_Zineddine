<?php

namespace App\Repository;

use App\Entity\FoodStoreVerificationRequest;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<FoodStoreVerificationRequest>
 */
class FoodStoreVerificationRequestRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, FoodStoreVerificationRequest::class);
    }

    public function findAllWithFilters(
        array $criteria,
        string $sortBy,
        string $sortOrder,
        int $limit,
        int $offset
    ): array {
        $qb = $this->createQueryBuilder('r')
            ->leftJoin('r.foodStore', 'fs')
            ->leftJoin('fs.seller', 'seller');

        foreach ($criteria as $field => $value) {
            $qb->andWhere("r.$field = :$field")
               ->setParameter($field, $value);
        }

        return $qb->orderBy("r.$sortBy", $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset)
            ->getQuery()
            ->getResult();
    }

    public function countWithFilters(array $criteria): int
    {
        $qb = $this->createQueryBuilder('r')
            ->select('COUNT(r.id)');

        foreach ($criteria as $field => $value) {
            $qb->andWhere("r.$field = :$field")
               ->setParameter($field, $value);
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    //    /**
    //     * @return FoodStoreVerificationRequest[] Returns an array of FoodStoreVerificationRequest objects
    //     */
    //    public function findByExampleField($value): array
    //    {
    //        return $this->createQueryBuilder('f')
    //            ->andWhere('f.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('f.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findOneBySomeField($value): ?FoodStoreVerificationRequest
    //    {
    //        return $this->createQueryBuilder('f')
    //            ->andWhere('f.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->getQuery()
    //            ->getOneOrNullResult()
    //        ;
    //    }
}
