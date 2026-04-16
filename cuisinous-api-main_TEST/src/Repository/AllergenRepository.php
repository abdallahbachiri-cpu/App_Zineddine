<?php

namespace App\Repository;

use App\Entity\Allergen;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Allergen>
 */
class AllergenRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Allergen::class);
    }

    public function findAllWithSearch(?string $search): array
    {
        $qb = $this->createQueryBuilder('c');

        if ($search) {
            $search = strtolower($search);
            $conditions = [];

            foreach (Allergen::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(c.$field) LIKE :search";
            }

            $qb->andWhere(implode(' OR ', $conditions))
                ->setParameter('search', '%' . $search . '%');
        }

        return $qb
            ->getQuery()
            ->getResult();
    }


    //    /**
    //     * @return Allergen[] Returns an array of Allergen objects
    //     */
    //    public function findByExampleField($value): array
    //    {
    //        return $this->createQueryBuilder('a')
    //            ->andWhere('a.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('a.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findOneBySomeField($value): ?Allergen
    //    {
    //        return $this->createQueryBuilder('a')
    //            ->andWhere('a.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->getQuery()
    //            ->getOneOrNullResult()
    //        ;
    //    }
}
