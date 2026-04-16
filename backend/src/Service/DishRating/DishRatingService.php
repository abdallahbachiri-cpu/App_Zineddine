<?php

namespace App\Service\DishRating;

use App\DTO\DishRatingDTO;
use App\Entity\Dish;
use App\Entity\DishRating;
use App\Entity\Enum\OrderStatus;
use App\Entity\Order;
use App\Entity\OrderDish;
use App\Entity\User;
use App\Helper\ValidationHelper;
use App\Repository\DishRatingRepository;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Repository\DishRepository;
use App\Repository\OrderDishRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use InvalidArgumentException;

class DishRatingService
{
    public function __construct(
        private DishRatingRepository $dishRatingRepository,
        private DishRepository $dishRepository,
        private OrderDishRepository $orderDishRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private DishRatingMapper $dishRatingMapper
    ) {}

    public function getFilteredRatings(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        ?string $search,
        ?string $dishId = null,
        ?string $buyerId = null,
        ?string $orderId = null,
        array $filters = []
    ): array {
        // Validate and normalize inputs
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, DishRating::ALLOWED_SORT_FIELDS);
        $search = SearchHelper::validate($search);

        foreach (['dishId', 'buyerId', 'orderId'] as $idField) {
            if ($$idField && !$this->validationHelper->isCorrectUuid($$idField)) {
                throw new InvalidArgumentException("Invalid UUID format for $idField");
            }
        }

        //search by client email or order number

        // Get filtered ratings from repository
        $ratings = $this->dishRatingRepository->findFilteredRatings(
            $dishId,
            $buyerId,
            $orderId,
            $search,
            $sortBy,
            $sortOrder,
            $limit,
            $offset,
            $filters
        );

        // Get total count for pagination
        $totalRatings = $this->dishRatingRepository->countFilteredRatings(
            $dishId,
            $buyerId,
            $orderId,
            $search,
            $filters
        );

        // Map to DTOs
        $ratingsDTO = $this->dishRatingMapper->mapToDTOs($ratings);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalRatings, $ratingsDTO);
    }

    public function getRatingById(string $id): DishRating
    {
        if (!$this->validationHelper->isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $rating = $this->dishRatingRepository->find($id);
        if (!$rating instanceof DishRating) {
            throw new NotFoundHttpException('Rating not found.');
        }

        return $rating;
    }

    public function getRatingDTOById(string $id): DishRatingDTO
    {
        $rating = $this->getRatingById($id);
        return $this->dishRatingMapper->mapToDTO($rating);
    }

    public function createRating(
        Dish $dish,
        User $buyer,
        Order $order,
        int $ratingValue,
        ?string $comment = null
    ): DishRatingDTO {
        // Validate rating conditions
        $this->validateRatingConditions($dish, $buyer, $order, $ratingValue);

        // Create and persist the rating
        $rating = new DishRating($dish, $buyer, $order, $ratingValue, $comment);
        
        // Validate the entity
        $errors = $this->validator->validate($rating);
        if (count($errors) > 0) {
            throw new InvalidArgumentException((string) $errors);
        }

        $this->entityManager->persist($rating);
        $this->entityManager->flush();

        // Update cached averages
        $this->updateDishRatingStats($dish);

        return $this->dishRatingMapper->mapToDTO($rating);
    }

    public function updateRating(
        DishRating $rating,
        int $newRatingValue,
        ?string $newComment = null
    ): DishRatingDTO {
        if ($newRatingValue < 1 || $newRatingValue > 5) {
            throw new InvalidArgumentException('Rating must be between 1 and 5 stars');
        }

        $originalDish = $rating->getDish();

        // Update the rating
        $rating->setRating($newRatingValue);
        $rating->setComment($newComment);

        // Validate the entity
        $errors = $this->validator->validate($rating);
        if (count($errors) > 0) {
            throw new InvalidArgumentException((string) $errors);
        }

        $this->entityManager->flush();

        // Update cached averages for both old and new dishes if changed
        $this->updateDishRatingStats($originalDish);

        return $this->dishRatingMapper->mapToDTO($rating);
    }

    public function deleteRating(DishRating $rating): void
    {
        $dish = $rating->getDish();
        $this->entityManager->remove($rating);
        $this->entityManager->flush();
        $this->updateDishRatingStats($dish);
    }

    private function validateRatingConditions(
        Dish $dish,
        User $buyer,
        Order $order,
        int $ratingValue
    ): void {
        if ($ratingValue < 1 || $ratingValue > 5) {
            throw new InvalidArgumentException('Rating must be between 1 and 5 stars');
        }

        // Verify user is the order buyer
        if ($buyer->getId() !== $order->getBuyer()->getId()) {
            throw new InvalidArgumentException('Only the order buyer can rate dishes');
        }

        // Verify order contains the dish
        if (!$this->orderDishRepository->orderContainsDish($order, $dish)) {
            throw new InvalidArgumentException('Cannot rate dishes not in this order');
        }

        // Verify order is delivered
        if ($order->getStatus() !== OrderStatus::Completed) {
            throw new InvalidArgumentException('Can only rate dishes from completed orders');
        }

        $existingRating = $this->dishRatingRepository->findOneBy([
            'dish' => $dish,
            'buyer' => $buyer,
            'order' => $order
        ]);

        if ($existingRating instanceof DishRating) {
            throw new InvalidArgumentException('You have already rated this dish from this order');
        }
    }

    private function updateDishRatingStats(Dish $dish): void
    {
        $average = $this->dishRepository->calculateAverageRating($dish);
        $dish->setCachedAverageRating($average);
        $this->entityManager->persist($dish);
        $this->entityManager->flush();
    }
}