<?php

namespace App\Service\Dish;

use App\DTO\DishDetailDTO;
use App\Entity\Category;
use App\Entity\Dish;
use App\Helper\MoneyHelper;
use App\Repository\DishRepository;
use App\Helper\PaginationHelper;
use App\Helper\SortingHelper;
use App\Helper\SearchHelper;
use App\Helper\ValidationHelper;
use App\Repository\AllergenRepository;
use App\Repository\CategoryRepository;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class DishService
{
    public function __construct(
        private DishRepository $dishRepository,
        private DishMapper $dishMapper,
        private CategoryRepository $categoryRepository,
        private EntityManagerInterface $entityManager
    ) {}

    public function getFilteredDishes(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        ?string $search,
        mixed $minPrice,
        mixed $maxPrice,
        mixed $available,
        array $ingredients = [],
        ?string $foodStoreId = null,
        array $categories = [],
        bool $onlyActiveStores = true
    ): array {

        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, Dish::ALLOWED_SORT_FIELDS);
        $search = SearchHelper::validate($search);

        if ($minPrice !== null) {
            if (!is_numeric($minPrice) || (float) $minPrice < 0) {
                throw new InvalidArgumentException('Min price must be a valid positive number.');
            }
            $minPrice = MoneyHelper::normalize((float) $minPrice);
        }

        if ($maxPrice !== null) {
            if (!is_numeric($maxPrice) || (float) $maxPrice < 0) {
                throw new InvalidArgumentException('Max price must be a valid positive number.');
            }
            $maxPrice = MoneyHelper::normalize((float) $maxPrice);
        }

        if ($minPrice !== null && $maxPrice !== null && $minPrice > $maxPrice) {
            throw new InvalidArgumentException('Min price cannot be greater than max price.');
        }

        if ($available !== null) {
            $available = filter_var($available, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
        }

        if ($foodStoreId) {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
        }

        $ingredientIds = array_filter($ingredients, fn($id) => ValidationHelper::isCorrectUuid($id));
        $categoryIds = array_filter($categories, fn($id) => ValidationHelper::isCorrectUuid($id));

        $dishes = $this->dishRepository->findFilteredDishes(
            $foodStoreId,
            $search,
            $sortBy,
            $sortOrder,
            $limit,
            $offset,
            $minPrice,
            $maxPrice,
            $ingredientIds,
            $available,
            $categoryIds,
            $onlyActiveStores
        );

        $totalDishes = $this->dishRepository->countFilteredDishes(
            $foodStoreId,
            $search,
            $minPrice,
            $maxPrice,
            $ingredientIds,
            $available,
            $categoryIds,
            $onlyActiveStores
        );

        $dishesDTO = $this->dishMapper->mapToDTOs($dishes);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalDishes, $dishesDTO);
    }

    /**
     * Add a single category to a dish
     */
    public function addDishCategory(string $dishId, string $categoryId, string $foodStoreId): DishDetailDTO
    {
        if (
            !ValidationHelper::isCorrectUuid($dishId) ||
            !ValidationHelper::isCorrectUuid($categoryId) ||
            !ValidationHelper::isCorrectUuid($foodStoreId)
        ) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $dish = $this->dishRepository->findActiveByIdAndStoreId($dishId, $foodStoreId);

        if (!$dish instanceof Dish) {
            throw new NotFoundHttpException('Dish not found');
        }

        $category = $this->categoryRepository->find($categoryId);

        if (!$category instanceof Category) {
            throw new NotFoundHttpException('Category not found');
        }

        $dish->addCategory($category);
        $this->entityManager->flush();
        return $this->dishMapper->mapToDetailDTO($dish);
    }

    /**
     * Remove a category from a dish
     */
    public function removeDishCategory(string $dishId, string $categoryId, string $foodStoreId): DishDetailDTO
    {
        if (
            !ValidationHelper::isCorrectUuid($dishId) ||
            !ValidationHelper::isCorrectUuid($categoryId) ||
            !ValidationHelper::isCorrectUuid($foodStoreId)
        ) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $dish = $this->dishRepository->findActiveByIdAndStoreId($dishId, $foodStoreId);

        if (!$dish instanceof Dish) {
            throw new NotFoundHttpException('Dish not found');
        }

        $category = $this->categoryRepository->find($categoryId);

        if (!$category instanceof Category) {
            throw new NotFoundHttpException('Category not found');
        }

        if (!$dish->getCategories()->contains($category)) {
            throw new NotFoundHttpException('Category not assigned to this dish');
        }

        $dish->removeCategory($category);
        $this->entityManager->flush();
        return $this->dishMapper->mapToDetailDTO($dish);
    }
}
