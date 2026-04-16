<?php

namespace App\Service\Statistics;

use App\Entity\Enum\OrderStatus;
use App\Entity\User;
use App\Helper\MoneyHelper;
use App\Repository\OrderRepository;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;

class StatisticsService
{
    public function __construct(
        private OrderRepository $orderRepository,
        private UserRepository $userRepository,
        private EntityManagerInterface $entityManager
    ) {}

    /**
     * Get basic statistics based on user type
     */
    public function getBasicStatistics(User $user): array
    {
        $userType = $user->getType();

        return match ($userType) {
            User::TYPE_ADMIN => $this->getAdminBasicStatistics(),
            User::TYPE_SELLER => $this->getSellerBasicStatistics($user),
            User::TYPE_BUYER => $this->getBuyerBasicStatistics($user),
            default => throw new \InvalidArgumentException('Invalid user type')
        };
    }

    /**
     * Admin basic statistics
     */
    private function getAdminBasicStatistics(): array
    {
        return [
            'totalUsers' => $this->userRepository->countAvailableUsers(),
            'totalBuyers' => $this->userRepository->countUsersByType(User::TYPE_BUYER),
            'totalSellers' => $this->userRepository->countUsersByType(User::TYPE_SELLER),
            'totalOrders' => $this->orderRepository->countAllOrders(),
            'totalPendingOrders' => $this->orderRepository->countOrdersByStatus(OrderStatus::Pending->value),
            'totalRevenue' => $this->orderRepository->sumGrossTotalOfCompletedOrders(),
        ];
    }

    /**
     * Seller basic statistics - only their store data
     */
    private function getSellerBasicStatistics(User $user): array
    {
        $foodStore = $user->getFoodStore();
        if (!$foodStore) {
            return [
                'totalOrders' => 0,
                'totalPendingOrders' => 0,
                'totalRevenue' => '0.00',
            ];
        }

        $foodStoreId = $foodStore->getId();

        return [
            'totalOrders' => $this->orderRepository->countAllOrders(['foodStoreId' => $foodStoreId]),
            'totalPendingOrders' => $this->orderRepository->countOrdersByStatus(OrderStatus::Pending->value, ['foodStoreId' => $foodStoreId]),
            'totalRevenue' => MoneyHelper::normalize($this->orderRepository->sumGrossTotalOfCompletedOrders(['foodStoreId' => $foodStoreId])),
        ];
    }

    /**
     * Buyer basic statistics
     */
    private function getBuyerBasicStatistics(User $user): array
    {
        return [
            'totalOrders' => $this->orderRepository->countAllOrders(['buyerId' => $user->getId()]),
            'totalPendingOrders' => $this->orderRepository->countOrdersByStatus(OrderStatus::Pending->value, ['buyerId' => $user->getId()]),
        ];
    }

    /**
     * Get revenue by month for a specific year
     * Returns revenue grouped by month (1-12) for sellers and admins
     * 
     * @param User $user The user requesting statistics
     * @param int $year The year to get revenue for (must be between 1900 and 2200)
     * @return array Array with month (1-12) => revenue (string)
     * @throws \InvalidArgumentException If year is invalid or user is a buyer
     */
    public function getRevenueByMonthForYear(User $user, int $year): array
    {
        // Validate year range
        if ($year < 1900 || $year > 2200) {
            throw new \InvalidArgumentException('Year must be between 1900 and 2200');
        }

        $userType = $user->getType();

        // Buyers don't have revenue statistics
        if ($userType === User::TYPE_BUYER) {
            throw new \InvalidArgumentException('Revenue statistics are not available for buyers');
        }

        $filters = [];

        // Apply filters based on user type
        if ($userType === User::TYPE_SELLER) {
            $foodStore = $user->getFoodStore();
            if (!$foodStore) {
                // Return empty months if no store
                $revenueByMonth = [];
                for ($month = 1; $month <= 12; $month++) {
                    $revenueByMonth[$month] = '0.00';
                }
                return $revenueByMonth;
            }
            $filters['foodStoreId'] = $foodStore->getId();
        }
        // Admin: no filters needed

        $revenueByMonth = $this->orderRepository->getRevenueByMonthForYear($year, $filters);

        // Normalize all values using MoneyHelper
        foreach ($revenueByMonth as $month => $revenue) {
            $revenueByMonth[$month] = MoneyHelper::normalize((float) $revenue);
        }

        return $revenueByMonth;
    }

    /**
     * Get revenue by day for a specific month and year
     * Returns revenue grouped by day (1-31) for sellers and admins
     * 
     * @param User $user The user requesting statistics
     * @param int $year The year
     * @param int $month The month (1-12)
     * @return array Array with day (1-31) => revenue (string)
     * @throws \InvalidArgumentException If year/month is invalid or user is a buyer
     */
    public function getRevenueByDayForMonth(User $user, int $year, int $month): array
    {
        // Validate year range
        if ($year < 1900 || $year > 2200) {
            throw new \InvalidArgumentException('Year must be between 1900 and 2200');
        }

        // Validate month
        if ($month < 1 || $month > 12) {
            throw new \InvalidArgumentException('Month must be between 1 and 12');
        }

        $userType = $user->getType();

        // Buyers don't have revenue statistics
        if ($userType === User::TYPE_BUYER) {
            throw new \InvalidArgumentException('Revenue statistics are not available for buyers');
        }

        $filters = [];

        // Apply filters based on user type
        if ($userType === User::TYPE_SELLER) {
            $foodStore = $user->getFoodStore();
            if (!$foodStore) {
                // Return empty days if no store
                $lastDay = (int) date('t', mktime(0, 0, 0, $month, 1, $year));
                $revenueByDay = [];
                for ($day = 1; $day <= $lastDay; $day++) {
                    $revenueByDay[$day] = '0.00';
                }
                return $revenueByDay;
            }
            $filters['foodStoreId'] = $foodStore->getId();
        }
        // Admin: no filters needed

        $revenueByDay = $this->orderRepository->getRevenueByDayForMonth($year, $month, $filters);

        // Normalize all values using MoneyHelper
        foreach ($revenueByDay as $day => $revenue) {
            $revenueByDay[$day] = MoneyHelper::normalize((float) $revenue);
        }

        return $revenueByDay;
    }

    /**
     * Get revenue by year (aggregated)
     * Returns revenue grouped by year for sellers and admins
     * 
     * @param User $user The user requesting statistics
     * @return array Array with year => revenue (string)
     * @throws \InvalidArgumentException If user is a buyer
     */
    public function getRevenueByYear(User $user): array
    {
        $userType = $user->getType();

        // Buyers don't have revenue statistics
        if ($userType === User::TYPE_BUYER) {
            throw new \InvalidArgumentException('Revenue statistics are not available for buyers');
        }

        $filters = [];

        // Apply filters based on user type
        if ($userType === User::TYPE_SELLER) {
            $foodStore = $user->getFoodStore();
            if (!$foodStore) {
                return [];
            }
            $filters['foodStoreId'] = $foodStore->getId();
        }
        // Admin: no filters needed

        $revenueByYear = $this->orderRepository->getRevenueByYear($filters);

        // Normalize all values using MoneyHelper
        foreach ($revenueByYear as $year => $revenue) {
            $revenueByYear[$year] = MoneyHelper::normalize((float) $revenue);
        }

        return $revenueByYear;
    }
}
