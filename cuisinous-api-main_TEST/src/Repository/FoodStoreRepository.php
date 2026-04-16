<?php

namespace App\Repository;

use App\Entity\FoodStore;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\ORM\Query\ResultSetMappingBuilder;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<FoodStore>
 */
class FoodStoreRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, FoodStore::class);
    }

    public function findAllWithSearch(?string $search, string $sortBy, string $sortOrder, int $limit, int $offset, ?array $locationFilters = [], ?string $type = null, bool $onlyActive = true): array
    {
        $qb = $this->createQueryBuilder('fs');

        if ($onlyActive) {
            $qb->andWhere('fs.isActive = :isActive')
            ->setParameter('isActive', true);
        }

        // Join with Location
        $locationFiltersExist = false;
        if (is_array($locationFilters) && count($locationFilters) > 0) {
            $locationFiltersExist = true;
            $qb->innerJoin('fs.location', 'l');
            //location required for filtering
        } else {
            $qb->leftJoin('fs.location', 'l');
        }

        if ($search) {
            $search = strtolower($search); // Normalize search input to lowercase
            // Dynamically build conditions based on searchable fields
            $conditions = [];
            foreach (FoodStore::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(fs.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }
        
        if ($type !== null) {
            $qb->andWhere('fs.type = :type')
               ->setParameter('type', $type);
        }

        if ($locationFiltersExist === true) {
            foreach ($locationFilters as $field => $value) {
                if (in_array($field, FoodStore::FILTERABLE_FIELDS, true) && is_string($value)) {
                    $qb->andWhere("LOWER(l.$field) = :$field")
                       ->setParameter($field, $value);
                }
            }
        }

        $qb->orderBy('fs.' . $sortBy, $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countWithSearch(?string $search, ?array $locationFilters = [], ?string $type = null, bool $onlyActive = true): int
    {
        $qb = $this->createQueryBuilder('fs')
            ->select('COUNT(fs.id)')
            ->leftJoin('fs.location', 'l');

        if ($onlyActive) {
            $qb->andWhere('fs.isActive = :isActive')
            ->setParameter('isActive', true);
        }

        if ($search) {
            $search = strtolower($search); // Normalize search input to lowercase
            $conditions = [];
            foreach (FoodStore::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(fs.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        if ($type !== null) {
            $qb->andWhere('fs.type = :type')
               ->setParameter('type', $type);
        }

        if (is_array($locationFilters) && count($locationFilters) > 0) {
            foreach ($locationFilters as $field => $value) {
                if (in_array($field, FoodStore::FILTERABLE_FIELDS, true) && $value) {
                    $qb->andWhere("l.$field = :$field")
                       ->setParameter($field, $value);
                }
            }
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    // Haversine formula Postgres
    public function findNearbyStores(float $latitude, float $longitude, float $radiusKm, int $limit, bool $onlyActive = true): array
    {
        $em = $this->getEntityManager();
        $rsm = new ResultSetMappingBuilder($em);
        $rsm->addRootEntityFromClassMetadata(FoodStore::class, 'fs');

        $latDelta = $radiusKm / 111.0;
        $lonDelta = $radiusKm / (111.0 * cos(deg2rad($latitude)));

        $minLat = $latitude - $latDelta;
        $maxLat = $latitude + $latDelta;
        $minLon = $longitude - $lonDelta;
        $maxLon = $longitude + $lonDelta;

        $sql = "
            SELECT fs.*
            FROM food_store fs
            JOIN location l ON fs.location_id = l.id
            WHERE l.latitude BETWEEN :minLat AND :maxLat
            AND l.longitude BETWEEN :minLon AND :maxLon
            AND 6371 * ACOS(
                    LEAST(1, GREATEST(-1,
                        COS(RADIANS(:latitude)) * COS(RADIANS(l.latitude)) * 
                        COS(RADIANS(l.longitude) - RADIANS(:longitude)) + 
                        SIN(RADIANS(:latitude)) * SIN(RADIANS(l.latitude))
                    ))
                ) <= :radiusKm
        ";

        if ($onlyActive) {
            $sql .= " AND fs.is_active = true";
        }

        $sql .= "
            ORDER BY 6371 * ACOS(
                LEAST(1, GREATEST(-1,
                    COS(RADIANS(:latitude)) * COS(RADIANS(l.latitude)) * 
                    COS(RADIANS(l.longitude) - RADIANS(:longitude)) + 
                    SIN(RADIANS(:latitude)) * SIN(RADIANS(l.latitude))
                ))
            ) ASC
            LIMIT :limit
        ";


        $query = $em->createNativeQuery($sql, $rsm);
        $query->setParameters([
            'latitude'   => $latitude,
            'longitude'  => $longitude,
            'radiusKm'   => $radiusKm,
            'limit'      => $limit,
            'minLat'     => $minLat,
            'maxLat'     => $maxLat,
            'minLon'     => $minLon,
            'maxLon'     => $maxLon,
        ]);

        return $query->getResult();
    }

    // Haversine formula MYSQL
    // public function findNearbyStores(float $latitude, float $longitude, float $radiusKm, int $limit, bool $onlyActive = true): array
    // {
    //     //  @Todo add bounding box to strict search for performance
    //     $earthRadius = 6371;
    //     $latDelta = $radiusKm / $earthRadius;
    //     $lonDelta = $radiusKm / (cos(deg2rad($latitude)) * $earthRadius);

    //     $qb = $this->createQueryBuilder('fs')
    //     ->innerJoin('fs.location', 'l')
    //     ->addSelect(
    //         '(6371 * ACOS(COS(RADIANS(:latitude)) * COS(RADIANS(l.latitude)) 
    //         * COS(RADIANS(l.longitude) - RADIANS(:longitude)) 
    //         + SIN(RADIANS(:latitude)) * SIN(RADIANS(l.latitude)))) AS HIDDEN distance'
    //     )
    //     ->having('distance <= :radiusKm')
    //     ->setParameter('latitude', $latitude)
    //     ->setParameter('longitude', $longitude)
    //     ->setParameter('radiusKm', $radiusKm)
    //     ->orderBy('distance', 'ASC')
    //     ->setMaxResults($limit);

    //     if ($onlyActive) {
    //         $qb->andWhere('fs.isActive = :isActive')
    //         ->setParameter('isActive', true);
    //     }

    //     return $qb->getQuery()->getResult();
    // }
}
