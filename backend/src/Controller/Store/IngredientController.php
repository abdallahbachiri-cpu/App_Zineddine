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
class IngredientController extends BaseController
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

    #[Route('/food-store/ingredients', name: 'get_food_store_ingredients', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store ingredients",
        description: "Retrieves a paginated list of ingredients for the authenticated seller's food store. Supports filtering and sorting.",
        tags: ["Seller - Food Store - Ingredients"],
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
                description: "Search term to filter ingredients by name",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated ingredient list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            // items: new OA\Items(ref: "#/components/schemas/IngredientDTO")
                            items: new OA\Items(ref: new Model(type: IngredientDTO::class, groups: ["default"]))
                        ),
                        new OA\Property(property: "page", type: "integer", description: "Current page number"),
                        new OA\Property(property: "limit", type: "integer", description: "Items per page"),
                        new OA\Property(property: "total", type: "integer", description: "Total number of items"),
                        new OA\Property(property: "totalPages", type: "integer", description: "Total number of pages")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid query parameters"),
            new OA\Response(response: 404, description: "Food store not found")
        ]
    )]
    public function getFoodStoreIngredients(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);
            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);
            $search = $request->query->getString('search', '') ?: null;

            $data = $this->ingredientService->getIngredientsByFoodStore(
                $foodStore,
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search
            );

            return $this->json($data);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/food-store/ingredients', name: 'create_food_store_ingredient', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a new ingredient",
        description: "Creates a new ingredient for the authenticated seller's food store.",
        tags: ["Seller - Food Store - Ingredients"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "nameFr",
                        type: "string",
                        description: "French name of the ingredient",
                        example: "Tomate",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "nameEn",
                        type: "string",
                        description: "English name of the ingredient",
                        example: "Tomato",
                        maxLength: 255
                    )
                ],
                required: ["nameFr", "nameEn"]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Ingredient created successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/IngredientDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Validation errors",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string")
                        )
                    ]
                )
            ),
            new OA\Response(response: 404, description: "Food store not found")
        ]
    )]
    public function createFoodStoreIngredient(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        $constraints = new Assert\Collection([
            'fields' => [
                'nameFr' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['max' => 255]),
                ],
                'nameEn' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['max' => 255]),
                ]
            ],
            'allowExtraFields' => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = new Ingredient();
        $ingredient->setNameFr($data['nameFr'])
            ->setNameEn($data['nameEn'])
            ->setFoodStore($foodStore);

        $this->entityManager->persist($ingredient);
        $this->entityManager->flush();

        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);

        return $this->json(
            $ingredientDTO,
            JsonResponse::HTTP_CREATED
        );
    }

    #[Route('/food-store/ingredients/{id}', name: 'get_food_store_ingredient', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a specific ingredient",
        description: "Retrieves details of a specific ingredient from the authenticated seller's food store.",
        tags: ["Seller - Food Store - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the ingredient",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with ingredient details",
                content: new OA\JsonContent(ref: "#/components/schemas/IngredientDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Invalid UUID format",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Ingredient or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Ingredient not found.")
                    ]
                )
            )
        ]
    )]
    public function getFoodStoreIngredient(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($id)) {
            return $this->json(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = $this->ingredientRepository->findOneBy([
            'id' => $id,
            'foodStore' => $foodStore
        ]);

        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }
        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);
        return $this->json($ingredientDTO);
    }

    #[Route('/food-store/ingredients/{id}', name: 'update_food_store_ingredient', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update an ingredient",
        description: "Updates an ingredient in the authenticated seller's food store. Only provided fields will be updated.",
        tags: ["Seller - Food Store - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the ingredient to update",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "nameFr",
                        type: "string",
                        nullable: true,
                        description: "French name of the ingredient",
                        example: "Tomate",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "nameEn",
                        type: "string",
                        nullable: true,
                        description: "English name of the ingredient",
                        example: "Tomato",
                        maxLength: 255
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Ingredient updated successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/IngredientDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Validation errors or invalid UUID",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string")
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Ingredient or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Ingredient not found.")
                    ]
                )
            )
        ]
    )]
    public function updateFoodStoreIngredient(string $id, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($id)) {
            return $this->json(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = $this->ingredientRepository->findOneBy([
            'id' => $id,
            'foodStore' => $foodStore
        ]);

        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        $constraints = new Assert\Collection([
            'fields' => [
                'nameFr' => new Assert\Optional([
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['max' => 255]),
                ]),
                'nameEn' => new Assert\Optional([
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['max' => 255]),
                ])
            ],
            'allowExtraFields' => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['nameFr'])) {
            $ingredient->setNameFr($data['nameFr']);
        }

        if (isset($data['nameEn'])) {
            $ingredient->setNameEn($data['nameEn']);
        }

        $this->entityManager->flush();

        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);
        return $this->json($ingredientDTO);
    }

    #[Route('/food-store/ingredients/{id}', name: 'delete_food_store_ingredient', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete an ingredient",
        description: "Deletes an ingredient from the authenticated seller's food store. The ingredient cannot be deleted if it is used in any dishes.",
        tags: ["Seller - Food Store - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the ingredient to delete",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Ingredient deleted successfully"
            ),
            new OA\Response(
                response: 400,
                description: "Invalid UUID format",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Ingredient or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Ingredient not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Ingredient is used in dishes",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Cannot delete ingredient as it is used in one or more dishes"
                        )
                    ]
                )
            )
        ]
    )]
    public function deleteFoodStoreIngredient(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($id)) {
            return $this->json(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = $this->ingredientRepository->findOneBy([
            'id' => $id,
            'foodStore' => $foodStore
        ]);

        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if ($ingredient->getDishIngredients()->count() > 0) {
            return $this->json(
                ['error' => 'Cannot delete ingredient as it is used in one or more dishes'],
                JsonResponse::HTTP_CONFLICT
            );
        }

        $this->entityManager->remove($ingredient);
        $this->entityManager->flush();

        return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
    }

    #[Route('/food-store/dishes/{id}/ingredients', name: 'get_dish_ingredients', methods: ['GET'])]
    #[OA\Get(
        summary: "Get ingredients of a dish",
        description: "Retrieves the list of ingredients assigned to a specific dish within the authenticated user's food store.",
        tags: ["Seller - Food Store - Dishes - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with a list of dish ingredients",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: "#/components/schemas/DishIngredientDTO")
                )
            ),
            new OA\Response(
                response: 400,
                description: "Invalid dish ID format (must be a UUID)",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid ID format. Expected a UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found or does not belong to the user's food store",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function getDishIngredients(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveById($id);

        if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
            return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dishIngredients = $this->dishIngredientRepository->findBy(['dish' => $dish]);
        $dishIngredientsDTOs = $this->dishIngredientMapper->mapToDTOs($dishIngredients);

        return $this->json($dishIngredientsDTOs, Response::HTTP_OK);
    }

    #[Route('/food-store/dishes/{id}/ingredients', name: 'add_dish_ingredient', methods: ['POST'])]
    #[OA\Post(
        summary: "Add an ingredient to a dish",
        description: "Assigns an ingredient to a specific dish within the authenticated user's food store. If `isSupplement` is `false`, the `price` will be automatically set to `0`.",
        tags: ["Seller - Food Store - Dishes - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Payload for assigning an ingredient to a dish",
            content: new OA\JsonContent(
                type: "object",
                required: ["ingredientId"],
                properties: [
                    new OA\Property(property: "ingredientId", type: "string", format: "uuid", description: "The ID of the ingredient"),
                    new OA\Property(
                        property: "price",
                        type: "number",
                        format: "float",
                        default: 0,
                        description: "The price associated with the ingredient. Always non-negative. If `isSupplement` is `false`, this will be automatically set to `0`."
                    ),
                    new OA\Property(
                        property: "isSupplement",
                        type: "boolean",
                        default: false,
                        description: "Whether the ingredient is an optional supplement. If `false`, `price` will always be `0`."
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Ingredient successfully assigned to the dish",
                content: new OA\JsonContent(ref: "#/components/schemas/DishIngredientDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid payload or validation errors",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Ingredient ID is required and should be a valid UUID."),
                        new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish or ingredient not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Ingredient is already assigned to the dish",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Ingredient is already assigned to this dish.")
                    ]
                )
            )
        ]
    )]
    public function addDishIngredient(string $id, Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveById($id);

        if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
            return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!isset($data['ingredientId'])) {
            return $this->json(['error' => 'Ingredient ID is required.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            "fields" => [
                'ingredientId' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                ],
                'price' => new Assert\Optional([
                    new Assert\Type('numeric'),
                    new Assert\PositiveOrZero()
                ]),
                'isSupplement' => new Assert\Optional([
                    new Assert\Type('bool')
                ])
            ],
            "allowMissingFields" => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (!ValidationHelper::isCorrectUuid($data['ingredientId'])) {
            return new JsonResponse(['error' => 'Invalid ingredientId UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = $this->ingredientRepository->find($data['ingredientId']);

        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        // Check if the ingredient is already assigned to the dish
        // foreach ($dish->getDishIngredients() as $dishIngredient) {
        //     if ($dishIngredient->getIngredient() === $ingredient) {
        //         return $this->json(['error' => 'Ingredient is already assigned to this dish.'], JsonResponse::HTTP_CONFLICT);
        //     }
        // }
        $existingDishIngredient = $this->dishIngredientRepository
            ->findOneBy([
                'dish' => $dish,
                'ingredient' => $ingredient
            ]);

        if ($existingDishIngredient instanceof DishIngredient) {
            return $this->json(['error' => 'Ingredient is already assigned to this dish.'], JsonResponse::HTTP_CONFLICT);
        }

        $dishIngredient = new DishIngredient();
        $dishIngredient->setDish($dish)
            ->setIngredient($ingredient)
            ->setIsSupplement($data['isSupplement'] ?? false)
            ->setPrice($data['price'] ?? 0);

        $this->entityManager->persist($dishIngredient);
        $this->entityManager->flush();

        $dishIngredientDTO = $this->dishIngredientMapper->mapToDTO($dishIngredient);
        return $this->json($dishIngredientDTO, JsonResponse::HTTP_CREATED);
    }

    #[Route('/food-store/dishes/{dishId}/ingredients/{ingredientId}', name: 'update_dish_ingredient', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a dish ingredient",
        description: "Updates the properties of an ingredient assigned to a specific dish. If `isSupplement` is set to `false`, the `price` will be automatically set to `0`.",
        tags: ["Seller - Food Store - Dishes - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "ingredientId",
                in: "path",
                required: true,
                description: "The ID of the ingredient",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Payload for updating the dish ingredient",
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "price",
                        type: "number",
                        format: "float",
                        description: "The price of the ingredient. Always non-negative. If `isSupplement` is `false`, this will be automatically set to `0`.",
                        example: 4.99
                    ),
                    new OA\Property(
                        property: "isSupplement",
                        type: "boolean",
                        description: "Indicates whether the ingredient is an optional supplement. If `false`, `price` will be reset to `0`."
                    ),
                    new OA\Property(
                        property: "available",
                        type: "boolean",
                        description: "Indicates whether the ingredient is currently available for selection."
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Ingredient successfully updated",
                content: new OA\JsonContent(ref: "#/components/schemas/DishIngredientDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid payload or validation errors",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish or ingredient not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function updateDishIngredient(string $dishId, string $ingredientId, Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveById($dishId);
        if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
            return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $ingredient = $this->ingredientRepository->find($ingredientId);
        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dishIngredient = $this->dishIngredientRepository->findOneBy([
            'dish' => $dish,
            'ingredient' => $ingredient
        ]);

        if (!$dishIngredient instanceof DishIngredient) {
            return $this->json(['message' => 'Dish ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $constraints = new Assert\Collection([
            "fields" => [
                'price' => new Assert\Optional([
                    new Assert\Type('numeric'),
                    new Assert\PositiveOrZero()
                ]),
                'isSupplement' => new Assert\Optional([
                    new Assert\Type('bool')
                ]),
                'available' => new Assert\Optional([
                    new Assert\Type('bool')
                ])
            ],
            "allowMissingFields" => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['isSupplement'])) {
            $dishIngredient->setIsSupplement($data['isSupplement']);
        }

        if (isset($data['price'])) {
            $dishIngredient->setPrice($data['price']);
        }

        if (isset($data['available'])) {
            $dishIngredient->setAvailable($data['available']);
        }

        $this->entityManager->flush();

        $dishIngredientDTO = $this->dishIngredientMapper->mapToDTO($dishIngredient);

        return $this->json($dishIngredientDTO, JsonResponse::HTTP_OK);
    }

    #[Route('/food-store/dishes/{dishId}/ingredients/{ingredientId}', name: 'remove_dish_ingredient', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove an ingredient from a dish",
        description: "Deletes the association between a dish and an ingredient, effectively removing the ingredient from the dish.",
        tags: ["Seller - Food Store - Dishes - Ingredients"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "ingredientId",
                in: "path",
                required: true,
                description: "The ID of the ingredient",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Ingredient successfully removed from the dish"
            ),
            new OA\Response(
                response: 400,
                description: "Invalid dish or ingredient ID format (must be a UUID)",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid ID format. Expected a UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish, ingredient, or dish-ingredient association not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function removeDishIngredient(string $dishId, string $ingredientId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveById($dishId);
        if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
            return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $ingredient = $this->ingredientRepository->find($ingredientId);
        if (!$ingredient instanceof Ingredient) {
            return $this->json(['message' => 'Ingredient not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dishIngredient = $this->dishIngredientRepository->findOneBy([
            'dish' => $dish,
            'ingredient' => $ingredient
        ]);

        if (!$dishIngredient instanceof DishIngredient) {
            return $this->json(['message' => 'Ingredient is not assigned to this dish.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $this->entityManager->remove($dishIngredient);
        $this->entityManager->flush();

        return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
    }

    // get orders, get single order (to be copied from buyerController after documentation)
}
