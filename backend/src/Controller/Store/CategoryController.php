<?php

namespace App\Controller\Store;


namespace App\Controller;

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
use App\Service\Twilio\TwilioProxyService;
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
class CategoryController extends BaseController
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
        private TwilioProxyService $twilioProxyService,
        private AllergenMapper $allergenMapper,
        private StatisticsService $statisticsService,
        private readonly LoggerInterface $logger,
    ) {
    }

    //categories

    #[Route('/category-types', name: 'categories_types_list', methods: ['GET'])]
    #[OA\Get(
        summary: "Get category types",
        description: "Retrieves a list of all available category types with labels in English and French.",
        tags: ["Seller - Categories"],
        parameters: [
            new OA\Parameter(
                name: "locale",
                in: "query",
                required: false,
                description: "Locale for label (en or fr)",
                schema: new OA\Schema(type: "string", enum: ["en", "fr"], default: "en")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with category types list",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(
                        type: "object",
                        properties: [
                            new OA\Property(property: "value", type: "string", description: "Category type value"),
                            new OA\Property(property: "labelEn", type: "string", description: "English label"),
                            new OA\Property(property: "labelFr", type: "string", description: "French label"),
                            new OA\Property(property: "label", type: "string", description: "Label based on locale")
                        ]
                    )
                )
            )
        ]
    )]
    public function getCategoryTypes(Request $request): JsonResponse
    {
        $locale = $request->query->getString('locale', 'en');
        $types = [];

        foreach (CategoryType::cases() as $type) {
            $types[] = [
                'value' => $type->value,
                'labelEn' => $type->labelEn(),
                'labelFr' => $type->labelFr(),
                'label' => $type->getLabel($locale)
            ];
        }
        return $this->json($types);
    }

    #[Route('/categories', name: 'categories_list', methods: ['GET'])]
    #[OA\Get(
        summary: "Get categories",
        description: "Retrieves a paginated list of categories. Supports filtering by type and search.",
        tags: ["Seller - Categories"],
        parameters: [
            new OA\Parameter(
                name: "page",
                in: "query",
                required: false,
                description: "Page number for pagination",
                schema: new OA\Schema(type: "integer", default: 1, minimum: 1)
            ),
            new OA\Parameter(
                name: "limit",
                in: "query",
                required: false,
                description: "Number of items per page",
                schema: new OA\Schema(type: "integer", default: 20, minimum: 1, maximum: 100)
            ),
            new OA\Parameter(
                name: "sortBy",
                in: "query",
                required: false,
                description: "Field to sort by",
                schema: new OA\Schema(type: "string", default: "createdAt")
            ),
            new OA\Parameter(
                name: "sortOrder",
                in: "query",
                required: false,
                description: "Sort order (asc or desc)",
                schema: new OA\Schema(type: "string", enum: ["asc", "desc"], default: "desc")
            ),
            new OA\Parameter(
                name: "search",
                in: "query",
                required: false,
                description: "Search term to filter categories",
                schema: new OA\Schema(type: "string")
            ),
            new OA\Parameter(
                name: "type",
                in: "query",
                required: false,
                description: "Filter by category type",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated category list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: "#/components/schemas/CategoryDTO")
                        ),
                        new OA\Property(property: "page", type: "integer", description: "Current page number"),
                        new OA\Property(property: "limit", type: "integer", description: "Items per page"),
                        new OA\Property(property: "total", type: "integer", description: "Total number of items"),
                        new OA\Property(property: "totalPages", type: "integer", description: "Total number of pages")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid query parameters")
        ]
    )]
    public function getCategories(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);
            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);
            $search = $request->query->getString('search', '') ?: null;
            $type = $request->query->getString('type', '') ?: null;

            $data = $this->categoryService->getAllCategories(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $type
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/allergens', name: 'allergens_list', methods: ['GET'])]
    #[OA\Get(
        summary: "Get allergens",
        description: "Retrieves a list of all allergens. Supports search filtering.",
        tags: ["Seller - Allergens"],
        parameters: [
            new OA\Parameter(
                name: "search",
                in: "query",
                required: false,
                description: "Search term to filter allergens",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with allergen list",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: new Model(type: AllergenDTO::class))
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid query parameters")
        ]
    )]
    public function getAllergens(Request $request): JsonResponse
    {
        try {
            $search = $request->query->getString('search', '') ?: null;
            $allergens = $this->allergenRepository->findAllWithSearch($search);

            $allergensDTOs = $this->allergenMapper->mapToDTOs($allergens);

            return $this->json($allergensDTOs, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/categories/{id}', name: 'get_category', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a specific category",
        description: "Retrieves details of a specific category by ID.",
        tags: ["Seller - Categories"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the category",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with category details",
                content: new OA\JsonContent(ref: "#/components/schemas/CategoryDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid category ID",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid category ID format")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Category not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Category not found")
                    ]
                )
            )
        ]
    )]
    public function getCategory(string $id): JsonResponse
    {
        try {
            $categoryDTO = $this->categoryService->getCategoryDTOById($id);
            return $this->json($categoryDTO, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }


}
