<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use App\DTO\CategoryDTO;
use App\DTO\DishDTO;
use App\DTO\DishDetailDTO;
use App\DTO\DishRatingDTO;
use App\DTO\FoodStoreDTO;
use App\DTO\FoodStoreVerificationRequestDTO;
use App\DTO\IngredientDTO;
use App\DTO\OrderDTO;
use App\DTO\OrderDetailDTO;
use App\DTO\PayoutConfigDTO;
use App\DTO\WalletDTO;
use App\DTO\WalletTransactionDTO;
use App\Entity\Dish;
use App\Entity\FoodStore;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use App\Helper\PaginationHelper;
use App\Helper\SortingHelper;
use App\Repository\DishRepository;
use App\Repository\FoodStoreRepository;
use App\Service\Dish\DishMapper;
use App\Service\Dish\DishService;
use App\Service\FoodStore\FoodStoreMapper;
use App\Service\FoodStore\FoodStoreService;
use App\Service\Ingredient\IngredientService;
use App\Service\User\UserService;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\Exception\BadRequestException;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use OpenApi\Attributes as OA;
use App\DTO\UserDTO;
use App\Entity\Enum\OrderDeliveryStatus;
use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\OrderStatus;
use App\Entity\Enum\StoreVerificationStatus;
use App\Entity\FoodStoreVerificationRequest;
use App\Entity\Media;
use App\Entity\Order;
use App\Entity\User;
use App\Entity\Enum\CategoryType;
use App\Entity\PayoutConfiguration;
use App\Entity\Wallet;
use App\Exception\ValidationException;
use App\Helper\MoneyHelper;
use App\Helper\ValidationHelper;
use App\Repository\FoodStoreVerificationRequestRepository;
use App\Repository\PayoutConfigurationRepository;
use App\Repository\WalletTransactionRepository;
use App\Service\Category\CategoryService;
use App\Service\DishRating\DishRatingMapper;
use App\Service\DishRating\DishRatingService;
use App\Service\FoodStore\FoodStoreVerificationRequestMapper;
use App\Service\FoodStore\FoodStoreVerificationService;
use App\Service\Media\MediaService;
use App\Service\Order\OrderMapper;
use App\Service\Order\OrderService;
use App\Service\Payout\PayoutConfigMapper;
use App\Service\Statistics\StatisticsService;
use App\Service\Twilio\TwilioProxyService;
use App\Service\Wallet\WalletMapper;
use App\Service\Wallet\WalletService;
use App\Service\Wallet\WalletTransaction\WalletTransactionMapper;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityNotFoundException;
use DomainException;
use Google\Service\BeyondCorp\Resource\V;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;

#[Route('/api/admin', name: 'admin_')]
class AdminController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private UserService $userService,
        private IngredientService $ingredientService,
        private FoodStoreService $foodStoreService,
        private FoodStoreMapper $foodStoreMapper,
        private FoodStoreRepository $foodStoreRepository,
        private DishService $dishService,
        private DishMapper $dishMapper,
        private DishRepository $dishRepository,
        private FoodStoreVerificationService $foodStoreVerificationService,
        private FoodStoreVerificationRequestRepository $foodStoreVerificationRequestRepository,
        private FoodStoreVerificationRequestMapper $foodStoreVerificationRequestMapper,
        private MediaService $mediaService,
        private OrderService $orderService,
        private OrderMapper $orderMapper,
        private CategoryService $categoryService,
        private DishRatingService $dishRatingService,
        private DishRatingMapper $dishRatingMapper,
        private WalletMapper $walletMapper,
        private WalletService $walletService,
        private WalletTransactionRepository $walletTransactionRepository,
        private WalletTransactionMapper $walletTransactionMapper,
        private PayoutConfigurationRepository $payoutConfigurationRepository,
        private PayoutConfigMapper $payoutConfigMapper,
        private StatisticsService $statisticsService,
        private TwilioProxyService $twilioProxyService
    ) {}


    #[Route('/users/admin', name: 'create_admin_user', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a new admin user",
        description: "Creates a new administrator account. Validates email, password strength, name fields, and optional locale.",
        tags: ["Admin - Users"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Admin user creation payload",
            content: new OA\JsonContent(
                required: ["email", "password", "firstName", "lastName"],
                properties: [
                    new OA\Property(
                        property: "email",
                        type: "string",
                        format: "email",
                        example: "admin@example.com",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "password",
                        type: "string",
                        format: "password",
                        example: "Admin@1234",
                        minLength: 8,
                        description: "Must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
                    ),
                    new OA\Property(
                        property: "firstName",
                        type: "string",
                        example: "John",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "lastName",
                        type: "string",
                        example: "Doe",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "locale",
                        type: "string",
                        enum: ["en", "fr"],
                        example: "en",
                        nullable: true
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Admin user successfully created",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(
                response: 400,
                description: "Validation error",
                content: new OA\JsonContent(
                    example: [
                        "errors" => [
                            "email" => ["This value should not be blank."],
                            "password" => ["This value is too short."]
                        ]
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Email already exists",
                content: new OA\JsonContent(
                    example: [
                        "errors" => ["An account with this email already exists."]
                    ]
                )
            )
        ]
    )]
    public function createAdminUser(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(
                ['error' => 'Invalid request payload.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        return $this->userService->createAdminUser($data);
    }

    //users management
    #[Route('/users', name: 'get_users', methods: ['GET'])]
    #[OA\Get(
        summary: "Get all users",
        description: "Fetches a paginated list of users with sorting and filtering options.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default value is used if not entered)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'createdAt', 'updatedAt') (optional)", schema: new OA\Schema(type: "string", default: 'createdAt')),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc) (optional)", schema: new OA\Schema(type: "string", default: 'DESC')),
            new OA\Parameter(name: "search", in: "query", description: "Search term (optional)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "type", in: "query", description: "Filter by user type (buyer, seller, admin) (optional)", schema: new OA\Schema(type: "string")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated data",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: UserDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters"),
        ]
    )]
    public function getAllUsers(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;
            $userType = $request->query->getString('type', '') ?: null;

            $data = $this->userService->getAllUsers($page, $limit, $sortBy, $sortOrder, $search, $userType);
            return $this->json($data);
        } catch (InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    // #[Route('/users/available', name: 'get_available', methods: ['GET'])]
    // public function getAvailableUsers(Request $request): JsonResponse
    // {
    //     $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
    //     $page = $request->query->getInt('page', 1);

    //     $search = $request->query->getString('search', '') ?: null;

    //     $data = $this->userService->getAvailableUsers($page, $limit);

    //     return $this->json($data);
    // }


    #[Route('/users/{id}', name: 'get_user', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a user by ID",
        description: "Fetches a user by their unique identifier.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the user",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with user data",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid ID format"),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function getUserById(string $id): JsonResponse
    {
        try {
            $userDTO = $this->userService->getUserById($id);

            if ($userDTO === null) {
                return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
            }

            return $this->json($userDTO);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/users/{id}', name: 'update', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a user by ID",
        description: "Updates a user's details based on their unique identifier.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the user",
                schema: new OA\Schema(type: "string")
            )
        ],
        requestBody: new OA\RequestBody(
            required: false,
            description: "User update payload (only provided fields will be updated)",
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "phoneNumber",
                        type: "string",
                        nullable: true,
                        description: "Phone number in international format (optional)",
                        example: "+1234567890",
                        pattern: "^\\+?[0-9]+$"
                    ),
                    new OA\Property(
                        property: "email",
                        type: "string",
                        format: "email",
                        nullable: true,
                        description: "Valid email address (optional)",
                        example: "user@example.com",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "firstName",
                        type: "string",
                        nullable: true,
                        description: "User's first name (optional)",
                        example: "John",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "lastName",
                        type: "string",
                        nullable: true,
                        description: "User's last name (optional)",
                        example: "Doe",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "middleName",
                        type: "string",
                        nullable: true,
                        description: "User's middle name (optional)",
                        example: "Michael",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "type",
                        type: "string",
                        nullable: true,
                        description: "User type (optional)",
                        example: "seller",
                        enum: ['seller', 'buyer']
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with updated user data",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid request payload or ID format"),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 422, description: "Unprocessable entity - Business logic validation failed"),
        ]
    )]
    public function updateUser(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);

            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            return $this->userService->updateUser($id, $data);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (DomainException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_UNPROCESSABLE_ENTITY);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/users/{id}', name: 'delete', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete a user by ID",
        description: "Soft deletes the authenticated user account. The account is marked as deleted but not removed from the database.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the user",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "User successfully deleted",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "User has been deleted")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid id format"),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function deleteUser(string $id): JsonResponse
    {
        try {
            return $this->userService->softDeleteUser($id);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/users/{id}/restore', name: 'restore', methods: ['POST'])]
    #[OA\Post(
        summary: "Restore a deleted user",
        description: "Restores a user who was previously deleted, allowing them to access their account again.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the user",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "User successfully restored",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "User has been restored")
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format"
            ),
            new OA\Response(
                response: 404,
                description: "User not found"
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - User is not deleted"
            )
        ]
    )]
    public function restoreUser(string $id): JsonResponse
    {
        try {
            return $this->userService->restoreUser($id);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        }
    }

    #[Route('/users/{id}/activate', name: 'activate', methods: ['POST'])]
    #[OA\Post(
        summary: "Activate a suspended user",
        description: "Reactivates a suspended user account by their unique identifier.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the suspended user",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "User successfully reactivated",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "User has been activated")
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format"
            ),
            new OA\Response(
                response: 404,
                description: "User not found"
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - User is already active"
            )
        ]
    )]
    public function activateUser(string $id): JsonResponse
    {
        try {
            return $this->userService->activateUser($id);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        }
    }

    #[Route('/users/{id}/suspend', name: 'suspend', methods: ['POST'])]
    #[OA\Post(
        summary: "Suspend a user",
        description: "Suspends a user by their ID.",
        tags: ["Admin - Users"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the user",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "User successfully suspended",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "User has been suspended")
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid ID format or request parameters"
            ),
            new OA\Response(
                response: 404,
                description: "User not found"
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - User is already suspended"
            )
        ]
    )]
    public function suspendUser(string $id): JsonResponse
    {
        try {
            return $this->userService->suspendUser($id);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        }
    }

    //ingredients management
    // #[Route('/ingredients', name: 'get_all_ingredients', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Get all ingredients",
    //     description: "Fetches a paginated list of ingredients with sorting and filtering options.",
    //     tags: ["Admin - Ingredients"],
    //     parameters: [
    //         new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default value is used if not entered)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
    //         new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
    //         new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'nameEn', 'nameFr', 'createdAt', 'updatedAt') (optional)", schema: new OA\Schema(type: "string", default: 'createdAt')),
    //         new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc) (optional)", schema: new OA\Schema(type: "string", default: 'DESC')),
    //         new OA\Parameter(name: "search", in: "query", description: "Search term (optional)", schema: new OA\Schema(type: "string"))
    //     ],
    //     responses: [
    //         new OA\Response(
    //             response: 200,
    //             description: "Successful response with paginated data",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "current_page", type: "integer", default: 1),
    //                     new OA\Property(property: "limit", type: "integer", default: 50),
    //                     new OA\Property(property: "total_items", type: "integer", default: 100),
    //                     new OA\Property(property: "total_pages", type: "integer", default: 2),
    //                     new OA\Property(
    //                         property: "data",
    //                         type: "array",
    //                         items: new OA\Items(ref: new Model(type: IngredientDTO::class, groups: ["default"]))
    //                     )
    //                 ]
    //             )
    //         ),
    //         new OA\Response(response: 400, description: "Bad request - Invalid parameters")
    //     ]
    // )]
    // public function getAllIngredients(Request $request): JsonResponse
    // {
    //     try {
    //         $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
    //         $page = $request->query->getInt('page', 1);

    //         $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
    //         $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

    //         $search = $request->query->getString('search', '') ?: null;

    //         $data = $this->ingredientService->getAllIngredients($page, $limit, $sortBy, $sortOrder, $search);
    //         return $this->json($data);

    //     } catch (\InvalidArgumentException | BadRequestException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     }
    // }

    // #[Route('/ingredients', name: 'create_ingredient', methods: ['POST'])]
    // #[OA\Post(
    //     summary: "Create a new ingredient",
    //     description: "Creates a new ingredient with English and French names.",
    //     tags: ["Admin - Ingredients"],
    //     requestBody: new OA\RequestBody(
    //         required: true,
    //         content: new OA\JsonContent(
    //             properties: [
    //                 new OA\Property(property: "nameEn", type: "string", example: "Tomato", minLength: 3, maxLength: 255),
    //                 new OA\Property(property: "nameFr", type: "string", example: "Tomate", minLength: 3, maxLength: 255)
    //             ],
    //             required: ["nameEn", "nameFr"]
    //         )
    //     ),
    //     responses: [
    //         new OA\Response(
    //             response: 201,
    //             description: "Ingredient successfully created",
    //             content: new OA\JsonContent(ref: new Model(type: IngredientDTO::class, groups: ["default"]))
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Validation errors",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
    //                 ]
    //             )
    //         )
    //     ]
    // )]
    // public function createIngredient(Request $request): JsonResponse
    // {
    //     $data = $this->getRequestData($request);
    //     return $this->ingredientService->createIngredient($data);
    // }

    // #[Route('/ingredients/{id}', name: 'get_ingredient', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Get an ingredient by ID",
    //     description: "Fetches a specific ingredient by its unique ID.",
    //     tags: ["Admin - Ingredients"],
    //     parameters: [
    //         new OA\Parameter(
    //             name: "id",
    //             in: "path",
    //             required: true,
    //             description: "UUID of the ingredient",
    //             schema: new OA\Schema(type: "string", format: "uuid"),
    //             example: "550e8400-e29b-41d4-a716-446655440000"
    //         )
    //     ],
    //     responses: [
    //         new OA\Response(
    //             response: 200,
    //             description: "Successful response with ingredient data",
    //             content: new OA\JsonContent(ref: new Model(type: IngredientDTO::class, groups: ["default"]))
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Invalid UUID format",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
    //                 ]
    //             )
    //         ),
    //         new OA\Response(
    //             response: 404,
    //             description: "Not found - Ingredient does not exist",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Ingredient not found.")
    //                 ]
    //             )
    //         )
    //     ]
    // )]
    // public function getIngredient(string $id): JsonResponse
    // {
    //     return $this->ingredientService->getIngredientById($id);
    // }

    // #[Route('/ingredients/{id}', name: 'update_ingredient', methods: ['PATCH'])]
    // #[OA\Patch(
    //     summary: "Update an ingredient",
    //     description: "Updates an existing ingredient's details. At least one field (nameEn or nameFr) must be provided.",
    //     tags: ["Admin - Ingredients"],
    //     parameters: [
    //         new OA\Parameter(
    //             name: "id",
    //             in: "path",
    //             required: true,
    //             description: "UUID of the ingredient",
    //             schema: new OA\Schema(type: "string", format: "uuid"),
    //             example: "550e8400-e29b-41d4-a716-446655440000"
    //         )
    //     ],
    //     requestBody: new OA\RequestBody(
    //         required: true,
    //         content: new OA\JsonContent(
    //             properties: [
    //                 new OA\Property(
    //                     property: "nameEn",
    //                     type: "string",
    //                     minLength: 3,
    //                     maxLength: 255,
    //                     example: "Tomato",
    //                     description: "Updated English name (optional)"
    //                 ),
    //                 new OA\Property(
    //                     property: "nameFr",
    //                     type: "string",
    //                     minLength: 3,
    //                     maxLength: 255,
    //                     example: "Tomate",
    //                     description: "Updated French name (optional)"
    //                 )
    //             ]
    //         )
    //     ),
    //     responses: [
    //         new OA\Response(
    //             response: 200,
    //             description: "Successful update, returns updated ingredient",
    //             content: new OA\JsonContent(ref: new Model(type: IngredientDTO::class, groups: ["default"]))
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Invalid UUID or validation errors",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Invalid UUID format."),
    //                     new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"), example: ["The name must contain at least one alphabetic character."])
    //                 ]
    //             )
    //         ),
    //         new OA\Response(
    //             response: 404,
    //             description: "Not found - Ingredient does not exist",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Ingredient not found.")
    //                 ]
    //             )
    //         )
    //     ]
    // )]
    // public function updateIngredient(string $id, Request $request): JsonResponse
    // {
    //     $data = $this->getRequestData($request);
    //     return $this->ingredientService->updateIngredient($id, $data);
    // }

    // #[Route('/ingredients/{id}', name: 'delete_ingredient', methods: ['DELETE'])]
    // #[OA\Delete(
    //     summary: "Delete an ingredient",
    //     description: "Deletes an ingredient by its UUID.",
    //     tags: ["Admin - Ingredients"],
    //     parameters: [
    //         new OA\Parameter(
    //             name: "id",
    //             in: "path",
    //             required: true,
    //             description: "UUID of the ingredient to delete",
    //             schema: new OA\Schema(type: "string", format: "uuid"),
    //             example: "550e8400-e29b-41d4-a716-446655440000"
    //         )
    //     ],
    //     responses: [
    //         new OA\Response(
    //             response: 204,
    //             description: "Successful deletion (no content)"
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Invalid UUID format",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
    //                 ]
    //             )
    //         ),
    //         new OA\Response(
    //             response: 404,
    //             description: "Not found - Ingredient does not exist",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "error", type: "string", example: "Ingredient not found.")
    //                 ]
    //             )
    //         )
    //     ]
    // )]
    // public function deleteIngredient(string $id): JsonResponse
    // {
    //     return $this->ingredientService->deleteIngredient($id);
    // }

    // explore food stores list (by filters and near locations)
    #[Route('/food-stores', name: 'search_foodstores', methods: ['GET'])]
    #[OA\Get(
        summary: "Search and filter food stores",
        description: "Fetches a paginated list of food stores with sorting, filtering, and search options.",
        tags: ["Admin - Food Stores"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default value is used if not entered)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'createdAt', 'updatedAt') (optional)", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc) (optional)", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term for food store (name, description) (optional)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "country", in: "query", description: "Filter by country (optional)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "city", in: "query", description: "Filter by city (optional)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "state", in: "query", description: "Filter by state (optional)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "zipCode", in: "query", description: "Filter by zip code (optional)", schema: new OA\Schema(type: "string")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated food store data",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: FoodStoreDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters"),
        ]
    )]
    public function getAllFoodStores(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;
            $type = $request->query->getString('type', '') ?: null;

            $locationFilters = array_filter([
                'country' => $request->query->getString('country', '') ?: null,
                'city' => $request->query->getString('city', '') ?: null,
                'state' => $request->query->getString('state', '') ?: null,
                'zipCode' => $request->query->getString('zipCode', '') ?: null
            ]);

            $onlyActive = false;

            $data = $this->foodStoreService->getAllFoodStores($page, $limit, $sortBy, $sortOrder, $search, $locationFilters, $type, $onlyActive);
            return $this->json($data);
        } catch (InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/food-stores/{id}', name: 'get_food_store', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a food store by ID",
        description: "Fetches detailed information about a specific food store by its unique identifier.",
        tags: ["Admin - Food Stores"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the food store",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with food store data",
                content: new OA\JsonContent(
                    ref: new Model(type: FoodStoreDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID format"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStore(string $id): JsonResponse
    {
        // @TODO check if not soft deleted after the feature is implemented
        $foodStore = $this->foodStoreRepository->findOneBy(['id' => $id]);

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], Response::HTTP_NOT_FOUND);
        }

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, Response::HTTP_OK);
    }

    #[Route('/food-stores/{id}/dishes', name: 'get_food_store_dishes', methods: ['GET'])]
    #[OA\Get(
        summary: "Get dishes from a specific food store",
        description: "Fetches a paginated list of dishes from a specific food store with filtering, sorting, and search options.",
        tags: ["Admin - Food Stores"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the food store",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'price', 'cachedAverageRating')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc)", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "available", in: "query", description: "Filter by availability", schema: new OA\Schema(type: "boolean"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated dishes",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStoreDishes(string $id, Request $request): JsonResponse
    {
        // @TODO check if not soft deleted after the feature is implemented
        $foodStore = $this->foodStoreRepository->findOneBy(['id' => $id]);

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], Response::HTTP_NOT_FOUND);
        }

        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $minPrice = $request->query->get('minPrice', null);
            $maxPrice = $request->query->get('maxPrice', null);
            $available = $request->query->get('available', null);

            $ingredients = $request->query->all('ingredients');
            $categories = $request->query->all('categories');

            $foodStoreId = $foodStore->getId();

            $onlyActiveStores = false;

            $data = $this->dishService->getFilteredDishes(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $minPrice,
                $maxPrice,
                $available,
                $ingredients,
                $foodStoreId,
                $categories,
                $onlyActiveStores
            );
            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/dishes', name: 'search_dishes', methods: ['GET'])]
    #[OA\Get(
        summary: "Search and filter all dishes",
        description: "Fetches a paginated list of dishes across all food stores with filtering, sorting, and search options.",
        tags: ["Admin - Dishes"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc)", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "foodStoreId", in: "query", description: "Filter by food store ID", schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated dishes",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
        ]
    )]
    public function searchDishes(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $minPrice = $request->query->get('minPrice', null);
            $maxPrice = $request->query->get('maxPrice', null);
            $available = $request->query->get('available', null);

            $foodStoreId = $request->query->get('foodStoreId', null);

            $ingredients = $request->query->all('ingredients');
            $categories = $request->query->all('categories');

            $onlyActiveStores = false;

            $data = $this->dishService->getFilteredDishes(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $minPrice,
                $maxPrice,
                $available,
                $ingredients,
                $foodStoreId,
                $categories,
                $onlyActiveStores
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/dishes/{id}', name: 'get_dish', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a dish by ID",
        description: "Fetches detailed information about a specific dish.",
        tags: ["Admin - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with dish details",
                content: new OA\JsonContent(
                    ref: new Model(type: DishDetailDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 404, description: "Dish not found"),
        ]
    )]
    public function getDish(string $id): JsonResponse
    {
        $dish = $this->dishRepository->findOneBy(['id' => $id]);
        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }
        $dishDto = $this->dishMapper->mapToDetailDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_OK);
    }

    //orders

    #[Route('/orders', name: 'orders', methods: ['GET'])]
    #[OA\Get(
        summary: "Search and filter all orders",
        description: "Fetches a paginated list of all orders with filtering, sorting, and search options.",
        tags: ["Admin - Orders"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order (asc/desc)", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum price", schema: new OA\Schema(type: "number")),
            new OA\Parameter(name: "buyerId", in: "query", description: "Filter by buyer ID", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "foodStoreId", in: "query", description: "Filter by food store ID", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "status", in: "query", description: "Filter by status", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "paymentStatus", in: "query", description: "Filter by payment status", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "deliveryStatus", in: "query", description: "Filter by delivery status", schema: new OA\Schema(type: "string"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated orders",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: OrderDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
        ]
    )]
    public function getOrders(Request $request): JsonResponse
    {
        try {

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $minPrice = $request->query->get('minPrice', null);
            $maxPrice = $request->query->get('maxPrice', null);

            $buyerId = $request->query->getString('buyerId', '') ?: null;
            $foodStoreId = $request->query->getString('foodStoreId', '') ?: null;

            $filters = [];

            if ($status = $request->query->get('status')) {
                $filters['status'] = OrderStatus::tryFrom($status);
                if ($filters['status'] === null) {
                    throw new InvalidArgumentException('Invalid order status');
                }
            }

            if ($paymentStatus = $request->query->get('paymentStatus')) {
                $filters['paymentStatus'] = OrderPaymentStatus::tryFrom($paymentStatus);
                if ($filters['paymentStatus'] === null) {
                    throw new InvalidArgumentException('Invalid payment status');
                }
            }

            if ($deliveryStatus = $request->query->get('deliveryStatus')) {
                $filters['deliveryStatus'] = OrderDeliveryStatus::tryFrom($deliveryStatus);
                if ($filters['deliveryStatus'] === null) {
                    throw new InvalidArgumentException('Invalid delivery status');
                }
            }

            $data = $this->orderService->getFilteredOrders(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $minPrice,
                $maxPrice,
                $buyerId,
                $foodStoreId,
                $filters
            );
            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/orders/{id}', name: 'order_detail', methods: ['GET'])]
    #[OA\Get(
        summary: "Get an order by ID",
        description: "Fetches detailed information about a specific order.",
        tags: ["Admin - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The unique identifier of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with order details",
                content: new OA\JsonContent(
                    ref: new Model(type: OrderDetailDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Order not found"),
        ]
    )]
    public function getOrder(string $id): JsonResponse
    {
        try {

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order) {
                throw new NotFoundHttpException('Order not found');
            }

            $orderDTO = $this->orderMapper->mapToDetailDTO($order);

            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/orders/{id}/cancel', name: 'admin_order_cancel', methods: ['POST'])]
    #[OA\Post(
        summary: "Cancel an order",
        description: "Cancels an order and initiates a refund if payment was made. Cannot cancel completed orders, orders in transit, or already delivered orders. Intended for admin use only.",
        tags: ["Admin - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order to cancel",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Order cancelled successfully",
                content: new OA\JsonContent(ref: new Model(type: OrderDetailDTO::class))
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format or order cannot be cancelled",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Completed orders cannot be cancelled")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Order already cancelled",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order is already cancelled")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "An error occurred while cancelling the order.")
                    ]
                )
            )
        ]
    )]
    public function cancelOrder(string $id): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new \InvalidArgumentException('Invalid UUID format');
            }

            $order = $this->orderService->getOrderById($id);
            if (!$order instanceof Order) {
                throw new NotFoundHttpException('Order not found');
            }

            $this->orderService->requestRefund($order, USER::TYPE_ADMIN);
            $this->twilioProxyService->closeProxySession($order);

            $this->entityManager->flush();

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);
            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred while cancelling the order.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }


    #[Route('/verification-requests', name: 'get_verification_requests', methods: ['GET'])]
    #[OA\Get(
        summary: "Get all food store verification requests",
        description: "Fetches a paginated list of food store verification requests with filtering and sorting.",
        tags: ["Admin - Food Store Verification"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page", schema: new OA\Schema(type: "integer", default: 50)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "status", in: "query", description: "Filter by status", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "foodStoreId", in: "query", description: "Filter by food store", schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with verification requests",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: FoodStoreVerificationRequestDTO::class, groups: ["default"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
        ]
    )]
    public function getVerificationRequests(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $status = $request->query->get('status');
            $foodStoreId = $request->query->get('foodStoreId');

            $filters = [];
            if ($status) {
                $filters['status'] = StoreVerificationStatus::tryFrom($status);
            }
            if ($foodStoreId) {
                if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                    throw new InvalidArgumentException('Invalid UUID format');
                }
                $foodStore = $this->foodStoreRepository->find($foodStoreId);
                if ($foodStore instanceof FoodStore) {
                    $filters['foodStore'] = $this->foodStoreRepository->find($foodStoreId);
                }
            }

            $data = $this->foodStoreVerificationService->getAllVerificationRequests(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $filters
            );

            return $this->json($data);
        } catch (InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/food-stores/{id}/verification-requests', name: 'get_food_store_verification_requests_admin', methods: ['GET'])]
    #[OA\Get(
        summary: "Get verification requests for a food store",
        description: "Fetches verification requests for a specific food store.",
        tags: ["Admin - Food Store Verification"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "limit", in: "query", schema: new OA\Schema(type: "integer", default: 50)),
            new OA\Parameter(name: "page", in: "query", schema: new OA\Schema(type: "integer", default: 1)),
            new OA\Parameter(name: "sortBy", in: "query", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "status", in: "query", schema: new OA\Schema(type: "string"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: FoodStoreVerificationRequestDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStoreVerificationRequestsAdmin(string $id, Request $request): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $foodStore = $this->foodStoreRepository->find($id);
            if (!$foodStore instanceof FoodStore) {
                return $this->json(['error' => 'Food store not found'], JsonResponse::HTTP_NOT_FOUND);
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $status = $request->query->get('status');

            $filters = [];

            if ($status) {
                $filters['status'] = StoreVerificationStatus::tryFrom($status);
            }

            $filters['foodStore'] = $foodStore;

            $data = $this->foodStoreVerificationService->getAllVerificationRequests(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $filters
            );

            return $this->json($data);
        } catch (InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/verification-requests/{requestId}/documents/{mediaId}', name: 'download_verification_document', methods: ['GET'])]
    #[OA\Get(
        summary: "Download verification document",
        description: "Downloads a document from a food store verification request.",
        tags: ["Admin - Food Store Verification"],
        parameters: [
            new OA\Parameter(name: "requestId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "mediaId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "File downloaded",
                content: new OA\MediaType(mediaType: "application/octet-stream")
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Not found"),
            new OA\Response(response: 500, description: "Internal server error"),
        ]
    )]
    public function downloadVerificationDocument(string $requestId, string $mediaId): Response
    {
        try {
            if (!ValidationHelper::isCorrectUuid($requestId) || !ValidationHelper::isCorrectUuid($mediaId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $verificationRequest = $this->foodStoreVerificationRequestRepository->find($requestId);
            if (!$verificationRequest instanceof FoodStoreVerificationRequest) {
                return $this->json(['error' => 'Verification request not found'], Response::HTTP_NOT_FOUND);
            }

            // $document = $verificationRequest->getVerificationDocument();
            $media = $this->foodStoreVerificationService->findMediaDocumentInVerificationRequest($verificationRequest, $mediaId);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        }

        try {
            $fileContent = $this->mediaService->downloadSecure($media);

            return new Response(
                $fileContent,
                Response::HTTP_OK,
                [
                    'Content-Type' => $media->getMimeType(),
                    'Content-Disposition' => sprintf(
                        'attachment; filename="%s"',
                        $media->getOriginalName()
                    ),
                    'X-Accel-Buffering' => 'no' // For better performance with large files
                ]
            );
        } catch (\RuntimeException $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }


    #[Route('/verification-requests/{id}/approve', name: 'approve_verification_request', methods: ['POST'])]
    #[OA\Post(
        summary: "Approve verification request",
        description: "Approves a pending food store verification request.",
        tags: ["Admin - Food Store Verification"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "note", type: "string", description: "Optional approval note")
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Request approved",
                content: new OA\JsonContent(ref: new Model(type: FoodStoreVerificationRequestDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Not found"),
        ]
    )]
    public function approveVerificationRequest(
        string $id,
        Request $request,
    ): JsonResponse {
        try {
            $data = $this->getRequestData($request);
            $note = $data['note'] ?? null;

            $verificationRequest = $this->foodStoreVerificationService->approveRequest(
                $id,
                $this->getUser(),
                $note
            );

            return $this->json(
                $this->foodStoreVerificationRequestMapper->mapToDTO($verificationRequest)
            );
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/verification-requests/{id}/reject', name: 'reject_verification_request', methods: ['POST'])]
    #[OA\Post(
        summary: "Reject verification request",
        description: "Rejects a pending food store verification request with a rejection reason.",
        tags: ["Admin - Food Store Verification"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "note", type: "string", description: "Rejection reason")
                ],
                required: ["note"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Request rejected",
                content: new OA\JsonContent(ref: new Model(type: FoodStoreVerificationRequestDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Not found"),
        ]
    )]
    public function rejectVerificationRequest(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);

            if (empty($data['note'])) {
                throw new \InvalidArgumentException('Rejection note is required');
            }

            $verificationRequest = $this->foodStoreVerificationService->rejectRequest(
                $id,
                $this->getUser(),
                $data['note']
            );

            return $this->json(
                $this->foodStoreVerificationRequestMapper->mapToDTO($verificationRequest)
            );
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/category-types', name: 'categories_types_list', methods: ['GET'])]
    #[OA\Get(
        summary: "Get all category types",
        description: "Fetches all available category types with labels in multiple languages.",
        tags: ["Admin - Categories"],
        parameters: [
            new OA\Parameter(name: "locale", in: "query", schema: new OA\Schema(type: "string", default: "en", enum: ["en", "fr"]))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Success",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(
                        properties: [
                            new OA\Property(property: "value", type: "string"),
                            new OA\Property(property: "labelEn", type: "string"),
                            new OA\Property(property: "labelFr", type: "string"),
                            new OA\Property(property: "label", type: "string")
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
        summary: "Get all categories",
        description: "Fetches a paginated list of categories with filtering and sorting options.",
        tags: ["Admin - Categories"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", schema: new OA\Schema(type: "integer", default: 50)),
            new OA\Parameter(name: "page", in: "query", schema: new OA\Schema(type: "integer", default: 1)),
            new OA\Parameter(name: "sortBy", in: "query", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "type", in: "query", schema: new OA\Schema(type: "string"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Success",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: CategoryDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
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

    #[Route('/categories/{id}', name: 'get_category', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a category by ID",
        description: "Fetches detailed information about a specific category.",
        tags: ["Admin - Categories"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Success",
                content: new OA\JsonContent(ref: new Model(type: CategoryDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Category not found"),
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

    #[Route('/categories', name: 'create_category', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a new category",
        description: "Creates a new category for organizing food items.",
        tags: ["Admin - Categories"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "nameEn", type: "string", example: "Beverages"),
                    new OA\Property(property: "nameFr", type: "string", example: "Boissons"),
                    new OA\Property(property: "type", type: "string")
                ],
                required: ["nameEn", "nameFr"]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Category created",
                content: new OA\JsonContent(ref: new Model(type: CategoryDTO::class))
            ),
            new OA\Response(response: 400, description: "Validation failed"),
        ]
    )]
    public function createCategory(Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);
            if ($data === null) {
                throw new BadRequestHttpException('Invalid request payload.');
            }

            $categoryDTO = $this->categoryService->createCategory($data);
            return $this->json($categoryDTO, JsonResponse::HTTP_CREATED);
        } catch (ValidationException $e) {
            return $this->json(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/categories/{id}', name: 'update_category', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a category",
        description: "Updates an existing category. Only provided fields will be updated.",
        tags: ["Admin - Categories"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "nameEn", type: "string"),
                    new OA\Property(property: "nameFr", type: "string"),
                    new OA\Property(property: "type", type: "string")
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Category updated",
                content: new OA\JsonContent(ref: new Model(type: CategoryDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Category not found"),
        ]
    )]
    public function updateCategory(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);
            if ($data === null) {
                throw new BadRequestHttpException('Invalid request payload.');
            }

            $categoryDTO = $this->categoryService->updateCategory($id, $data);
            return $this->json($categoryDTO, JsonResponse::HTTP_OK);
        } catch (ValidationException $e) {
            return $this->json(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/categories/{id}', name: 'delete_category', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete a category",
        description: "Deletes a category by its unique identifier.",
        tags: ["Admin - Categories"],
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(response: 204, description: "Deleted"),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Category not found"),
        ]
    )]
    public function deleteCategory(string $id): JsonResponse
    {
        try {
            $this->categoryService->deleteCategory($id);
            return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-store/{foodStoreId}/ratings', name: 'food_store_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get ratings for a food store",
        description: "Fetches a paginated list of ratings for a specific food store.",
        tags: ["Admin - Ratings"],
        parameters: [
            new OA\Parameter(name: "foodStoreId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "limit", in: "query", schema: new OA\Schema(type: "integer", default: 50)),
            new OA\Parameter(name: "page", in: "query", schema: new OA\Schema(type: "integer", default: 1)),
            new OA\Parameter(name: "sortBy", in: "query", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "buyerId", in: "query", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "orderId", in: "query", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "minRating", in: "query", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)),
            new OA\Parameter(name: "maxRating", in: "query", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Success",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishRatingDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStoreRatings(string $foodStoreId, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $foodStore = $this->foodStoreRepository->findOneBy(['id' => $foodStoreId]);

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $buyerId = $request->query->getString('buyerId', '') ?: null;
            $orderId = $request->query->getString('orderId', '') ?: null;

            $filters = [
                'foodStoreId' => $foodStore->getId()
            ];

            $minRating = $request->query->get('minRating');
            $maxRating = $request->query->get('maxRating');

            if ($minRating !== null && is_numeric($minRating)) {
                $filters['minRating'] = max(1, min(5, (int)$minRating));
            }

            if ($maxRating !== null && is_numeric($maxRating)) {
                $filters['maxRating'] = max(1, min(5, (int)$maxRating));
            }

            $data = $this->dishRatingService->getFilteredRatings(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                null,
                $buyerId,
                $orderId,
                $filters
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/dishes/{dishId}/ratings', name: 'food_store_dish_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get ratings for a dish",
        description: "Fetches a paginated list of ratings for a specific dish.",
        tags: ["Admin - Ratings"],
        parameters: [
            new OA\Parameter(name: "dishId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "limit", in: "query", schema: new OA\Schema(type: "integer", default: 50)),
            new OA\Parameter(name: "page", in: "query", schema: new OA\Schema(type: "integer", default: 1)),
            new OA\Parameter(name: "sortBy", in: "query", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "buyerId", in: "query", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "orderId", in: "query", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "minRating", in: "query", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)),
            new OA\Parameter(name: "maxRating", in: "query", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Success",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer"),
                        new OA\Property(property: "limit", type: "integer"),
                        new OA\Property(property: "total_items", type: "integer"),
                        new OA\Property(property: "total_pages", type: "integer"),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishRatingDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Dish not found"),
        ]
    )]
    public function getDishRatings(string $dishId, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            if (!ValidationHelper::isCorrectUuid($dishId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $dish = $this->dishRepository->find($dishId);
            if (!$dish instanceof Dish) {
                throw new NotFoundHttpException('Dish not found');
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $buyerId = $request->query->getString('buyerId', '') ?: null;
            $orderId = $request->query->getString('orderId', '') ?: null;

            $minRating = $request->query->get('minRating');
            $maxRating = $request->query->get('maxRating');

            $filters = [];

            if ($minRating !== null && is_numeric($minRating)) {
                $filters['minRating'] = max(1, min(5, (int)$minRating));
            }

            if ($maxRating !== null && is_numeric($maxRating)) {
                $filters['maxRating'] = max(1, min(5, (int)$maxRating));
            }

            $data = $this->dishRatingService->getFilteredRatings(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $dishId,
                $buyerId,
                $orderId,
                $filters
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-stores/{foodStoreId}/wallet', name: 'food_store_wallet', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a food store's wallet",
        description: "Fetches wallet information for a specific food store, including balance and status.",
        tags: ["Admin - Wallet"],
        parameters: [
            new OA\Parameter(name: "foodStoreId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with wallet data",
                content: new OA\JsonContent(ref: new Model(type: WalletDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID format"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStoreWallet(string $foodStoreId): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $foodStore = $this->foodStoreRepository->find($foodStoreId);

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('Food store not found');
            }

            $wallet = $foodStore->getWallet();

            if (!$wallet instanceof Wallet) {
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
                $this->entityManager->flush();
            }

            $walletDTO = $this->walletMapper->mapToDTO($wallet);

            return $this->json($walletDTO, JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-stores/{foodStoreId}/wallet/transactions', name: 'food_store_wallet_transactions', methods: ['GET'])]
    #[OA\Get(
        summary: "Get wallet transactions for a food store",
        description: "Fetches a list of all wallet transactions (deposits, withdrawals, etc.) for a specific food store.",
        tags: ["Admin - Wallet"],
        parameters: [
            new OA\Parameter(name: "foodStoreId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with transaction list",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: new Model(type: WalletTransactionDTO::class))
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID format"),
            new OA\Response(response: 404, description: "Food store not found"),
        ]
    )]
    public function getFoodStoreWalletTransactions(string $foodStoreId): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $foodStore = $this->foodStoreRepository->find($foodStoreId);

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('Food store not found');
            }

            $wallet = $foodStore->getWallet();

            if (!$wallet instanceof Wallet) {
                // throw new NotFoundHttpException('Wallet not found');
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
            }

            // @TODO use paginated data with search and filters
            $transactions = $this->walletTransactionRepository->findBy(
                ['wallet' => $wallet],
                ['createdAt' => 'DESC']
            );

            $transactionsDTO = $this->walletTransactionMapper->mapToDTOs($transactions);

            return $this->json($transactionsDTO, JsonResponse::HTTP_OK);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }


    #[Route('/food-stores/{foodStoreId}/wallet/block', name: 'admin_block_food_store_wallet', methods: ['POST'])]
    #[OA\Post(
        summary: "Block a food store's wallet",
        description: "Prevents the food store from requesting payouts by deactivating their wallet.",
        tags: ["Admin - Wallet"],
        parameters: [
            new OA\Parameter(name: "foodStoreId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Wallet successfully blocked",
                content: new OA\JsonContent(ref: new Model(type: WalletDTO::class))
            ),
            new OA\Response(response: 400, description: "Invalid UUID format"),
            new OA\Response(response: 404, description: "Food store or wallet not found"),
            new OA\Response(response: 409, description: "Wallet already blocked"),
        ]
    )]
    public function blockWallet(string $foodStoreId): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new \InvalidArgumentException('Invalid UUID format');
            }

            $foodStore = $this->foodStoreRepository->find($foodStoreId);
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('Food store not found');
            }

            $wallet = $foodStore->getWallet();
            if (!$wallet instanceof Wallet) {
                throw new NotFoundHttpException('Wallet not found');
            }

            if (!$wallet->isActive()) {
                return $this->json(['message' => 'Wallet already blocked.'], JsonResponse::HTTP_CONFLICT);
            }

            $wallet->setIsActive(false);
            $this->entityManager->flush();

            return $this->json($this->walletMapper->mapToDTO($wallet), JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-stores/{foodStoreId}/wallet/unblock', name: 'admin_unblock_food_store_wallet', methods: ['POST'])]
    #[OA\Post(
        summary: "Unblock a food store's wallet",
        description: "Re-enables payout requests for a previously blocked wallet.",
        tags: ["Admin - Wallet"],
        parameters: [
            new OA\Parameter(name: "foodStoreId", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Wallet successfully unblocked",
                content: new OA\JsonContent(ref: new Model(type: WalletDTO::class))
            ),
            new OA\Response(response: 400, description: "Invalid UUID format"),
            new OA\Response(response: 404, description: "Food store or wallet not found"),
            new OA\Response(response: 409, description: "Wallet already active"),
        ]
    )]
    public function unblockWallet(string $foodStoreId): JsonResponse
    {
        try {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new \InvalidArgumentException('Invalid UUID format');
            }

            $foodStore = $this->foodStoreRepository->find($foodStoreId);
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('Food store not found');
            }

            $wallet = $foodStore->getWallet();
            if (!$wallet instanceof Wallet) {
                throw new NotFoundHttpException('Wallet not found');
            }

            if ($wallet->isActive()) {
                return $this->json(['message' => 'Wallet already active.'], JsonResponse::HTTP_CONFLICT);
            }

            $wallet->setIsActive(true);
            $this->entityManager->flush();

            return $this->json($this->walletMapper->mapToDTO($wallet), JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }




    #[Route('/payout-config', name: 'upsert_payout_config', methods: ['POST'])]
    #[OA\Post(
        summary: "Create or update payout configuration",
        description: "Creates or updates the global payout configuration settings for the platform.",
        tags: ["Admin - Payout Configuration"],
        requestBody: new OA\RequestBody(
            required: false,
            description: "Payout configuration update (only provided fields will be updated)",
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "commissionRate", type: "number", description: "Commission rate (0-1)", example: 0.15, minimum: 0, maximum: 1),
                    new OA\Property(property: "minimumPayout", type: "number", description: "Minimum payout amount", example: 10.00, exclusiveMinimum: true),
                    new OA\Property(property: "maximumPayout", type: "number", description: "Maximum payout amount", example: 5000.00, exclusiveMinimum: true),
                    new OA\Property(property: "payoutCooldownHours", type: "integer", description: "Cooldown between payouts in hours", example: 24, minimum: 1, maximum: 720),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Configuration created or updated successfully",
                content: new OA\JsonContent(ref: new Model(type: PayoutConfigDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Validation errors"),
            new OA\Response(response: 500, description: "Internal server error"),
        ]
    )]
    public function upsertPayoutConfig(Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);

            if ($data === null) {
                return $this->json(['error' => 'Invalid request payload'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'commissionRate' => [
                        new Assert\Optional([
                            new Assert\Type('numeric'),
                            new Assert\Range(['min' => 0, 'max' => 1]),
                            new Assert\NotBlank()
                        ])
                    ],
                    'minimumPayout' => [
                        new Assert\Optional([
                            new Assert\Type('numeric'),
                            new Assert\Positive(),
                            new Assert\NotBlank()
                        ])
                    ],
                    'maximumPayout' => [
                        new Assert\Optional([
                            new Assert\Type('numeric'),
                            new Assert\Positive(),
                            new Assert\NotBlank()
                        ])
                    ],
                    'payoutCooldownHours' => [
                        new Assert\Optional([
                            new Assert\Type('integer'),
                            new Assert\Positive(),
                            new Assert\LessThanOrEqual(720) // 30 days
                        ])
                    ],
                ],
                'allowMissingFields' => true, // patch
                'allowExtraFields' => false
            ]);

            // Validate input data
            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                $formattedErrors = ValidationHelper::formatErrors($errors);
                return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
            }


            $config = $this->payoutConfigurationRepository->findOneBy([]);

            if (!$config instanceof PayoutConfiguration) {
                $config = new PayoutConfiguration();
            }

            if (array_key_exists('minimumPayout', $data)) {
                $config->setMinimumPayout(
                    MoneyHelper::normalize((float)$data['minimumPayout'])
                );
            }

            if (array_key_exists('maximumPayout', $data)) {
                $config->setMaximumPayout(
                    MoneyHelper::normalize((float)$data['maximumPayout'])
                );
            }

            if (array_key_exists('commissionRate', $data)) {
                $config->setCommissionRate((string) $data['commissionRate']);
            }

            if (array_key_exists('payoutCooldownHours', $data)) {
                $config->setPayoutCooldownHours($data['payoutCooldownHours']);
            }

            $this->entityManager->persist($config);
            $this->entityManager->flush();

            return $this->json($this->payoutConfigMapper->mapToDTO($config));
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/payout-config', name: 'get_payout_config', methods: ['GET'])]
    #[OA\Get(
        summary: "Get payout configuration",
        description: "Fetches the current global payout configuration settings.",
        tags: ["Admin - Payout Configuration"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Current payout configuration",
                content: new OA\JsonContent(ref: new Model(type: PayoutConfigDTO::class))
            ),
        ]
    )]
    public function getPayoutConfig(): JsonResponse
    {
        $configDTO = $this->walletService->getPayoutConfig();
        return $this->json($configDTO);
    }

    #[Route('/stats', name: 'get_basic_stats', methods: ['GET'])]
    #[OA\Get(
        summary: "Get basic statistics",
        description: "Retrieves basic statistics for the entire platform including total users, buyers, sellers, total orders, pending orders, and total revenue from completed orders.",
        tags: ["Admin - Statistics"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with platform statistics",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "totalUsers", type: "integer", description: "Total number of active users"),
                        new OA\Property(property: "totalBuyers", type: "integer", description: "Total number of buyers"),
                        new OA\Property(property: "totalSellers", type: "integer", description: "Total number of sellers"),
                        new OA\Property(property: "totalOrders", type: "integer", description: "Total number of orders"),
                        new OA\Property(property: "totalPendingOrders", type: "integer", description: "Number of pending orders"),
                        new OA\Property(property: "totalRevenue", type: "string", description: "Total revenue as a decimal string")
                    ],
                    example: [
                        "totalUsers" => 1250,
                        "totalBuyers" => 950,
                        "totalSellers" => 300,
                        "totalOrders" => 8450,
                        "totalPendingOrders" => 125,
                        "totalRevenue" => "458920.75"
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
        summary: "Get platform revenue by day",
        description: "Retrieves platform-wide revenue statistics grouped by day for a specific month and year. Revenue is calculated from all completed orders across all sellers.",
        tags: ["Admin - Statistics"],
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
                description: "Successful response with platform revenue by day",
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
                            "1" => "8450.75",
                            "2" => "9200.50",
                            "3" => "7875.25",
                            "4" => "0.00",
                            "5" => "12300.00",
                            "11" => "15629.99"
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
        summary: "Get platform revenue by month",
        description: "Retrieves platform-wide revenue statistics grouped by month for a specific year. Revenue is calculated from all completed orders across all sellers.",
        tags: ["Admin - Statistics"],
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
                description: "Successful response with platform revenue by month",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "year", type: "integer"),
                        new OA\Property(property: "revenueByMonth", type: "object", description: "Revenue keyed by month (1-12), values are decimal strings")
                    ],
                    example: [
                        "year" => 2025,
                        "revenueByMonth" => [
                            "1" => "45230.50",
                            "2" => "38450.75",
                            "3" => "52920.00",
                            "4" => "0.00",
                            "5" => "61150.25",
                            "11" => "75680.99",
                            "12" => "58345.60"
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
        summary: "Get platform revenue by year",
        description: "Retrieves platform-wide aggregated revenue statistics grouped by year. Revenue is calculated from all completed orders across all sellers.",
        tags: ["Admin - Statistics"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with platform revenue by year",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "revenueByYear", type: "object", description: "Revenue keyed by year, values are decimal strings")
                    ],
                    example: [
                        "revenueByYear" => [
                            "2023" => "425680.50",
                            "2024" => "625420.75",
                            "2025" => "398765.30"
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
}
