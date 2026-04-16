<?php

namespace App\Repository;

use App\Entity\Dish;
use App\Entity\FoodStore;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\ORM\QueryBuilder;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Dish>
 */
class DishRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Dish::class);
    }

    public function findActiveByStore(FoodStore $foodStore): array
    {
        return $this->createQueryBuilder('d')
            ->andWhere('d.foodStore = :foodStore')
            ->andWhere('d.deletedAt IS NULL')
            ->setParameter('foodStore', $foodStore)
            ->orderBy('d.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    public function calculateAverageRating(Dish $dish): float
    {
        return (float)$this->createQueryBuilder('d')
            ->select('AVG(dr.rating)')
            ->join('d.ratings', 'dr')
            ->where('d = :dish')
            ->andWhere('d.deletedAt IS NULL')
            ->setParameter('dish', $dish)
            ->getQuery()
            ->getSingleScalarResult() ?? 0;
    }

    public function findActiveById(string $id): ?Dish
    {
        return $this->createQueryBuilder('d')
            ->andWhere('d.id = :id')
            ->andWhere('d.deletedAt IS NULL')
            ->setParameter('id', $id)
            ->getQuery()
            ->getOneOrNullResult();
    }

    /**
     * Find a single non-deleted dish by ID scoped to a food store.
     * Use this everywhere instead of findOneBy(['id' => ..., 'foodStore' => ...]).
     */
    public function findActiveByIdAndStore(string $id, FoodStore $foodStore): ?Dish
    {
        return $this->createQueryBuilder('d')
            ->andWhere('d.id = :id')
            ->andWhere('d.foodStore = :store')
            ->andWhere('d.deletedAt IS NULL')
            ->setParameter('id', $id)
            ->setParameter('store', $foodStore)
            ->getQuery()
            ->getOneOrNullResult();
    }

    public function findActiveByIdAndStoreId(string $id, string $foodStoreId): ?Dish
    {
        return $this->createQueryBuilder('d')
            ->andWhere('d.id = :id')
            ->andWhere('d.foodStore = :storeId')
            ->andWhere('d.deletedAt IS NULL')
            ->setParameter('id', $id)
            ->setParameter('storeId', $foodStoreId)
            ->getQuery()
            ->getOneOrNullResult();
    }

    /**
     * Find a single available, non-deleted dish from an active store by ID
     * E.g. for buyers access
     */
    public function findAvailableById(string $id): ?Dish
    {
        // @TEMPORARY skip isActive check to allow viewing inactive stores
        return $this->createQueryBuilder('d')
            ->innerJoin('d.foodStore', 'fs')
            ->innerJoin('fs.seller', 'u')
            ->andWhere('d.id = :id')
            ->andWhere('d.available = :available')
            ->andWhere('d.deletedAt IS NULL')
            // ->andWhere('fs.isActive = true')
            ->andWhere('u.isActive = :sellerActive')
            ->setParameter('id', $id)
            ->setParameter('available', true)
            ->setParameter('sellerActive', true)
            ->getQuery()
            ->getOneOrNullResult();
    }

    /**
     * Find a dish regardless of its soft-delete status.
     * Use only when you explicitly need to handle already-deleted dishes (e.g. the delete endpoint 409 check).
     */
    public function findByIdAndStore(string $id, FoodStore $foodStore): ?Dish
    {
        return $this->findOneBy(['id' => $id, 'foodStore' => $foodStore]);
    }

    public function findFilteredDishes(
        ?string $foodStoreId,
        ?string $search,
        string $sortBy,
        string $sortOrder,
        int $limit,
        int $offset,
        ?string $minPrice,
        ?string $maxPrice,
        array $ingredientIds = [],
        ?bool $available = null,
        array $categoryIds = [],
        bool $onlyActiveStores = true
    ): array {
        $qb = $this->createQueryBuilder('d')
            ->innerJoin('d.foodStore', 'fs')
            ->andWhere('d.deletedAt IS NULL');

        $this->applyCommonFilters($qb, $foodStoreId, $search, $minPrice, $maxPrice, $ingredientIds, $available, $categoryIds, $onlyActiveStores);

        $qb->orderBy("d.$sortBy", $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countFilteredDishes(
        ?string $foodStoreId,
        ?string $search,
        ?float $minPrice,
        ?float $maxPrice,
        array $ingredientIds = [],
        ?bool $available = null,
        array $categoryIds = [],
        bool $onlyActiveStores = true
    ): int {
        $qb = $this->createQueryBuilder('d')
            ->select('COUNT(DISTINCT d.id)')
            ->innerJoin('d.foodStore', 'fs')
            ->andWhere('d.deletedAt IS NULL');

        $this->applyCommonFilters($qb, $foodStoreId, $search, $minPrice, $maxPrice, $ingredientIds, $available, $categoryIds, $onlyActiveStores);

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    private function applyCommonFilters(
        QueryBuilder $qb,
        ?string $foodStoreId,
        ?string $search,
        mixed $minPrice,
        mixed $maxPrice,
        array $ingredientIds,
        ?bool $available,
        array $categoryIds,
        bool $onlyActiveStores
    ): void {
        if ($onlyActiveStores) {
            $qb->andWhere('fs.isActive = :isActive')
                ->setParameter('isActive', true);
        }

        $qb->innerJoin('fs.seller', 'u')
            ->andWhere('u.isActive = :sellerActive')
            ->setParameter('sellerActive', true);

        if ($available !== null) {
            $qb->andWhere('d.available = :available')
                ->setParameter('available', $available);
        }

        if ($foodStoreId) {
            $qb->andWhere('d.foodStore = :foodStoreId')
                ->setParameter('foodStoreId', $foodStoreId);
        }

        if ($search) {
            $search = strtolower($search);
            $conditions = [];
            foreach (Dish::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(d.$field) LIKE :search";
            }
            $qb->andWhere(implode(' OR ', $conditions))
                ->setParameter('search', '%' . $search . '%');
        }

        if ($minPrice !== null) {
            $qb->andWhere('d.price >= :minPrice')
                ->setParameter('minPrice', $minPrice);
        }

        if ($maxPrice !== null) {
            $qb->andWhere('d.price <= :maxPrice')
                ->setParameter('maxPrice', $maxPrice);
        }

        if (count($ingredientIds) > 0) {
            $qb->innerJoin('d.dishIngredients', 'di')
                ->innerJoin('di.ingredient', 'i')
                ->andWhere('i.id IN (:ingredientIds)')
                ->setParameter('ingredientIds', $ingredientIds);
        }

        if (count($categoryIds) > 0) {
            $qb->innerJoin('d.categories', 'c')
                ->andWhere('c.id IN (:categoryIds)')
                ->setParameter('categoryIds', $categoryIds);
        }
    }
}
