<?php

namespace App\Controller\Store;

use App\Controller\Abstract\BaseController;
use App\DTO\AllergenDTO;
use App\DTO\CategoryDTO;
use App\DTO\DishDTO;
use App\DTO\DishIngredientDTO;
use App\DTO\DishRatingDTO;
use App\DTO\FoodStoreDTO;
use App\DTO\FoodStoreVerificationRequestDTO;
use App\DTO\IngredientDTO;
use App\DTO\LocationDTO;
use App\DTO\OrderDTO;
use App\DTO\OrderDetailDTO;
use App\DTO\UserDTO;
use App\DTO\WalletDTO;
use App\DTO\WalletTransactionDTO;
use App\Entity\Allergen;
use App\Entity\Dish;
use App\Entity\DishAllergen;
use App\Entity\DishIngredient;
use App\Entity\Enum\OrderDeliveryStatus;
use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\OrderStatus;
use App\Entity\Enum\StoreVerificationStatus;
use App\Entity\FoodStore;
use App\Entity\Ingredient;
use App\Entity\Media;
use App\Entity\Order;
use App\Entity\User;
use App\Entity\Wallet;
use App\Exception\ValidationException;
use App\Helper\PaginationHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\AllergenRepository;
use App\Repository\DishIngredientRepository;
use App\Repository\DishRepository;
use App\Repository\FoodStoreRepository;
use App\Repository\FoodStoreVerificationRequestRepository;
use App\Repository\IngredientRepository;
use App\Repository\MediaRepository;
use App\Service\Dish\DishMapper;
use App\Service\DishIngredient\DishIngredientMapper;
use App\Service\FoodStore\FoodStoreMapper;
use App\Service\Ingredient\IngredientService;
use App\Service\Location\LocationService;
use App\Service\Media\MediaService;
use App\Service\Order\OrderMapper;
use App\Service\Order\OrderService;
use App\Service\User\UserMapper;
use App\Service\User\UserService;
use App\Service\Wallet\WalletService;
use App\Entity\FoodStoreVerificationRequest;
use App\Entity\Enum\CategoryType;
use App\Entity\Enum\StoreDeliveryOption;
use App\Entity\Enum\StoreType;
use App\Repository\DishAllergenRepository;
use App\Repository\WalletTransactionRepository;
use App\Service\BankAccount\BankAccountMapper;
use App\Service\Allergen\AllergenMapper;
use App\Service\Category\CategoryService;
use App\Service\Dish\DishService;
use App\Service\DishAllergen\DishAllergenMapper;
use App\Service\DishRating\DishRatingMapper;
use App\Service\DishRating\DishRatingService;
use App\Service\FoodStore\FoodStoreVerificationRequestMapper;
use App\Service\FoodStore\FoodStoreVerificationService;
use App\Service\Ingredient\IngredientMapper;
use App\Service\Statistics\StatisticsService;
use App\Service\Stripe\StripeService;
use App\Service\Wallet\WalletMapper;
use App\Service\Wallet\WalletTransaction\WalletTransactionMapper;
use Doctrine\DBAL\Exception\ForeignKeyConstraintViolationException;
use Doctrine\ORM\EntityManagerInterface;
use DomainException;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\Exception\BadRequestException;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Psr\Log\LoggerInterface;
use Stripe\Exception\ApiErrorException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

#[Route('/api/seller', name: 'seller_')]
class AnalyticsController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private DishRepository $dishRepository,
        private FoodStoreRepository $foodStoreRepository,
        private MediaRepository $mediaRepository,
        private IngredientRepository $ingredientRepository,
        private AllergenRepository $allergenRepository,
        private DishAllergenRepository $dishAllergenRepository,
        private DishAllergenMapper $dishAllergenMapper,
        private DishIngredientRepository $dishIngredientRepository,
        private UserMapper $userMapper,
        private FoodStoreMapper $foodStoreMapper,
        private DishMapper $dishMapper,
        private IngredientService $ingredientService,
        private LocationService $locationService,
        private DishIngredientMapper $dishIngredientMapper,
        private UserService $userService,
        private MediaService $mediaService,
        private OrderMapper $orderMapper,
        private OrderService $orderService,
        private WalletService $walletService,
        private FoodStoreVerificationRequestRepository $foodStoreVerificationRequestRepository,
        private FoodStoreVerificationRequestMapper $foodStoreVerificationRequestMapper,
        private FoodStoreVerificationService $foodStoreVerificationService,
        private CategoryService $categoryService,
        private DishService $dishService,
        private DishRatingService $dishRatingService,
        private WalletMapper $walletMapper,
        private WalletTransactionRepository $walletTransactionRepository,
        private WalletTransactionMapper $walletTransactionMapper,
        private StripeService $stripeService,
        private IngredientMapper $ingredientMapper,
        private AllergenMapper $allergenMapper,
        private StatisticsService $statisticsService,
        private readonly LoggerInterface $logger,
    ) {
    }

    #[Route('/stats', name: 'get_basic_stats', methods: ['GET'])]
    #[OA\Get(
        summary: "Get basic statistics",
        description: "Retrieves basic statistics for the authenticated seller including total orders, pending orders, and total revenue from completed orders.",
        tags: ["Seller - Statistics"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with basic statistics",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "totalOrders", type: "integer", description: "Total number of orders"),
                        new OA\Property(property: "totalPendingOrders", type: "integer", description: "Number of pending orders"),
                        new OA\Property(property: "totalRevenue", type: "string", description: "Total revenue as a decimal string")
                    ],
                    example: [
                        "totalOrders" => 45,
                        "totalPendingOrders" => 3,
                        "totalRevenue" => "12847.50"
                    ]
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 500, description: "Internal server error")
        ]
    )]
    public function getBasicStats(): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }
            $stats = $this->statisticsService->getBasicStatistics($user);

            return $this->json($stats);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/stats/revenue/{year}/{month}', name: 'get_revenue_by_day', methods: ['GET'])]
    #[OA\Get(
        summary: "Get revenue by day",
        description: "Retrieves revenue statistics grouped by day for a specific month and year. Revenue is calculated from completed orders.",
        tags: ["Seller - Statistics"],
        parameters: [
            new OA\Parameter(
                name: "year",
                in: "path",
                required: true,
                description: "The year (must be between 1900 and 2200)",
                schema: new OA\Schema(type: "integer")
            ),
            new OA\Parameter(
                name: "month",
                in: "path",
                required: true,
                description: "The month (1-12)",
                schema: new OA\Schema(type: "integer", minimum: 1, maximum: 12)
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with revenue by day",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "year", type: "integer"),
                        new OA\Property(property: "month", type: "integer"),
                        new OA\Property(property: "revenueByDay", type: "object", description: "Revenue keyed by day (1-31), values are decimal strings")
                    ],
                    example: [
                        "year" => 2025,
                        "month" => 12,
                        "revenueByDay" => [
                            "1" => "1250.75",
                            "2" => "2100.50",
                            "3" => "1875.25",
                            "4" => "0.00",
                            "5" => "3200.00",
                            "11" => "5629.99"
                        ]
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid year or month"),
            new OA\Response(response: 404, description: "User not found")
        ]
    )]
    public function getRevenueByDay(int $year, int $month): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $revenueByDay = $this->statisticsService->getRevenueByDayForMonth($user, $year, $month);

            return $this->json([
                'year' => $year,
                'month' => $month,
                'revenueByDay' => $revenueByDay
            ]);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/stats/revenue/{year}', name: 'get_revenue_by_month', methods: ['GET'])]
    #[OA\Get(
        summary: "Get revenue by month",
        description: "Retrieves revenue statistics grouped by month for a specific year. Revenue is calculated from completed orders.",
        tags: ["Seller - Statistics"],
        parameters: [
            new OA\Parameter(
                name: "year",
                in: "path",
                required: true,
                description: "The year (must be between 1900 and 2200)",
                schema: new OA\Schema(type: "integer")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with revenue by month",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "year", type: "integer"),
                        new OA\Property(property: "revenueByMonth", type: "object", description: "Revenue keyed by month (1-12), values are decimal strings")
                    ],
                    example: [
                        "year" => 2025,
                        "revenueByMonth" => [
                            "1" => "15230.50",
                            "2" => "12450.75",
                            "3" => "18920.00",
                            "4" => "0.00",
                            "5" => "22150.25",
                            "11" => "25680.99",
                            "12" => "19345.60"
                        ]
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid year"),
            new OA\Response(response: 404, description: "User not found")
        ]
    )]
    public function getRevenueByMonth(int $year): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $revenueByMonth = $this->statisticsService->getRevenueByMonthForYear($user, $year);

            return $this->json([
                'year' => $year,
                'revenueByMonth' => $revenueByMonth
            ]);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/stats/revenue', name: 'get_revenue_by_year', methods: ['GET'])]
    #[OA\Get(
        summary: "Get revenue by year",
        description: "Retrieves aggregated revenue statistics grouped by year for all time. Revenue is calculated from completed orders.",
        tags: ["Seller - Statistics"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with revenue by year",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "revenueByYear", type: "object", description: "Revenue keyed by year, values are decimal strings")
                    ],
                    example: [
                        "revenueByYear" => [
                            "2023" => "125680.50",
                            "2024" => "185420.75",
                            "2025" => "98765.30"
                        ]
                    ]
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 500, description: "Internal server error")
        ]
    )]
    public function getRevenueByYear(): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $revenueByYear = $this->statisticsService->getRevenueByYear($user);

            return $this->json([
                'revenueByYear' => $revenueByYear
            ]);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/food-store/vendor-agreement/accept', name: 'food_store_accept_vendor_agreement', methods: ['POST'])]
    #[OA\Post(
        summary: "Accept vendor agreement",
        description: "Accepts the vendor agreement for the authenticated seller's food store. Once accepted, the agreement cannot be un-accepted. Records the acceptance timestamp.",
        tags: ["Seller - Food Store - Vendor Agreement"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Vendor agreement accepted successfully",
                content: new OA\JsonContent(ref: new Model(type: FoodStoreDTO::class, groups: ['output']))
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Vendor agreement already accepted",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Vendor agreement already accepted.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "An unexpected error occurred")
                    ]
                )
            )
        ]
    )]
    public function acceptVendorAgreement(): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if ($foodStore->isVendorAgreementAccepted()) {
                return $this->json(['message' => 'Vendor agreement already accepted.'], JsonResponse::HTTP_CONFLICT);
            }
            $foodStore->setVendorAgreementAccepted(true);
            $foodStore->setVendorAgreementAcceptedAt(new \DateTimeImmutable());
            $this->entityManager->persist($foodStore);

            $this->entityManager->flush();

            $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

            return $this->json($foodStoreDto, JsonResponse::HTTP_OK);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
