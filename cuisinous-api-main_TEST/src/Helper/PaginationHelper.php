<?php

namespace App\Helper;

class PaginationHelper
{
    // Define the default limit as a constant
    public const DEFAULT_LIMIT = 50;
    private const MAX_LIMIT = 1000;

    /**
     * Calculate the limit and offset for pagination based on the current page and limit.
     *
     * @param int $page The current page number.
     * @param int $limit The number of items per page.
     * @return array An array containing the limit and offset.
     */
    public static function calculate(int $page, int $limit): array
    {
        // Validate and sanitize limit
        $limit = filter_var(
            $limit,
            FILTER_VALIDATE_INT,
            ['options' => ['default' => self::DEFAULT_LIMIT, 'min_range' => 1, 'max_range' => self::MAX_LIMIT]]
        );

        // Validate and sanitize page
        $page = max(
            1,
            filter_var(
                $page,
                FILTER_VALIDATE_INT,
                ['options' => ['default' => 1, 'min_range' => 1]]
            )
        );

        // Calculate offset
        $offset = ($page - 1) * $limit;

        return [$page, $limit, $offset];
    }

    public static function createPaginatedResponse (int $page, int $limit, int $total, array $data): array
    {
        $totalPages = ceil($total / $limit);

        return [
            'current_page' => $page,
            'limit' => $limit,
            'total_items' => $total,
            'total_pages' => $totalPages,
            'data' => $data
        ];
    }

}