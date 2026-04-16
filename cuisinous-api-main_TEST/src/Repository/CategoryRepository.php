<?php

namespace App\Repository;

use App\Entity\Category;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Category>
 */
class CategoryRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Category::class);
    }

    public function findAllWithSearch(
        ?string $search,
        string $sortBy,
        string $sortOrder,
        int $limit,
        int $offset,
        ?string $type = null
    ): array {
        $qb = $this->createQueryBuilder('c');

        if ($search) {
            $search = strtolower($search);
            $conditions = [];
            foreach (Category::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(c.$field) LIKE :search";
            }
            $qb->andWhere(implode(' OR ', $conditions))
               ->setParameter('search', '%' . $search . '%');
        }

        if ($type) {
            $qb->andWhere('c.type = :type')
               ->setParameter('type', $type);
        }

        return $qb->orderBy('c.' . $sortBy, $sortOrder)
                 ->setMaxResults($limit)
                 ->setFirstResult($offset)
                 ->getQuery()
                 ->getResult();
    }

    public function countWithSearch(?string $search, ?string $type = null): int
    {
        $qb = $this->createQueryBuilder('c')
                   ->select('COUNT(c.id)');

        if ($search) {
            $search = strtolower($search);
            $conditions = [];
            foreach (Category::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(c.$field) LIKE :search";
            }
            $qb->andWhere(implode(' OR ', $conditions))
               ->setParameter('search', '%' . $search . '%');
        }

        if ($type) {
            $qb->andWhere('c.type = :type')
               ->setParameter('type', $type);
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }
}
