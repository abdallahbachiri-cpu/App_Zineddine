<?php

namespace App\Repository;

use App\Entity\User;
use App\Helper\ValidationHelper;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<User>
 */
class UserRepository extends ServiceEntityRepository
{
    private EntityManagerInterface $entityManager;
    public function __construct(ManagerRegistry $registry,
    EntityManagerInterface $entityManager,
    private ValidationHelper $validationHelper
    )
    {
        parent::__construct($registry, User::class);
        $this->entityManager = $entityManager;
    }

    public function findUserByEmail(string $email): ?User
    {
        $normalizedEmail = $this->validationHelper->normalizeEmail($email);
        return $this->findOneBy(['email' => $normalizedEmail]);
    }

    public function findAllWithSearch(?string $search, string $sortBy, string $sortOrder, int $limit, int $offset, ?string $userType): array
    {
        $qb = $this->createQueryBuilder('u');

        if ($search) {
            $search = strtolower($search); // Normalize the search input to lowercase
            // Dynamically build the conditions based on the searchable fields
            $conditions = [];
            foreach (User::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(u.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            // Combine conditions with OR
            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        if ($userType) {
            $qb->andWhere('u.type = :userType')
               ->setParameter('userType', $userType);
        }

        $qb->orderBy('u.' . $sortBy, $sortOrder)
        ->setMaxResults($limit)
        ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countWithSearch(?string $search, ?string $userType): int
    {
        $qb = $this->createQueryBuilder('u')
                ->select('COUNT(u.id)');

        if ($search) {
            $search = strtolower($search); // Normalize the search input to lowercase
            // Dynamically build the conditions based on the searchable fields
            $conditions = [];
            foreach (User::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(u.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            // Combine conditions with OR
            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        if ($userType) {
            $qb->andWhere('u.type = :userType')
               ->setParameter('userType', $userType);
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    /**
     * Save the given user entity.
     * If the user exists, it will update, otherwise, it will create a new user.
     */
    public function save(User $user): void
    {
        // Persist the user entity
        $this->entityManager->persist($user);
        
        // Flush changes to the database
        $this->entityManager->flush();
    }


    /**
     * Find available users with pagination.
     *
     * @param int $limit
     * @param int $offset
     * @return User[]
    */
    public function findAvailableUsers(int $limit, int $offset): array
    {
        return $this->createQueryBuilder('u')
            ->andWhere('u.isActive = true')
            ->andWhere('u.deletedAt IS NULL')
            ->setMaxResults($limit)
            ->setFirstResult($offset)
            ->getQuery()
            ->getResult();
    }

    /**
     * Count available users.
     *
     * @return int
     */
    public function countAvailableUsers(): int
    {
        return $this->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->andWhere('u.isActive = true')
            ->andWhere('u.deletedAt IS NULL')
            ->getQuery()
            ->getSingleScalarResult();
    }

    /**
     * Find an available user by ID (active and not soft-deleted).
     *
     * @param string $id The user ID.
     * @return User|null The available User object or null if not found.
     */
    public function findAvailableUserById(string $id): ?User
    {
        return $this->createQueryBuilder('u')
            ->andWhere('u.id = :id')
            ->andWhere('u.isActive = true')
            ->andWhere('u.deletedAt IS NULL')
            ->setParameter('id', $id)
            ->getQuery()
            ->getOneOrNullResult();
    }

    /**
     * Find unavailable users with pagination (either inactive or soft-deleted).
     *
     * @param int $limit
     * @param int $offset
     * @return User[]
     */
    public function findUnavailableUsers(int $limit, int $offset): array
    {
        return $this->createQueryBuilder('u')
            ->andWhere('u.isActive = false OR u.deletedAt IS NOT NULL')
            ->setMaxResults($limit)
            ->setFirstResult($offset)
            ->getQuery()
            ->getResult();
    }

    /**
     * Count unavailable users.
     *
     * @return int
     */
    public function countUnavailableUsers(): int
    {
        return $this->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->andWhere('u.isActive = false OR u.deletedAt IS NOT NULL')
            ->getQuery()
            ->getSingleScalarResult();
    }

    public function findUsersWithFcmToken(?string $userType = null): array
    {
        $qb = $this->createQueryBuilder('u')
            ->andWhere('u.fcmToken IS NOT NULL')
            ->andWhere('u.fcmToken != :emptyToken')
            ->andWhere('u.isActive = true')
            ->andWhere('u.deletedAt IS NULL')
            ->setParameter('emptyToken', '');

        if ($userType) {
            $qb->andWhere('u.type = :type')
               ->setParameter('type', $userType);
        }

        return $qb->getQuery()->getResult();
    }

    public function countUsersByType(string $type): int
    {
        return $this->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->where('u.type = :type')
            ->andWhere('u.isActive = true')
            ->andWhere('u.deletedAt IS NULL')
            ->setParameter('type', $type)
            ->getQuery()
            ->getSingleScalarResult();
    }
}
