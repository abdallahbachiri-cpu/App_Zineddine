<?php

namespace App\Repository;

use App\Entity\Enum\OrderStatus;
use App\Entity\FoodStore;
use App\Entity\Order;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\ORM\QueryBuilder;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Order>
 */
class OrderRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Order::class);
    }

    /**
     * Find orders with active Twilio sessions where the buyer or seller phone number
     * matches one of the given phone numbers, excluding the current order.
     *
     * @param string $currentOrderId
     * @param string[] $phoneNumbers
     * @return Order[]
     */
    public function findOrdersWithConflictingTwilioSessions(string $currentOrderId, array $phoneNumbers): array
    {
        return $this->createQueryBuilder('o')
            ->join('o.buyer', 'b')
            ->join('o.foodStore', 'fs')
            ->join('fs.seller', 's')
            ->where('o.id != :currentOrderId')
            ->andWhere('o.twilioSessionSid IS NOT NULL')
            ->andWhere('b.phoneNumber IN (:phones) OR s.phoneNumber IN (:phones)')
            ->setParameter('currentOrderId', $currentOrderId)
            ->setParameter('phones', $phoneNumbers)
            ->getQuery()
            ->getResult();
    }

    public function findFilteredOrders(?string $buyerId, ?string $foodStoreId, ?string $search, string $sortBy, string $sortOrder, int $limit, int $offset, ?string $minPrice, ?string $maxPrice, array $filters = []): array
    {
        $qb = $this->createQueryBuilder('o');

        if ($foodStoreId) {
            $qb->andWhere('o.foodStore = :foodStoreId')
                ->setParameter('foodStoreId', $foodStoreId);
        }

        if ($buyerId) {
            $qb->andWhere('o.buyer = :buyerId')
                ->setParameter('buyerId', $buyerId);
        }

        if ($search) {
            $search = strtolower($search); // Normalize search input to lowercase
            $conditions = [];
            foreach (Order::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(o.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        if ($minPrice !== null) {
            $qb->andWhere('o.totalPrice >= :minPrice')
                ->setParameter('minPrice', $minPrice);
        }

        if ($maxPrice !== null) {
            $qb->andWhere('o.totalPrice <= :maxPrice')
                ->setParameter('maxPrice', $maxPrice);
        }

        if (isset($filters['status'])) {
            $qb->andWhere('o.status = :status')
                ->setParameter('status', $filters['status']);
        }

        if (isset($filters['paymentStatus'])) {
            $qb->andWhere('o.paymentStatus = :paymentStatus')
                ->setParameter('paymentStatus', $filters['paymentStatus']);
        }

        if (isset($filters['deliveryStatus'])) {
            $qb->andWhere('o.deliveryStatus = :deliveryStatus')
                ->setParameter('deliveryStatus', $filters['deliveryStatus']);
        }

        $qb->orderBy("o.$sortBy", $sortOrder)
            ->setMaxResults($limit)
            ->setFirstResult($offset);

        return $qb->getQuery()->getResult();
    }

    public function countFilteredOrders(?string $buyerId, ?string $foodStoreId, ?string $search, ?float $minPrice, ?float $maxPrice, array $filters = []): int
    {
        $qb = $this->createQueryBuilder('o')
            ->select('COUNT(DISTINCT o.id)');

        if ($foodStoreId) {
            $qb->andWhere('o.foodStore = :foodStoreId')
                ->setParameter('foodStoreId', $foodStoreId);
        }

        if ($buyerId) {
            $qb->andWhere('o.buyer = :buyerId')
                ->setParameter('buyerId', $buyerId);
        }

        if ($search) {
            $search = strtolower($search); // Normalize search input to lowercase
            $conditions = [];
            foreach (Order::SEARCHABLE_FIELDS as $field) {
                $conditions[] = "LOWER(o.$field) LIKE :search";
            }
            $implodedConditions = implode(' OR ', $conditions);

            $qb->andWhere($implodedConditions)
                ->setParameter('search', '%' . $search . '%');
        }

        if ($minPrice !== null) {
            $qb->andWhere('o.totalPrice >= :minPrice')
                ->setParameter('minPrice', $minPrice);
        }

        if ($maxPrice !== null) {
            $qb->andWhere('o.totalPrice <= :maxPrice')
                ->setParameter('maxPrice', $maxPrice);
        }

        if (isset($filters['status'])) {
            $qb->andWhere('o.status = :status')
                ->setParameter('status', $filters['status']);
        }

        if (isset($filters['paymentStatus'])) {
            $qb->andWhere('o.paymentStatus = :paymentStatus')
                ->setParameter('paymentStatus', $filters['paymentStatus']);
        }

        if (isset($filters['deliveryStatus'])) {
            $qb->andWhere('o.deliveryStatus = :deliveryStatus')
                ->setParameter('deliveryStatus', $filters['deliveryStatus']);
        }

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    /**
     * Count all orders with optional filters
     */
    public function countAllOrders(array $filters = []): int
    {
        $qb = $this->createQueryBuilder('o')
            ->select('COUNT(o.id)');

        $this->applyOrderFilters($qb, $filters);

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    /**
     * Count orders by status with optional filters
     */
    public function countOrdersByStatus(string $status, array $filters = []): int
    {
        $qb = $this->createQueryBuilder('o')
            ->select('COUNT(o.id)')
            ->where('o.status = :status')
            ->setParameter('status', $status);

        $this->applyOrderFilters($qb, $filters);

        return (int) $qb->getQuery()->getSingleScalarResult();
    }

    /**
     * Sum gross total of completed orders with optional filters
     */
    public function sumGrossTotalOfCompletedOrders(array $filters = []): string
    {
        $qb = $this->createQueryBuilder('o')
            ->select('COALESCE(SUM(o.grossTotal), 0)')
            ->where('o.status = :status')
            ->setParameter('status', OrderStatus::Completed->value);

        $this->applyOrderFilters($qb, $filters);

        $result = $qb->getQuery()->getSingleScalarResult();
        return $result ?? '0.00';
    }

    // TODO: optimize queries and use functions like DATE_TRUNC(S)

    /**
     * Get revenue by month for a specific year
     * Returns array with month number (1-12) as key and revenue as value
     * 
     * Uses database-level aggregation (GROUP BY) for efficiency, following the pattern
     * of sumGrossTotalOfCompletedOrders() which uses SUM() at database level.
     * 
     * @param int $year The year to get revenue for
     * @param array $filters Optional filters (foodStoreId, buyerId)
     * @return array Array with month (1-12) => revenue (string)
     */
    public function getRevenueByMonthForYear(int $year, array $filters = []): array
    {
        $startDate = new \DateTimeImmutable("{$year}-01-01 00:00:00");
        $endDate = new \DateTimeImmutable("{$year}-12-31 23:59:59");

        // Build WHERE conditions using Query Builder (consistent with other methods)
        $qb = $this->createQueryBuilder('o')
            ->where('o.status = :status')
            ->andWhere('o.createdAt >= :startDate')
            ->andWhere('o.createdAt <= :endDate')
            ->setParameter('status', OrderStatus::Completed->value)
            ->setParameter('startDate', $startDate)
            ->setParameter('endDate', $endDate);

        $this->applyOrderFilters($qb, $filters);

        // Get metadata for column names
        $metadata = $this->getEntityManager()->getClassMetadata(Order::class);
        $conn = $this->getEntityManager()->getConnection();
        $tableName = $metadata->getTableName();
        $createdAtColumn = $metadata->getColumnName('createdAt');
        $grossTotalColumn = $metadata->getColumnName('grossTotal');
        $statusColumn = $metadata->getColumnName('status');

        // Build WHERE clause from Query Builder (PostgreSQL-compatible)
        $whereParts = [];
        $whereParts[] = "o.{$conn->quoteIdentifier($statusColumn)} = :status";
        $whereParts[] = "o.{$conn->quoteIdentifier($createdAtColumn)} >= :startDate";
        $whereParts[] = "o.{$conn->quoteIdentifier($createdAtColumn)} <= :endDate";

        $params = [
            'status' => OrderStatus::Completed->value,
            'startDate' => $startDate->format('Y-m-d H:i:s'),
            'endDate' => $endDate->format('Y-m-d H:i:s'),
        ];

        if (!empty($filters['foodStoreId'])) {
            $foodStoreColumn = $metadata->getAssociationMapping('foodStore')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($foodStoreColumn)} = :foodStoreId";
            $params['foodStoreId'] = $filters['foodStoreId'];
        }

        if (!empty($filters['buyerId'])) {
            $buyerColumn = $metadata->getAssociationMapping('buyer')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($buyerColumn)} = :buyerId";
            $params['buyerId'] = $filters['buyerId'];
        }

        $whereClause = 'WHERE ' . implode(' AND ', $whereParts);

        // Use native SQL for aggregation (PostgreSQL-compatible)
        // Using PostgreSQL EXTRACT function and proper quoting for table/column names
        $quotedTableName = $conn->quoteIdentifier($tableName);
        $quotedCreatedAt = $conn->quoteIdentifier($createdAtColumn);
        $quotedGrossTotal = $conn->quoteIdentifier($grossTotalColumn);

        $sql = "
            SELECT 
                EXTRACT(MONTH FROM o.{$quotedCreatedAt})::integer as month, 
                COALESCE(SUM(o.{$quotedGrossTotal}), 0) as revenue
            FROM {$quotedTableName} o
            {$whereClause}
            GROUP BY EXTRACT(MONTH FROM o.{$quotedCreatedAt})
            ORDER BY month ASC
        ";

        $stmt = $conn->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }

        $results = $stmt->executeQuery()->fetchAllAssociative();

        // Initialize all months with 0.00
        $revenueByMonth = [];
        for ($month = 1; $month <= 12; $month++) {
            $revenueByMonth[$month] = '0.00';
        }

        // Fill in actual revenue data
        foreach ($results as $result) {
            $month = (int) $result['month'];
            $revenueByMonth[$month] = (string) $result['revenue'];
        }

        return $revenueByMonth;
    }

    /**
     * Get revenue by day for a specific month
     * Returns array with day number (1-31) as key and revenue as value
     * 
     * Uses database-level aggregation (GROUP BY) for efficiency, following the pattern
     * of sumGrossTotalOfCompletedOrders() which uses SUM() at database level.
     * 
     * @param int $year The year
     * @param int $month The month (1-12)
     * @param array $filters Optional filters (foodStoreId, buyerId)
     * @return array Array with day (1-31) => revenue (string)
     */
    public function getRevenueByDayForMonth(int $year, int $month, array $filters = []): array
    {
        // Validate month
        if ($month < 1 || $month > 12) {
            throw new \InvalidArgumentException('Month must be between 1 and 12');
        }

        // Get the last day of the month
        $lastDay = (int) date('t', mktime(0, 0, 0, $month, 1, $year));

        $startDate = new \DateTimeImmutable("{$year}-{$month}-01 00:00:00");
        $endDate = new \DateTimeImmutable("{$year}-{$month}-{$lastDay} 23:59:59");

        // Build WHERE conditions using Query Builder (consistent with other methods)
        $qb = $this->createQueryBuilder('o')
            ->where('o.status = :status')
            ->andWhere('o.createdAt >= :startDate')
            ->andWhere('o.createdAt <= :endDate')
            ->setParameter('status', OrderStatus::Completed->value)
            ->setParameter('startDate', $startDate)
            ->setParameter('endDate', $endDate);

        $this->applyOrderFilters($qb, $filters);

        // Get metadata for column names
        $metadata = $this->getEntityManager()->getClassMetadata(Order::class);
        $conn = $this->getEntityManager()->getConnection();
        $tableName = $metadata->getTableName();
        $createdAtColumn = $metadata->getColumnName('createdAt');
        $grossTotalColumn = $metadata->getColumnName('grossTotal');
        $statusColumn = $metadata->getColumnName('status');

        // Build WHERE clause from Query Builder (PostgreSQL-compatible)
        $whereParts = [];
        $whereParts[] = "o.{$conn->quoteIdentifier($statusColumn)} = :status";
        $whereParts[] = "o.{$conn->quoteIdentifier($createdAtColumn)} >= :startDate";
        $whereParts[] = "o.{$conn->quoteIdentifier($createdAtColumn)} <= :endDate";

        $params = [
            'status' => OrderStatus::Completed->value,
            'startDate' => $startDate->format('Y-m-d H:i:s'),
            'endDate' => $endDate->format('Y-m-d H:i:s'),
        ];

        if (!empty($filters['foodStoreId'])) {
            $foodStoreColumn = $metadata->getAssociationMapping('foodStore')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($foodStoreColumn)} = :foodStoreId";
            $params['foodStoreId'] = $filters['foodStoreId'];
        }

        if (!empty($filters['buyerId'])) {
            $buyerColumn = $metadata->getAssociationMapping('buyer')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($buyerColumn)} = :buyerId";
            $params['buyerId'] = $filters['buyerId'];
        }

        $whereClause = 'WHERE ' . implode(' AND ', $whereParts);

        // Use native SQL for aggregation (PostgreSQL-compatible)
        // Using PostgreSQL EXTRACT function and proper quoting for table/column names
        $quotedTableName = $conn->quoteIdentifier($tableName);
        $quotedCreatedAt = $conn->quoteIdentifier($createdAtColumn);
        $quotedGrossTotal = $conn->quoteIdentifier($grossTotalColumn);

        $sql = "
            SELECT 
                EXTRACT(DAY FROM o.{$quotedCreatedAt})::integer as day, 
                COALESCE(SUM(o.{$quotedGrossTotal}), 0) as revenue
            FROM {$quotedTableName} o
            {$whereClause}
            GROUP BY EXTRACT(DAY FROM o.{$quotedCreatedAt})
            ORDER BY day ASC
        ";

        $stmt = $conn->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }

        $results = $stmt->executeQuery()->fetchAllAssociative();

        // Initialize all days of the month with 0.00
        $revenueByDay = [];
        for ($day = 1; $day <= $lastDay; $day++) {
            $revenueByDay[$day] = '0.00';
        }

        // Fill in actual revenue data
        foreach ($results as $result) {
            $day = (int) $result['day'];
            $revenueByDay[$day] = (string) $result['revenue'];
        }

        return $revenueByDay;
    }

    /**
     * Get revenue by year (aggregated)
     * Returns array with year as key and revenue as value
     * 
     * Uses database-level aggregation (GROUP BY) for efficiency, following the pattern
     * of sumGrossTotalOfCompletedOrders() which uses SUM() at database level.
     * 
     * @param array $filters Optional filters (foodStoreId, buyerId)
     * @return array Array with year => revenue (string)
     */
    public function getRevenueByYear(array $filters = []): array
    {
        // Get metadata for column names
        $em = $this->getEntityManager();
        $metadata = $em->getClassMetadata(Order::class);
        $conn = $em->getConnection();
        $tableName = $metadata->getTableName();
        $createdAtColumn = $metadata->getColumnName('createdAt');
        $grossTotalColumn = $metadata->getColumnName('grossTotal');
        $statusColumn = $metadata->getColumnName('status');

        $currentYear = (int) (new \DateTimeImmutable())->format('Y');
        $startYear = $currentYear;

        if (!empty($filters['foodStoreId'])) {
            // Seller => use food store creation year
            $foodStore = $em->getRepository(FoodStore::class)
                ->find($filters['foodStoreId']);

            if ($foodStore instanceof FoodStore && $foodStore->getCreatedAt()) {
                $startYear = (int) $foodStore->getCreatedAt()->format('Y');
            }
        } else {
            // Admin => use oldest order year in DB
            $quotedTable = $conn->quoteIdentifier($tableName);
            $quotedCreatedAt = $conn->quoteIdentifier($createdAtColumn);

            $minYearSql = "
            SELECT MIN(EXTRACT(YEAR FROM {$quotedCreatedAt}))::integer AS min_year
            FROM {$quotedTable}
        ";

            $minYear = $conn->executeQuery($minYearSql)->fetchOne();
            if ($minYear !== null) {
                $startYear = (int) $minYear;
            }
        }


        // Build WHERE clause from Query Builder (PostgreSQL-compatible)
        $whereParts = [];
        $whereParts[] = "o.{$conn->quoteIdentifier($statusColumn)} = :status";

        $params = ['status' => OrderStatus::Completed->value];

        if (!empty($filters['foodStoreId'])) {
            $foodStoreColumn = $metadata->getAssociationMapping('foodStore')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($foodStoreColumn)} = :foodStoreId";
            $params['foodStoreId'] = $filters['foodStoreId'];
        }

        if (!empty($filters['buyerId'])) {
            $buyerColumn = $metadata->getAssociationMapping('buyer')['joinColumns'][0]['name'];
            $whereParts[] = "o.{$conn->quoteIdentifier($buyerColumn)} = :buyerId";
            $params['buyerId'] = $filters['buyerId'];
        }

        $whereClause = 'WHERE ' . implode(' AND ', $whereParts);

        // Use native SQL for aggregation (PostgreSQL-compatible)
        // Using PostgreSQL EXTRACT function and proper quoting for table/column names
        $quotedTableName = $conn->quoteIdentifier($tableName);
        $quotedCreatedAt = $conn->quoteIdentifier($createdAtColumn);
        $quotedGrossTotal = $conn->quoteIdentifier($grossTotalColumn);

        $sql = "
            SELECT 
                EXTRACT(YEAR FROM o.{$quotedCreatedAt})::integer as year, 
                COALESCE(SUM(o.{$quotedGrossTotal}), 0) as revenue
            FROM {$quotedTableName} o
            {$whereClause}
            GROUP BY EXTRACT(YEAR FROM o.{$quotedCreatedAt})
            ORDER BY year DESC
        ";

        $stmt = $conn->prepare($sql);

        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }

        $results = $stmt->executeQuery()->fetchAllAssociative();

        $revenueByYear = [];
        for ($year = $startYear; $year <= $currentYear; $year++) {
            $revenueByYear[$year] = '0.00';
        }

        foreach ($results as $row) {
            $year = (int) $row['year'];
            $revenueByYear[$year] = (string) $row['revenue'];
        }

        ksort($revenueByYear);

        return $revenueByYear;
    }

    /**
     * Apply basic filters to query builder
     */
    private function applyOrderFilters(QueryBuilder $qb, array $filters): void
    {
        if (!empty($filters['foodStoreId'])) {
            $qb->andWhere('o.foodStore = :foodStoreId')
                ->setParameter('foodStoreId', $filters['foodStoreId']);
        }

        if (!empty($filters['buyerId'])) {
            $qb->andWhere('o.buyer = :buyerId')
                ->setParameter('buyerId', $filters['buyerId']);
        }
    }
}
