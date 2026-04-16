<?php

namespace App\Helper;

class SortingHelper
{
    public const DEFAULT_SORT_BY = 'createdAt';
    public const DEFAULT_SORT_ORDER = 'DESC';
    private const ALLOWED_SORT_ORDERS = ['ASC', 'DESC'];

    /**
     * Validate and sanitize the sorting parameters.
     *
     * @param string|null $sortBy The field to sort by.
     * @param string|null $sortOrder The order of sorting ('ASC' or 'DESC').
     * @param array $allowedFields The list of allowed sorting fields for the entity.
     * @return array An array containing the validated sortBy and sortOrder values.
     *
     * @throws \InvalidArgumentException If the sortBy field is not allowed.
     */
    public static function validateSorting(?string $sortBy, ?string $sortOrder, array $allowedFields): array
    {
        // Use the default sortBy if none is provided
        $sortBy = $sortBy ?? self::DEFAULT_SORT_BY;

        // Ensure the sortBy field is allowed
        if (!in_array($sortBy, $allowedFields, true)) {
            throw new \InvalidArgumentException("Invalid sort field: $sortBy. Allowed fields are: " . implode(', ', $allowedFields));
        }

        // Use the default sortOrder if none is provided or sanitize the given sortOrder
        $sortOrder = strtoupper($sortOrder ?? self::DEFAULT_SORT_ORDER);
        if (!in_array($sortOrder, self::ALLOWED_SORT_ORDERS, true)) {
            $sortOrder = self::DEFAULT_SORT_ORDER;
        }

        return [$sortBy, $sortOrder];
    }
}