<?php

namespace App\Helper;

class SearchHelper
{
    public const MIN_SEARCH_LENGTH = 3;
    public const MAX_SEARCH_LENGTH = 255;

    /**
     * Validate and sanitize a search term.
     *
     * @param string|null $search The search term to validate.
     * @return string|null The sanitized search term, or null if it's empty.
     *
     * @throws \InvalidArgumentException If the search term is invalid.
     */
    public static function validate(?string $search): ?string
    {
        if (is_null($search) || trim($search) === '') {
            return null;
        }

        $search = trim($search);

        if (strlen($search) < self::MIN_SEARCH_LENGTH) {
            throw new \InvalidArgumentException('Search term must be at least ' . self::MIN_SEARCH_LENGTH . ' characters long.');
        }

        if (strlen($search) > self::MAX_SEARCH_LENGTH) {
            throw new \InvalidArgumentException('Search term must not exceed ' . self::MAX_SEARCH_LENGTH . ' characters.');
        }

        return $search;
    }

    /**
     * Normalize a string filter value by trimming and converting to lowercase.
     *
     * @param string|null $value The value to normalize.
     * @return string|null The normalized value, or null if empty.
     */
    public static function normalizeStringFilter(?string $value): ?string
    {
        if (is_null($value) || trim($value) === '') {
            return null;
        }

        return strtolower(trim($value));
    }
}