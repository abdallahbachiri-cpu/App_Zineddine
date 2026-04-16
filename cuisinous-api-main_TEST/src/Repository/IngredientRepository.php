<?php

namespace App\Repository;

use App\Entity\FoodStore;
use App\Entity\Ingredient;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Ingredient>
 */
class IngredientRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Ingredient::class);
    }

    public function findByFoodStoreWithSearch(
        FoodStore $foodStore,
        ?string $search,
        string $sortBy,
        string $sortOrder,
        int $limit,
        int $offset
    ): array
    {
        $qb = $this->createQueryBuilder('i')
            ->where('i.foodStore = :foodStore')
            ->setParameter('foodStore', $foodStore);

        if ($search) {
            $search = strtolower($search);
            $conditions = [];
            foreach (Ingredient::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(i.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        $qb->orderBy('i.' . $sortBy, $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countByFoodStoreWithSearch(FoodStore $foodStore, ?string $search): int
    {
        $qb = $this->createQueryBuilder('i')
            ->select('COUNT(i.id)')
            ->where('i.foodStore = :foodStore')
            ->setParameter('foodStore', $foodStore);

        if ($search) {
            $search = strtolower($search);
            $conditions = [];
            foreach (Ingredient::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(i.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    public function findAllWithSearch(?string $search, string $sortBy, string $sortOrder, int $limit, int $offset): array
    {
        $qb = $this->createQueryBuilder('u');

        if ($search) {
            $search = strtolower($search); // Normalize the search input to lowercase
            // Dynamically build the conditions based on the searchable fields
            $conditions = [];
            foreach (Ingredient::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(u.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            // Combine conditions with OR
            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        $qb->orderBy('u.' . $sortBy, $sortOrder)
        ->setMaxResults($limit)
        ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countWithSearch(?string $search): int
    {
        $qb = $this->createQueryBuilder('u')
                ->select('COUNT(u.id)');

        if ($search) {
            $search = strtolower($search); // Normalize the search input to lowercase
            // Dynamically build the conditions based on the searchable fields
            $conditions = [];
            foreach (Ingredient::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(u.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            // Combine conditions with OR
            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    //    /**
    //     * @return Ingredient[] Returns an array of Ingredient objects
    //     */
    //    public function findByExampleField($value): array
    //    {
    //        return $this->createQueryBuilder('i')
    //            ->andWhere('i.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('i.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findOneBySomeField($value): ?Ingredient
    //    {
    //        return $this->createQueryBuilder('i')
    //            ->andWhere('i.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->getQuery()
    //            ->getOneOrNullResult()
    //        ;
    //    }
}
