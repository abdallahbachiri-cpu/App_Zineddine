<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use App\DTO\CartDTO;
use App\DTO\DishDetailDTO;
use App\DTO\DishDTO;
use App\DTO\DishRatingDTO;
use App\DTO\FoodStoreDTO;
use App\DTO\OrderDetailDTO;
use App\DTO\OrderDTO;
use App\DTO\UserDTO;
use App\Entity\Cart;
use App\Entity\CartDish;
use App\Entity\CartDishIngredient;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use App\Entity\Dish;
use App\Entity\DishIngredient;
use App\Entity\DishRating;
use App\Entity\Enum\OrderDeliveryStatus;
use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\OrderStatus;
use App\Entity\FoodStore;
use App\Entity\Order;
use App\Entity\OrderDish;
use App\Entity\OrderDishIngredient;
use App\Entity\User;
use App\Entity\Enum\CategoryType;
use App\Entity\Enum\OrderDeliveryMethod;
use App\Entity\Enum\OrderTipPaymentStatus;
use App\Entity\Enum\StoreDeliveryOption;
use App\Entity\Location;
use App\Exception\ValidationException;
use App\Helper\MoneyHelper;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\CartDishIngredientRepository;
use App\Repository\CartDishRepository;
use App\Repository\CartRepository;
use App\Repository\DishIngredientRepository;
use App\Repository\DishRepository;
use App\Repository\FoodStoreRepository;
use App\Repository\IngredientRepository;
use App\Repository\MediaRepository;
use App\Repository\OrderRepository;
use App\Service\Cart\CartDish\CartDishMapper;
use App\Service\Cart\CartMapper;
use App\Service\Cart\CartService;
use App\Service\Category\CategoryService;
use App\Service\Dish\DishMapper;
use App\Service\Dish\DishService;
use App\Service\Order\OrderMapper;
use App\Service\DishIngredient\DishIngredientMapper;
use App\Service\DishRating\DishRatingMapper;
use App\Service\DishRating\DishRatingService;
use App\Service\FoodStore\FoodStoreMapper;
use App\Service\FoodStore\FoodStoreService;
use App\Service\Ingredient\IngredientService;
use App\Service\Location\LocationService;
use App\Service\Media\MediaService;
use App\Service\Order\OrderService;
use App\Service\Stripe\StripeService;
use App\Service\Statistics\StatisticsService;
use App\Service\Tax\TaxCalculatorService;
use App\Service\Twilio\TwilioProxyService;
use App\Service\User\UserMapper;
use App\Service\User\UserService;
use Brick\Math\BigDecimal;
use Doctrine\DBAL\LockMode;
use Doctrine\ORM\EntityManagerInterface;
use DomainException;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\Exception\BadRequestException;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Psr\Log\LoggerInterface;
use Stripe\Exception\ApiErrorException;
use Stripe\Exception\CardException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

#[Route('/api/buyer', name: 'buyer_')]
class BuyerController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private SerializerInterface $serializer,
        private ValidatorInterface $validator,
        private DishRepository $dishRepository,
        private FoodStoreRepository $foodStoreRepository,
        private MediaRepository $mediaRepository,
        private IngredientRepository $ingredientRepository,
        private DishIngredientRepository $dishIngredientRepository,
        private CartMapper $cartMapper,
        private CartDishRepository $cartDishRepository,
        private CartRepository $cartRepository,
        private CartDishIngredientRepository $cartDishIngredientRepository,
        private OrderRepository $orderRepository,
        private CartDishMapper $cartDishMapper,
        private UserMapper $userMapper,
        private FoodStoreMapper $foodStoreMapper,
        private FoodStoreService $foodStoreService,
        private DishMapper $dishMapper,
        private DishService $dishService,
        private IngredientService $ingredientService,
        private LocationService $locationService,
        private DishIngredientMapper $dishIngredientMapper,
        private UserService $userService,
        private MediaService $mediaService,
        private CartService $cartService,
        private OrderMapper $orderMapper,
        private OrderService $orderService,
        private StripeService $stripeService,
        private CategoryService $categoryService,
        private DishRatingService $dishRatingService,
        private DishRatingMapper $dishRatingMapper,
        private TwilioProxyService $twilioProxyService,
        private TaxCalculatorService $taxCalculator,
        private StatisticsService $statisticsService,
        private readonly LoggerInterface $logger,
    ) {
    }

    // user info and management
    #[Route('', name: 'info', methods: ['GET'])]
    #[OA\Get(
        summary: "Get the logged-in buyer's information",
        description: "Retrieves the profile details of the authenticated buyer.",
        tags: ["Buyer - profile"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with user data",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function getBuyerInfo(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        $userDTO = $this->userMapper->mapToDTO($user);

        return $this->json($userDTO);
    }

    #[Route('', name: 'update', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update the logged-in buyer's profile",
        description: "Updates the profile of the authenticated buyer. Only provided fields will be updated.",
        tags: ["Buyer - profile"],
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
                        example: "buyer@example.com",
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
            new OA\Response(response: 400, description: "Bad request - Invalid request payload"),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 422, description: "Unprocessable entity - Business logic validation failed"),
        ]
    )]
    public function updateBuyer(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        $userId = $user->getId();

        try {
            $data = $this->getRequestData($request);

            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            return $this->userService->updateUser($userId, $data);
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

    #[Route('', name: 'delete', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete the logged-in user",
        description: "Soft deletes the authenticated user account. The account is marked as deleted but not removed from the database.",
        tags: ["Buyer - profile"],
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
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function deleteUser(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        try {
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }
            return $this->userService->softDeleteUser($user->getId());
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    // #[Route('/suspend', name: 'suspend', methods: ['POST'])]
    // #[OA\Post(
    //     summary: "Suspend the logged-in user",
    //     description: "Suspends the authenticated buyer account. The user will no longer be able to access their account until reactivated.",
    //     tags: ["Buyer - profile"],
    //     responses: [
    //         new OA\Response(
    //             response: 200,
    //             description: "User successfully suspended",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "message", type: "string", example: "User has been suspended")
    //                 ]
    //             )
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Invalid request"
    //         ),
    //         new OA\Response(
    //             response: 404,
    //             description: "User not found"
    //         ),
    //         new OA\Response(
    //             response: 409,
    //             description: "Conflict - User is already suspended"
    //         )
    //     ]
    // )]
    // public function suspendUser(): JsonResponse
    // {
    //     /** @var User $user */
    //     $user = $this->getUser();
    //     try {
    //         if (!$user instanceof User) {
    //             throw new NotFoundHttpException('User not found');
    //         }
    //         return $this->userService->suspendUser($user->getId());

    //     } catch (InvalidArgumentException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);

    //     }  catch (NotFoundHttpException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);

    //     } catch (ConflictHttpException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
    //     }
    // }

    #[Route('/restore', name: 'restore', methods: ['POST'])]
    #[OA\Post(
        summary: "Restore the logged-in user",
        description: "Restores the authenticated user account if it was previously deleted.",
        tags: ["Buyer - profile"],
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
                response: 404,
                description: "User not found"
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - User is not deleted"
            )
        ]
    )]
    public function restoreUser(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        try {
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }
            return $this->userService->restoreUser($user->getId());
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        }
    }

    // #[Route('/activate', name: 'activate', methods: ['POST'])]
    // public function activateUser(): JsonResponse
    // {
    //     /** @var User $user */
    //     $user = $this->getUser();
    //     if (!$user instanceof User) {
    //         return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
    //     }
    //     [$data, $status] = $this->userService->activateUser($user->getId());

    //     return $this->json($data, $status);
    // }


    // addresses (location) management
    #[Route('/locations', name: 'get_locations', methods: ['GET'])]
    #[OA\Get(
        summary: "Get user's saved locations",
        description: "Retrieves all saved locations associated with the authenticated user.",
        tags: ["Buyer - Locations"],
        responses: [
            new OA\Response(
                response: 200,
                description: "User locations retrieved successfully",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(
                        ref: "#/components/schemas/LocationDTO"
                    )
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "User not found.")
                    ]
                )
            )
        ]
    )]
    public function getUserLocations(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        return $this->userService->getUserLocations($user->getId());
    }

    #[Route('/locations', name: 'add_location', methods: ['POST'])]
    #[OA\Post(
        summary: "Add a new location for the authenticated user",
        description: "Creates and saves a new location associated with the authenticated user.",
        tags: ["Buyer - Locations"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "latitude", type: "number", format: "float", example: 40.712776),
                    new OA\Property(property: "longitude", type: "number", format: "float", example: -74.005974),
                    new OA\Property(property: "street", type: "string", nullable: true, example: "123 Main St"),
                    new OA\Property(property: "city", type: "string", nullable: true, example: "New York"),
                    new OA\Property(property: "state", type: "string", nullable: true, example: "NY"),
                    new OA\Property(property: "zipCode", type: "string", nullable: true, example: "10001"),
                    new OA\Property(property: "country", type: "string", nullable: true, example: "USA"),
                    new OA\Property(property: "additionalDetails", type: "string", nullable: true, example: "Apartment 5B")
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Location added successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/LocationDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format or validation error",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format."),
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string", example: "Latitude is required.")
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "User not found.")
                    ]
                )
            )
        ]
    )]
    public function addUserLocation(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);
        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        return $this->userService->addUserLocation($user->getId(), $data);
    }

    #[Route('/locations/{locationId}', name: 'get_location', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a specific location for the authenticated user",
        description: "Retrieves details of a specific location belonging to the authenticated user by its ID.",
        tags: ["Buyer - Locations"],
        parameters: [
            new OA\Parameter(
                name: "locationId",
                in: "path",
                required: true,
                description: "The unique identifier of the location",
                schema: new OA\Schema(type: "string", format: "uuid", example: "550e8400-e29b-41d4-a716-446655440000")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Location retrieved successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/LocationDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User or Location not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Location not found."),
                    ]
                )
            )
        ]
    )]
    public function getUserLocationById(string $locationId): JsonResponse
    {
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        return $this->userService->getUserLocationById($user->getId(), $locationId);
    }


    #[Route('/locations/{locationId}', name: 'update_location', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a specific location for the authenticated user",
        description: "Updates the details of a specific location belonging to the authenticated user.",
        tags: ["Buyer - Locations"],
        parameters: [
            new OA\Parameter(
                name: "locationId",
                in: "path",
                required: true,
                description: "The unique identifier of the location",
                schema: new OA\Schema(type: "string", format: "uuid", example: "550e8400-e29b-41d4-a716-446655440000")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "latitude", type: "number", format: "float", example: 40.712776),
                    new OA\Property(property: "longitude", type: "number", format: "float", example: -74.005974),
                    new OA\Property(property: "street", type: "string", nullable: true, example: "123 Main St"),
                    new OA\Property(property: "city", type: "string", nullable: true, example: "New York"),
                    new OA\Property(property: "state", type: "string", nullable: true, example: "NY"),
                    new OA\Property(property: "zipCode", type: "string", nullable: true, example: "10001"),
                    new OA\Property(property: "country", type: "string", nullable: true, example: "USA"),
                    new OA\Property(property: "additionalDetails", type: "string", nullable: true, example: "Apartment 5B"),
                    new OA\Property(property: "default", type: "boolean", nullable: true, example: true)
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Location updated successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/LocationDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format or validation error",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format."),
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string", example: "Latitude is required.")
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User or location not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Location not found."),
                    ]
                )
            )
        ]
    )]
    public function updateUserLocation(Request $request, string $locationId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);
        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        return $this->userService->updateUserLocation($user->getId(), $locationId, $data);
    }

    #[Route('/locations/{locationId}', name: 'delete_location', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove a specific location for the authenticated user",
        description: "Deletes a location belonging to the authenticated user by its ID. The default address cannot be deleted.",
        tags: ["Buyer - Locations"],
        parameters: [
            new OA\Parameter(
                name: "locationId",
                in: "path",
                required: true,
                description: "The unique identifier of the location",
                schema: new OA\Schema(type: "string", format: "uuid", example: "550e8400-e29b-41d4-a716-446655440000")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Location removed successfully",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Location removed successfully")
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Cannot delete the default address or invalid UUID format",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Cannot delete the default address")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User or Location not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Location not found")
                    ]
                )
            )
        ]
    )]
    public function removeUserLocation(string $locationId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        return $this->userService->removeUserLocation($user->getId(), $locationId);
    }

    //ingredients
    // #[Route('/ingredients', name: 'get_all_ingredients', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Get all ingredients",
    //     description: "Fetches a paginated list of ingredients with sorting and filtering options.",
    //     tags: ["Buyer - Ingredients"],
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

    //     } catch (InvalidArgumentException | BadRequestException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     }
    // }
    // #[Route('/ingredients/{id}', name: 'get_ingredient', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Get an ingredient by ID",
    //     description: "Fetches a specific ingredient by its unique ID.",
    //     tags: ["Buyer - Ingredients"],
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

    // explore food stores list (by filters and near locations)
    #[Route('/food-stores', name: 'search_foodstores', methods: ['GET'])]
    #[OA\Get(
        summary: "Search and filter food stores",
        description: "Fetches a paginated list of food stores with sorting, filtering, and search options.",
        tags: ["Buyer - Food Stores"],
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

            $data = $this->foodStoreService->getAllFoodStores(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                $search,
                $locationFilters,
                $type,
                // @TEMPORARILY set onlyActiveStores to false
                false
            );
            return $this->json($data);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/food-stores/nearby', name: 'nearby_foodstores', methods: ['GET'])]
    #[OA\Get(
        summary: "Get nearby food stores",
        description: "Retrieves a list of food stores near the provided location within a given radius.",
        tags: ["Buyer - Food Stores"],
        parameters: [
            new OA\Parameter(
                name: "latitude",
                in: "query",
                required: true,
                description: "The latitude of the user's location",
                schema: new OA\Schema(type: "number", format: "float", example: 48.8566)
            ),
            new OA\Parameter(
                name: "longitude",
                in: "query",
                required: true,
                description: "The longitude of the user's location",
                schema: new OA\Schema(type: "number", format: "float", example: 2.3522)
            ),
            new OA\Parameter(
                name: "radiusKm",
                in: "query",
                required: false,
                description: "The search radius in kilometers (default: 10, min: 0.1, max: 100)",
                schema: new OA\Schema(type: "number", format: "float", example: 10)
            ),
            new OA\Parameter(
                name: "limit",
                in: "query",
                required: false,
                description: "The maximum number of results to return (default: default pagination limit (50))",
                schema: new OA\Schema(type: "integer", example: 50)
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "List of nearby food stores",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: new Model(type: FoodStoreDTO::class, groups: ["default"]))
                )
            ),
            new OA\Response(
                response: 400,
                description: "Invalid input parameters",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Latitude must be between -90 and 90.")
                    ]
                )
            )
        ]
    )]
    public function getNearbyFoodStores(Request $request): JsonResponse
    {
        try {
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);

            $latitude = $request->query->get('latitude');
            $longitude = $request->query->get('longitude');
            $radiusKm = $request->query->get('radiusKm', 10); // Default to 10km if not provided

            $data = $this->foodStoreService->getNearbyFoodStores(
                $limit,
                $latitude,
                $longitude,
                $radiusKm,
                // @TEMPORARILY set onlyActiveStores to false
                false
            );
            return $this->json($data);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    // @TODO use foodstore service and apply changes to admin controller aswell
    #[Route('/food-stores/{id}', name: 'get_food_store', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store details",
        description: "Retrieves detailed information about a specific food store by its ID. Only active (non-deleted) food stores can be retrieved.",
        tags: ["Buyer - Food Stores"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the food store",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with food store details",
                content: new OA\JsonContent(ref: new Model(type: FoodStoreDTO::class, groups: ["default"]))
            ),
            new OA\Response(
                response: 404,
                description: "Food store not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            )
        ]
    )]
    public function getFoodStore(string $id): JsonResponse
    {

        // @TODO check if not soft deleted after the feature is implemented
        // $foodStore = $this->foodStoreRepository->findOneBy(['id' => $id, 'isActive' => true]);

        // @TEMPORARY skip isActive check to allow viewing inactive stores
        $foodStore = $this->foodStoreRepository->findOneBy(['id' => $id]);

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], Response::HTTP_NOT_FOUND);
        }

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, Response::HTTP_OK);
    }

    // explore dishes by ingredients, categories, food stores, prices, etc
    // explore food stores dishes on detail page

    #[Route('/food-stores/{id}/dishes', name: 'get_food_store_dishes', methods: ['GET'])]
    #[OA\Get(
        summary: "Search dishes from a specific food store",
        description: "Fetches a paginated list of available dishes from a specific food store with filtering, sorting, and search options.",
        tags: ["Buyer - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the food store",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'price', 'createdAt', 'cachedAverageRating')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum price filter", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum price filter", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "ingredients", in: "query", description: "Filter by ingredient IDs (comma-separated UUIDs)", schema: new OA\Schema(type: "array", items: new OA\Items(type: "string", format: "uuid"))),
            new OA\Parameter(name: "categories", in: "query", description: "Filter by category IDs (comma-separated UUIDs)", schema: new OA\Schema(type: "array", items: new OA\Items(type: "string", format: "uuid")))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated dishes",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishDTO::class, groups: ["output"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters"),
            new OA\Response(response: 404, description: "Food store not found")
        ]
    )]
    public function getFoodStoreDishes(string $id, Request $request): JsonResponse
    {
        // @TODO check if not soft deleted after the feature is implemented
        // $foodStore = $this->foodStoreRepository->findOneBy(['id' => $id, 'isActive' => true]);
        // @TEMPORARY skip isActive check to allow viewing dishes of inactive stores
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

            //for buyer search only available dishes
            $available = true;
            // $available = $request->query->get('available', true);

            $ingredients = $request->query->all('ingredients');
            $categories = $request->query->all('categories');

            $foodStoreId = $foodStore->getId();

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
                // @TEMPORARY allow the display of inactive food store dishes
                false
            );
            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/dishes', name: 'search_dishes', methods: ['GET'])]
    #[OA\Get(
        summary: "Search and filter all available dishes",
        description: "Fetches a paginated list of all available dishes from all food stores with sorting, filtering, and searching options. Buyers can only see available dishes.",
        tags: ["Buyer - Dishes"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'price', 'createdAt', 'cachedAverageRating')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string", minimum: 3)),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum price filter", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum price filter", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "ingredients", in: "query", description: "Filter by ingredient IDs (comma-separated UUIDs)", schema: new OA\Schema(type: "array", items: new OA\Items(type: "string", format: "uuid"))),
            new OA\Parameter(name: "categories", in: "query", description: "Filter by category IDs (comma-separated UUIDs)", schema: new OA\Schema(type: "array", items: new OA\Items(type: "string", format: "uuid")))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated dishes",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishDTO::class, groups: ["output"]))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters")
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

            $foodStoreId = $request->query->get('foodStoreId', null);

            //for buyer search only available dishes
            $available = true;
            // $available = $request->query->get('available', true);

            $ingredients = $request->query->all('ingredients');
            $categories = $request->query->all('categories');

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
                // @TEMPORARY allow the display of inactive food store dishes
                false
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/dishes/{id}', name: 'get_dish', methods: ['GET'])]
    #[OA\Get(
        summary: "Get dish details",
        description: "Fetches the details of a single dish by its ID. Only available dishes can be retrieved by a buyer.",
        tags: ["Buyer - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with dish details",
                content: new OA\JsonContent(ref: new Model(type: DishDetailDTO::class, groups: ["output"]))
            ),
            new OA\Response(response: 404, description: "Dish not found")
        ]
    )]
    public function getDish(string $id): JsonResponse
    {
        // buyer can only access available dishes
        $dish = $this->dishRepository->findAvailableById($id);
        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }
        $dishDto = $this->dishMapper->mapToDetailDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_OK);
    }

    // add dish to cart, manage ingredients, manage quantity, remove dish from cart, cart management
    #[Route('/cart', name: 'get_cart', methods: ['GET'])]
    #[OA\Get(
        summary: "Get buyer's active cart",
        description: "Retrieves the buyer's unarchived cart, including the list of dishes and the total price. If no cart exists, a new one is created.",
        tags: ["Buyer - Cart"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with cart details",
                content: new OA\JsonContent(ref: new Model(type: CartDTO::class, groups: ["output"]))
            ),
            new OA\Response(
                response: 401,
                description: "Unauthorized - Buyer not authenticated"
            )
        ]
    )]
    public function getCart(): JsonResponse
    {
        // Implementation: Retrieve the buyer's unarchived cart, return cart details.
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        $cart = $this->cartRepository->findOneBy([
            'buyer' => $user,
            'archived' => false,
        ]);

        if (!$cart instanceof Cart) {
            $cart = new Cart($user);
            $this->entityManager->persist($cart);
            $this->entityManager->flush();
        }

        $cartDishes = $this->cartDishRepository->findCartDishesWithIngredients($cart);

        // $cartDishesDTOs = $this->cartDishMapper->mapToDTOs($cartDishes);
        // return $this->json($cartDishesDTOs, JsonResponse::HTTP_OK);

        $cartDTO = $this->cartMapper->mapToDTO($cart, $cartDishes);

        return $this->json($cartDTO, JsonResponse::HTTP_OK);
    }

    #[Route('/cart/dishes', name: 'add_dish_to_cart', methods: ['POST'])]
    #[OA\Post(
        summary: "Add a dish to the cart",
        description: "Adds a dish to the buyer's unarchived cart. If no active cart exists, a new one is created. If the dish is unavailable, the request fails.",
        tags: ["Buyer - Cart"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                required: ["dishId"],
                properties: [
                    new OA\Property(
                        property: "dishId",
                        type: "string",
                        format: "uuid",
                        description: "UUID of the dish to add"
                    ),
                    new OA\Property(
                        property: "quantity",
                        type: "integer",
                        minimum: 1,
                        maximum: ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_QUANTITY,
                        description: "Quantity of the dish (default is 1, must be within allowed limits)"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Dish successfully added to cart"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid data or dish is unavailable"
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found"
            )
        ]
    )]
    public function addDishToCart(Request $request): JsonResponse
    {
        // Implementation: Validate dishId, check availability, add to cart.
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        if ($data == null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $maximumQuantity = ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_QUANTITY;

        if (!isset($data['dishId'])) {
            return $this->json(['error' => 'Invalid request data'], Response::HTTP_BAD_REQUEST);
        }

        // if quantity is not set, we set it to default value 1
        $quantity = $data['quantity'] ?? 1;

        if (!is_numeric($quantity) || (int) $quantity < 1 || (int) $quantity > $maximumQuantity) {
            throw new InvalidArgumentException("Quantity must be a valid integer between 1 and $maximumQuantity.");
        }

        $quantity = (int) $quantity;


        $dishId = $data['dishId'];
        if (!ValidationHelper::isCorrectUuid($dishId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $dish = $this->dishRepository->findAvailableById($data['dishId']);
        if (!$dish instanceof Dish) {
            return $this->json(['error' => 'Dish not found'], Response::HTTP_NOT_FOUND);
        }

        if (!$dish->isAvailable()) {
            return $this->json(['error' => 'Dish is not available'], Response::HTTP_BAD_REQUEST);
        }

        $cart = $this->cartRepository->findOneBy([
            'buyer' => $user,
            'archived' => false,
        ]);

        if (!$cart instanceof Cart) {
            $cart = new Cart($user);
            $this->entityManager->persist($cart);
        }

        // We allow duplicates of the same dish in the cart because CartDishIngredients may differ.
        $cartDish = new CartDish($cart, $dish, $quantity);
        $this->entityManager->persist($cartDish);

        $this->entityManager->flush();

        return $this->json(['message' => 'Dish added to cart'], JsonResponse::HTTP_CREATED);
    }

    #[Route('/cart/dishes/{cartDishId}', name: 'update_cart_dish_quantity', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update cart dish quantity",
        description: "Updates the quantity of a specific dish in the buyer's cart. The cart must be unarchived and belong to the current user.",
        tags: ["Buyer - Cart"],
        parameters: [
            new OA\Parameter(
                name: "cartDishId",
                in: "path",
                required: true,
                description: "UUID of the cart dish to update",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                required: ["quantity"],
                properties: [
                    new OA\Property(
                        property: "quantity",
                        type: "integer",
                        minimum: 1,
                        maximum: ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_QUANTITY,
                        description: "New quantity for the dish (must be within allowed limits)"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Cart dish quantity successfully updated"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid data or quantity out of range"
            ),
            new OA\Response(
                response: 403,
                description: "Unauthorized - The cart belongs to another user or is archived"
            ),
            new OA\Response(
                response: 404,
                description: "Cart dish not found or user not authenticated"
            )
        ]
    )]
    public function updateCartDishQuantity(string $cartDishId, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($cartDishId)) {
            return $this->json(['error' => 'Invalid UUID format'], Response::HTTP_BAD_REQUEST);
        }

        $cartDish = $this->cartDishRepository->find($cartDishId);
        if (!$cartDish instanceof CartDish) {
            return $this->json(['error' => 'Cart dish not found'], Response::HTTP_NOT_FOUND);
        }

        // Ensure the cart belongs to the current user and is not archived
        if ($cartDish->getCart()->getBuyer() !== $user || $cartDish->getCart()->isArchived()) {
            return $this->json(['error' => 'Unauthorized or archived cart'], Response::HTTP_FORBIDDEN);
        }

        $data = $this->getRequestData($request);

        if ($data === null || !isset($data['quantity'])) {
            return $this->json(['error' => 'Invalid request payload.'], Response::HTTP_BAD_REQUEST);
        }

        $maximumQuantity = ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_QUANTITY;

        if (!is_numeric($data['quantity']) || (int) $data['quantity'] < 1 || (int) $data['quantity'] > $maximumQuantity) {
            return $this->json(['error' => "Quantity must be a valid integer between 1 and $maximumQuantity."], Response::HTTP_BAD_REQUEST);
        }

        $quantity = (int) $data['quantity'];

        $cartDish->setQuantity($quantity);
        $this->entityManager->flush();

        return $this->json(['message' => 'Cart dish quantity updated'], JsonResponse::HTTP_OK);
    }

    #[Route('/cart/dishes/{cartDishId}', name: 'remove_cart_dish', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove a dish from the cart",
        description: "Deletes a specific dish from the buyer's cart. The cart must be unarchived and belong to the current user.",
        tags: ["Buyer - Cart"],
        parameters: [
            new OA\Parameter(
                name: "cartDishId",
                in: "path",
                required: true,
                description: "UUID of the cart dish to remove",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Dish successfully removed from the cart"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format"
            ),
            new OA\Response(
                response: 403,
                description: "Unauthorized - The cart belongs to another user or is archived"
            ),
            new OA\Response(
                response: 404,
                description: "Cart dish not found or user not authenticated"
            )
        ]
    )]
    public function removeCartDish(string $cartDishId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($cartDishId)) {
            return $this->json(['error' => 'Invalid UUID format'], Response::HTTP_BAD_REQUEST);
        }

        $cartDish = $this->cartDishRepository->find($cartDishId);
        if (!$cartDish instanceof CartDish) {
            return $this->json(['error' => 'Cart dish not found'], Response::HTTP_NOT_FOUND);
        }

        // Ensure the cart belongs to the current user and is not archived
        if ($cartDish->getCart()->getBuyer() !== $user || $cartDish->getCart()->isArchived()) {
            return $this->json(['error' => 'Unauthorized or archived cart'], Response::HTTP_FORBIDDEN);
        }

        $this->entityManager->remove($cartDish);
        $this->entityManager->flush();

        return $this->json([], JsonResponse::HTTP_NO_CONTENT);
    }

    #[Route('/cart/dishes/{cartDishId}/ingredients', name: 'add_cart_dish_ingredient', methods: ['POST'])]
    #[OA\Post(
        summary: "Add an ingredient to a dish in the cart",
        description: "Adds a supplementary ingredient to a specific dish in the buyer's cart. If the ingredient already exists, its quantity is updated.",
        tags: ["Buyer - Cart"],
        parameters: [
            new OA\Parameter(
                name: "cartDishId",
                in: "path",
                required: true,
                description: "UUID of the cart dish to add an ingredient to",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Data for adding an ingredient to the cart dish",
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "dishIngredientId",
                        type: "string",
                        format: "uuid",
                        description: "UUID of the dish ingredient to add",
                    ),
                    new OA\Property(
                        property: "quantity",
                        type: "integer",
                        minimum: 1,
                        maximum: ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_INGREDIENT_QUANTITY,
                        description: "Quantity of the ingredient (default: 1)"
                    ),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Ingredient added successfully"
            ),
            new OA\Response(
                response: 200,
                description: "quantity updated (Ingredient already added to cartDish)"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid data, non-supplement ingredient, or exceeded quantity"
            ),
            new OA\Response(
                response: 403,
                description: "Unauthorized - The cart dish does not belong to the user"
            ),
            new OA\Response(
                response: 404,
                description: "Cart dish or ingredient not found, or does not belong to the dish"
            )
        ]
    )]
    public function addCartDishIngredient(string $cartDishId, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);
        if ($data == null || !isset($data['dishIngredientId'])) {
            return $this->json(['error' => 'Invalid request data'], Response::HTTP_BAD_REQUEST);
        }

        $dishIngredientId = $data['dishIngredientId'];
        if (!ValidationHelper::isCorrectUuid($dishIngredientId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        // Default quantity = 1 if not set
        $quantity = isset($data['quantity']) ? (int) $data['quantity'] : 1;
        $maximumQuantity = ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_INGREDIENT_QUANTITY;

        if ($quantity < 1 || $quantity > $maximumQuantity) {
            throw new InvalidArgumentException("Quantity must be a valid integer between 1 and $maximumQuantity.");
        }

        // Find the CartDish
        $cartDish = $this->cartDishRepository->find($cartDishId);
        if (!$cartDish instanceof CartDish) {
            return $this->json(['error' => 'Cart dish not found'], Response::HTTP_NOT_FOUND);
        }

        if ($cartDish->getCart()->getBuyer() !== $user) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_FORBIDDEN);
        }

        $dishIngredient = $this->dishIngredientRepository->findOneBy([
            'id' => $dishIngredientId,
            'dish' => $cartDish->getDish(),
        ]);

        if (!$dishIngredient instanceof DishIngredient) {
            return $this->json(['error' => 'Ingredient not found or does not belong to this dish'], Response::HTTP_NOT_FOUND);
        }

        if (!$dishIngredient->isAvailable()) {
            return $this->json(['error' => 'Ingredient is not available'], Response::HTTP_BAD_REQUEST);
        }

        if (!$dishIngredient->isSupplement()) {
            return $this->json(['error' => 'Ingredient is not a supplement'], Response::HTTP_BAD_REQUEST);
        }


        $cartDishIngredient = $this->cartDishIngredientRepository->findOneBy([
            'cartDish' => $cartDish,
            'dishIngredient' => $dishIngredient
        ]);

        if ($cartDishIngredient instanceof CartDishIngredient) {
            // If ingredient already exists in the cart dish, update its quantity instead of creating a new one
            $newQuantity = $cartDishIngredient->getQuantity() + $quantity;
            if ($newQuantity > $maximumQuantity) {
                throw new InvalidArgumentException("New quantity shouldn't exceed $maximumQuantity.");
            }

            $cartDishIngredient->setQuantity($newQuantity);
            $this->entityManager->flush();

            return $this->json(['message' => 'Cart Dish Ingredient quantity updated']);
        }

        // Create a new CartDishIngredient
        $cartDishIngredient = new CartDishIngredient($cartDish, $dishIngredient, $quantity);
        $this->entityManager->persist($cartDishIngredient);
        $this->entityManager->flush();

        return $this->json(['message' => 'Ingredient added to cart dish'], Response::HTTP_CREATED);
    }

    #[Route('/cart/dishes/{cartDishId}/ingredients/{dishIngredientId}', name: 'update_cart_dish_ingredient_quantity', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update the quantity of an ingredient in a cart dish",
        description: "Updates the quantity of a specific supplementary ingredient in a cart dish.",
        tags: ["Buyer - Cart"],
        parameters: [
            new OA\Parameter(
                name: "cartDishId",
                in: "path",
                required: true,
                description: "UUID of the cart dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "dishIngredientId",
                in: "path",
                required: true,
                description: "UUID of the dish ingredient (please note: dishIngredientId and not cartDishIngredientId)",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Quantity update payload",
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "quantity",
                        type: "integer",
                        minimum: 1,
                        maximum: ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_INGREDIENT_QUANTITY,
                        description: "New quantity for the cart dish ingredient"
                    )
                ],
                required: ["quantity"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Ingredient quantity updated"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid quantity or payload"
            ),
            new OA\Response(
                response: 403,
                description: "Unauthorized or archived cart"
            ),
            new OA\Response(
                response: 404,
                description: "Cart dish or ingredient not found"
            )
        ]
    )]
    public function updateCartDishIngredientQuantity(string $cartDishId, string $dishIngredientId, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($cartDishId) || !ValidationHelper::isCorrectUuid($dishIngredientId)) {
            return $this->json(['error' => 'Invalid UUID format'], Response::HTTP_BAD_REQUEST);
        }

        $cartDish = $this->cartDishRepository->find($cartDishId);
        if (!$cartDish instanceof CartDish) {
            return $this->json(['error' => 'Cart dish not found'], Response::HTTP_NOT_FOUND);
        }

        if ($cartDish->getCart()->getBuyer() !== $user || $cartDish->getCart()->isArchived()) {
            return $this->json(['error' => 'Unauthorized or archived cart'], Response::HTTP_FORBIDDEN);
        }

        $data = $this->getRequestData($request);
        if ($data === null || !isset($data['quantity'])) {
            return $this->json(['error' => 'Invalid request payload.'], Response::HTTP_BAD_REQUEST);
        }

        $maximumQuantity = ValidationHelper::MAXIMUM_ALLOWED_CART_DISH_INGREDIENT_QUANTITY;

        if (!is_numeric($data['quantity']) || (int) $data['quantity'] < 1 || (int) $data['quantity'] > $maximumQuantity) {
            return $this->json(['error' => "Quantity must be a valid integer between 1 and $maximumQuantity."], Response::HTTP_BAD_REQUEST);
        }

        $quantity = (int) $data['quantity'];

        $cartDishIngredient = $this->cartDishIngredientRepository->findOneBy([
            'cartDish' => $cartDish,
            'dishIngredient' => $dishIngredientId,
        ]);

        if (!$cartDishIngredient instanceof CartDishIngredient) {
            return $this->json(['error' => 'Cart dish ingredient not found'], Response::HTTP_NOT_FOUND);
        }

        $cartDishIngredient->setQuantity($quantity);
        $this->entityManager->flush();

        return $this->json(['message' => 'Cart dish ingredient quantity updated'], JsonResponse::HTTP_OK);
    }

    #[Route('/cart/dishes/{cartDishId}/ingredients/{dishIngredientId}', name: 'remove_cart_dish_ingredient', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove an ingredient from a cart dish",
        description: "Removes a specific supplementary ingredient from a cart dish.",
        tags: ["Buyer - Cart"],
        parameters: [
            new OA\Parameter(
                name: "cartDishId",
                in: "path",
                required: true,
                description: "UUID of the cart dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "dishIngredientId",
                in: "path",
                required: true,
                description: "UUID of the dish ingredient",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Ingredient removed successfully"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format"
            ),
            new OA\Response(
                response: 403,
                description: "Unauthorized or archived cart"
            ),
            new OA\Response(
                response: 404,
                description: "Cart dish or ingredient not found"
            )
        ]
    )]
    public function removeCartDishIngredient(string $cartDishId, string $dishIngredientId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if (!ValidationHelper::isCorrectUuid($cartDishId) || !ValidationHelper::isCorrectUuid($dishIngredientId)) {
            return $this->json(['error' => 'Invalid UUID format'], Response::HTTP_BAD_REQUEST);
        }

        $cartDish = $this->cartDishRepository->find($cartDishId);
        if (!$cartDish instanceof CartDish) {
            return $this->json(['error' => 'Cart dish not found'], Response::HTTP_NOT_FOUND);
        }

        if ($cartDish->getCart()->getBuyer() !== $user || $cartDish->getCart()->isArchived()) {
            return $this->json(['error' => 'Unauthorized or archived cart'], Response::HTTP_FORBIDDEN);
        }

        $cartDishIngredient = $this->cartDishIngredientRepository->findOneBy([
            'cartDish' => $cartDish,
            'dishIngredient' => $dishIngredientId,
        ]);

        if (!$cartDishIngredient instanceof CartDishIngredient) {
            return $this->json(['error' => 'Cart dish ingredient not found'], Response::HTTP_NOT_FOUND);
        }

        $this->entityManager->remove($cartDishIngredient);
        $this->entityManager->flush();

        return $this->json([], Response::HTTP_NO_CONTENT);
    }

    // make order. cart items will be grouped by foodstore for orders
    #[Route('/cart/checkout', name: 'checkout', methods: ['POST'])]
    #[OA\Post(
        summary: "Checkout and create orders from cart",
        description: "Converts the buyer's cart into one or more orders grouped by food store. Each food store's dishes become a separate order. The cart is archived after successful checkout.",
        tags: ["Buyer - Cart"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "deliveryMethod",
                        type: "string",
                        enum: ["pickup", "delivery"],
                        description: "Preferred delivery method. Will be validated against store capabilities."
                    ),
                    new OA\Property(
                        property: "locationId",
                        type: "string",
                        format: "uuid",
                        description: "Location ID for delivery (required if deliveryMethod is 'Delivery')"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Orders created successfully",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: new Model(type: OrderDetailDTO::class))
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Empty cart, invalid delivery method, or missing location"
            ),
            new OA\Response(
                response: 404,
                description: "User or location not found"
            )
        ]
    )]
    public function checkout(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);
        if ($data == null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $requestedDeliveryMethod = OrderDeliveryMethod::tryFrom($data['deliveryMethod'] ?? '') ?? OrderDeliveryMethod::Pickup; // Default to pickup if not provided or invalid

        $location = null;
        if ($requestedDeliveryMethod === OrderDeliveryMethod::Delivery) {
            if (!isset($data['locationId'])) {
                return $this->json(['error' => 'Location is required for delivery'], Response::HTTP_BAD_REQUEST);
            }

            $locationId = $data['locationId'];
            if (!ValidationHelper::isCorrectUuid($locationId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $location = $this->userService->getUserLocationEntityById($user->getId(), $locationId);
        }

        $cart = $this->cartRepository->findOneBy([
            'buyer' => $user,
            'archived' => false,
        ]);

        if (!$cart instanceof Cart) {
            return $this->json(['error' => 'No cart to checkout'], Response::HTTP_BAD_REQUEST);
        }

        $cartDishes = $this->cartDishRepository->findCartDishesWithIngredients($cart);

        if (count($cartDishes) < 1) {
            return $this->json(['error' => 'Empty cart'], Response::HTTP_BAD_REQUEST);
        }

        // cart items will be grouped by foodstore for orders, so multiple orders may be created
        // create orders,

        $ordersByStore = [];

        foreach ($cartDishes as $cartDish) {
            if ($cartDish instanceof CartDish) {
                $dish = $cartDish->getDish();
                $foodStore = $dish->getFoodStore();
                $storeId = $foodStore->getId();

                if (!isset($ordersByStore[$storeId])) {
                    $ordersByStore[$storeId] = [
                        'store' => $foodStore,
                        'cartDishes' => [],
                    ];
                }
                $ordersByStore[$storeId]['cartDishes'][] = $cartDish;
            }
        }

        $createdOrders = [];

        foreach ($ordersByStore as $storeOrders) {
            $foodStore = $storeOrders['store'];
            $cartDishes = $storeOrders['cartDishes'];

            $finalDeliveryMethod = match ($foodStore->getDeliveryOption()) {
                StoreDeliveryOption::PickupOnly => OrderDeliveryMethod::Pickup,
                StoreDeliveryOption::Both => $requestedDeliveryMethod,
            };

            $deliveryLocation = $finalDeliveryMethod === OrderDeliveryMethod::Delivery
                ? $location
                : $foodStore->getLocation();

            // Final safety check - ensure we have a location for the order
            if (!$deliveryLocation instanceof Location) {
                // This should only happen if:
                // 1. It's a pickup order AND 
                // 2. The store has no location set
                continue;
                // Alternatively return error:
                // return $this->json(['error' => 'Store location not configured'], 400);
            }

            $order = new Order($user, $cart, $foodStore, $deliveryLocation);
            $order->setDeliveryMethod($finalDeliveryMethod);

            $totalPrice = BigDecimal::zero();

            foreach ($cartDishes as $cartDish) {

                $priceDetails = $this->cartService->calculateCartDishPrices($cartDish);

                $dish = $cartDish->getDish();

                $orderDishUnitPrice = $dish->getBasePrice();
                $orderDishQuantity = $cartDish->getQuantity();

                $orderDishTotalPrice = $priceDetails['totalPrice'];
                $orderDishSubtotalPrice = $priceDetails['dishSubtotal'];

                $totalPrice = $totalPrice->plus($orderDishTotalPrice);


                $orderDish = new OrderDish(
                    $order,
                    $cartDish,
                    $orderDishUnitPrice,
                    MoneyHelper::decimalToString($orderDishSubtotalPrice),
                    MoneyHelper::decimalToString($orderDishTotalPrice),
                    $orderDishQuantity
                );

                foreach ($cartDish->getIngredients() as $cartDishIngredient) {
                    if ($cartDishIngredient instanceof CartDishIngredient) {
                        $dishIngredient = $cartDishIngredient->getDishIngredient();
                        $dishIngredientPrice = $dishIngredient->getPrice();
                        $dishIngredientQuantity = $cartDishIngredient->getQuantity();
                        $orderDishIngredient = new OrderDishIngredient($orderDish, $cartDishIngredient, $dishIngredientPrice, $dishIngredientQuantity);
                        $this->entityManager->persist($orderDishIngredient);
                    }
                }

                $this->entityManager->persist($orderDish);
            }
            $order->setTotalPrice($totalPrice);
            // TODO: make it according to buyer's region
            $taxData = $this->taxCalculator->calculate($totalPrice, 'quebec');
            $order->setTaxTotal($taxData['taxTotal']);
            $order->setGrossTotal($taxData['grossTotal']);
            $order->setAppliedTaxes($taxData['appliedTaxes']);

            $this->entityManager->persist($order);
            $createdOrders[] = $order;
        }

        // Archive cart
        $cart->setArchived(true);
        $this->entityManager->flush();

        // Notify sellers about new orders
        foreach ($createdOrders as $createdOrder) {
            $this->orderService->createAndSendNotification(
                $user,
                $createdOrder->getStore()->getSeller(),
                'New Order Received',
                'You have a new order #' . $createdOrder->getOrderNumber() . ' from ' . $user->getFirstName() . '.',
                'Nouvelle commande reçue',
                'Vous avez une nouvelle commande #' . $createdOrder->getOrderNumber() . ' de ' . $user->getFirstName() . '.',
                $createdOrder->getId()
            );
        }


        $createdOrdersDTOs = $this->orderMapper->mapToDTOs($createdOrders);

        return $this->json($createdOrdersDTOs, JsonResponse::HTTP_OK);
    }

    // search orders ( order history )
    #[Route('/orders', name: 'orders', methods: ['GET'])]
    #[OA\Get(
        summary: "Search buyer's orders",
        description: "Retrieves a paginated list of the authenticated buyer's orders with filtering by status, payment status, delivery status, and other criteria.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'createdAt', 'updatedAt')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term for order number or details", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "minPrice", in: "query", description: "Minimum order total price", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "maxPrice", in: "query", description: "Maximum order total price", schema: new OA\Schema(type: "number", format: "float", minimum: 0)),
            new OA\Parameter(name: "foodStoreId", in: "query", description: "Filter by food store UUID", schema: new OA\Schema(type: "string", format: "uuid")),
            new OA\Parameter(name: "status", in: "query", description: "Filter by order status (Pending, Confirmed, Completed, Cancelled)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "paymentStatus", in: "query", description: "Filter by payment status (Pending, Processing, Paid, Failed, Refunded, RefundRequested, RefundFailed)", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "deliveryStatus", in: "query", description: "Filter by delivery status (Pending, Transit, Delivered)", schema: new OA\Schema(type: "string"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated orders",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: OrderDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid status or parameters"),
            new OA\Response(response: 404, description: "User not found")
        ]
    )]
    public function getOrders(Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }
            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $minPrice = $request->query->get('minPrice', null);
            $maxPrice = $request->query->get('maxPrice', null);

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
                $user->getId(),
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

    // get single order
    #[Route('/orders/{id}', name: 'order_detail', methods: ['GET'])]
    #[OA\Get(
        summary: "Get order details",
        description: "Retrieves complete details of a specific order by its ID. The authenticated buyer can only access their own orders.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with order details",
                content: new OA\JsonContent(ref: new Model(type: OrderDetailDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID format"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order")
        ]
    )]
    public function getOrder(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getBuyer() !== $user) {
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

    // pay order
    #[Route('/orders/{id}/pay', name: 'order_pay', methods: ['POST'])]
    #[OA\Post(
        summary: "Initiate payment for an order",
        description: "Creates a Stripe PaymentIntent for the order total. The payment is not confirmed yet; the client must confirm it using the client_secret. Only pending or processing orders can be paid.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Payment initiated successfully",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "paymentResponse",
                            type: "object",
                            properties: [
                                new OA\Property(property: "client_secret", type: "string", description: "Stripe client_secret for confirming payment"),
                                new OA\Property(property: "payment_intent_id", type: "string", description: "Stripe PaymentIntent ID"),
                                new OA\Property(property: "publishable_key", type: "string", description: "Stripe publishable key")
                            ]
                        ),
                        new OA\Property(property: "order", ref: new Model(type: OrderDetailDTO::class))
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID or order state"),
            new OA\Response(response: 402, description: "Payment required - Stripe card error"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order"),
            new OA\Response(response: 409, description: "Conflict - Order is already paid or in invalid state")
        ]
    )]
    public function payOrder(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }


            // ownership validation before the lock transaction
            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getBuyer() !== $user) {
                throw new NotFoundHttpException('Order not found');
            }

            $paymentIntent = null;

            $this->entityManager->beginTransaction();
            try {
                $order = $this->orderRepository->find($id, LockMode::PESSIMISTIC_WRITE);

                $this->orderService->validateOrderStateForPayment($order);

                $orderTotalPrice = $order->getTotalPrice();
                $orderGrossTotal = $order->getGrossTotal();
                $orderCurrency = $order->getCurrency();
                $orderNumber = $order->getOrderNumber();

                $orderGrossTotalInCents = MoneyHelper::toStripeAmount($orderGrossTotal);

                // Create but don't confirm the PaymentIntent yet
                $paymentIntent = $this->stripeService->createPaymentIntent(
                    amount: $orderGrossTotalInCents,
                    currency: $orderCurrency,
                    metadata: [
                        'payment_type' => 'order',
                        'order_id' => $id,
                        'order_number' => $orderNumber,
                        'buyer_id' => $user->getId(),
                        'order_subtotal' => $orderTotalPrice,
                        'order_gross_total' => $orderGrossTotal,
                    ],
                );

                $order->setStripePaymentIntentId($paymentIntent->id);
                $order->setPaymentStatus(OrderPaymentStatus::Processing);
                $this->entityManager->persist($order);
                $this->entityManager->flush();
                $this->entityManager->commit();
            } catch (\Throwable $e) {
                $this->entityManager->rollback();
                throw $e;
            }

            // Notify seller that buyer has paid for the order
            $this->orderService->createAndSendNotification(
                $order->getBuyer(),
                $order->getStore()->getSeller(),
                'New Order Payment',
                'Customer ' . $order->getBuyer()->getFirstName() . ' has paid for order ' . $order->getOrderNumber() . '. Please confirm the order.',
                'Nouveau paiement',
                'Le client ' . $order->getBuyer()->getFirstName() . ' a paye la commande ' . $order->getOrderNumber() . '. Veuillez confirmer la commande.',
                $order->getId()
            );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order);

            $paymentResponse = [
                'paymentResponse' => [
                    'client_secret' => $paymentIntent->client_secret,
                    'payment_intent_id' => $paymentIntent->id,
                    'publishable_key' => $this->stripeService->getPublishableKey(),
                ],
                'order' => $orderDTO,
            ];
            return $this->json($paymentResponse, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException | BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (CardException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_PAYMENT_REQUIRED);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe API error during payment initiation', [
                'order_id' => $id,
                'stripe_error' => $e->getMessage(),
                'stripe_code' => $e->getStripeCode(),
            ]);
            return $this->json(
                ['error' => 'Payment service is temporarily unavailable. Please try again later.'],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    // Cancel order
    #[Route('/orders/{id}/cancel', name: 'order_cancel', methods: ['POST'])]
    #[OA\Post(
        summary: "Cancel an order",
        description: "Cancels an order and initiates a refund if payment was made. Orders in transit or already delivered cannot be cancelled. Completed or already cancelled orders also cannot be cancelled.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Order cancelled successfully",
                content: new OA\JsonContent(ref: new Model(type: OrderDetailDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID or order cannot be cancelled"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order"),
            new OA\Response(response: 409, description: "Conflict - Order already cancelled or in invalid state")
        ]
    )]
    public function cancelOrder(string $id, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getBuyer() !== $user) {
                throw new NotFoundHttpException('Order not found');
            }


            $this->orderService->requestRefund($order, USER::TYPE_BUYER);
            $this->twilioProxyService->closeProxySession($order);

            $this->entityManager->flush();


            // Notify seller that buyer cancelled the order
            // $this->orderService->createAndSendNotification(
            //     $order->getBuyer(),
            //     $order->getStore()->getSeller(),
            //     'Order Cancelled',
            //     'Order ' . $order->getOrderNumber() . ' has been cancelled by the customer.',
            //     'Commande annulee',
            //     'La commande ' . $order->getOrderNumber() . ' a ete annulee par le client.',
            //     $order->getId()
            // );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order);
            return $this->json($orderDTO, JsonResponse::HTTP_OK);
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


    #[Route('/orders/{id}/note', name: 'upsert_order_note', methods: ['POST'])]
    #[OA\Post(
        summary: "Add or update order note",
        description: "Adds or updates a buyer's note for an order. Notes can only be added to pending or confirmed orders, not to completed or cancelled orders.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "note",
                        type: "string",
                        nullable: true,
                        minLength: 3,
                        maxLength: 1000,
                        description: "Order note (3-1000 characters, must contain at least one alphanumeric character)"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Note saved successfully",
                content: new OA\JsonContent(ref: new Model(type: OrderDetailDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid note format or order state"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order")
        ]
    )]
    public function upsertOrderNote(Request $request, string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $order = $this->orderRepository->findOneBy([
                'id' => $id,
                'buyer' => $user
            ]);

            if (!$order instanceof Order) {
                throw new NotFoundHttpException('Order not found');
            }

            if ($order->getStatus() === OrderStatus::Cancelled) {
                throw new BadRequestHttpException('Note for cancelled orders cannot be updated');
            }

            if ($order->getStatus() === OrderStatus::Completed) {
                throw new BadRequestHttpException('Note for completed orders cannot be updated');
            }

            // Get and validate request data
            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'note' => [
                        new Assert\Optional([
                            new Assert\Type('string'),
                            new Assert\Length([
                                'min' => 3,
                                'max' => 1000,
                                'minMessage' => 'Note must be at least {{ limit }} characters long',
                                'maxMessage' => 'Note cannot be longer than {{ limit }} characters',
                            ]),
                            new Assert\Regex([
                                'pattern' => '/[a-zA-Z0-9]/',
                                'message' => 'Note must contain at least one alphanumeric character',
                            ])
                        ])
                    ]
                ],
                'allowExtraFields' => false,
                'allowMissingFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $order->setBuyerNote($data['note'] ?? null);
            $this->entityManager->flush();

            return $this->json($this->orderMapper->mapToDetailDTO($order));
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }



    #[OA\Post(
        summary: "Add a tip to a completed order",
        description: "Allows the buyer to add a tip to a completed order. 
            A Stripe PaymentIntent is created for the tip amount. 
            Tips can only be added to completed orders, and only one active 
            payment attempt is allowed at a time.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                description: "Order UUID",
                in: "path",
                required: true,
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                required: ["tip"],
                properties: [
                    new OA\Property(
                        property: "tip",
                        type: "number",
                        format: "float",
                        minimum: 1,
                        maximum: 100,
                        example: 15.50,
                        description: "Tip amount in the order currency (between 1 and 100)."
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Tip payment initiated successfully.",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "paymentResponse",
                            type: "object",
                            properties: [
                                new OA\Property(
                                    property: "client_secret",
                                    type: "string",
                                    description: "Stripe client_secret for confirming the PaymentIntent"
                                ),
                                new OA\Property(
                                    property: "payment_intent_id",
                                    type: "string",
                                    description: "Stripe PaymentIntent ID"
                                ),
                                new OA\Property(
                                    property: "publishable_key",
                                    type: "string",
                                    description: "Stripe publishable key used by the frontend"
                                )
                            ]
                        ),
                        new OA\Property(
                            property: "order",
                            ref: new Model(type: OrderDetailDTO::class)
                        )
                    ]
                )
            ),

            new OA\Response(
                response: 400,
                description: "Bad Request — Validation failed or order cannot accept tips.",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Order is not completed yet. Tips can only be added to completed orders."
                        ),
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string"),
                            example: ["Tip must be at least 1."]
                        )
                    ]
                )
            ),

            new OA\Response(
                response: 404,
                description: "Order not found or the buyer does not own the order.",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Order not found."
                        )
                    ]
                )
            ),

            new OA\Response(
                response: 409,
                description: "Conflict — A tip has already been paid, or a PaymentIntent is already in progress.",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Order tip has already been paid (Stripe verification)."
                        )
                    ]
                )
            ),

            new OA\Response(
                response: 402,
                description: "Payment required — Stripe card error or payment failure.",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Your card was declined."
                        )
                    ]
                )
            )
        ]
    )]
    #[Route('/orders/{id}/tip', name: 'order_tip_pay', methods: ['POST'])]
    public function payTip(string $id, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getBuyer() !== $user) {
                throw new NotFoundHttpException('Order not found');
            }

            $this->orderService->validateOrderStateForTipPayment($order);

            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                "fields" => [
                    'tip' => [
                        new Assert\NotBlank(),
                        new Assert\Type('numeric'),
                        new Assert\Positive(),
                        new Assert\GreaterThanOrEqual(1),
                        new Assert\LessThanOrEqual(100)
                    ],
                ],
                "allowMissingFields" => false,
            ]);

            $errors = $this->validator->validate($data, $constraints);

            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $tipAmount = MoneyHelper::normalize($data['tip']);
            $order->setTipAmount($tipAmount);
            $orderCurrency = $order->getCurrency();
            $orderNumber = $order->getOrderNumber();

            $orderTipAmountInCents = MoneyHelper::toStripeAmount($tipAmount);

            // Create but don't confirm the PaymentIntent yet
            $paymentIntent = $this->stripeService->createPaymentIntent(
                amount: $orderTipAmountInCents,
                currency: $orderCurrency,
                metadata: [
                    'payment_type' => 'tip',
                    'order_id' => $id,
                    'order_number' => $orderNumber,
                    'buyer_id' => $user->getId(),
                    'tip_amount' => $tipAmount,
                ],
            );

            $order->setTipStripePaymentIntentId($paymentIntent->id);
            $order->setTipPaymentStatus(OrderTipPaymentStatus::Processing);
            $this->entityManager->persist($order);
            $this->entityManager->flush();

            $response = [
                'client_secret' => $paymentIntent->client_secret,
                'payment_intent_id' => $paymentIntent->id,
                'publishable_key' => $this->stripeService->getPublishableKey(),
            ];

            $orderDTO = $this->orderMapper->mapToDetailDTO($order);
            $paymentResponse = [
                'paymentResponse' => $response,
                'order' => $orderDTO,
            ];
            return $this->json($paymentResponse, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException | BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (CardException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_PAYMENT_REQUIRED);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/orders/{id}/resend-confirmation', name: 'order_resend_confirmation', methods: ['POST'])]
    #[OA\Post(
        summary: "Resend order confirmation code via email",
        description: "Resends the order confirmation code to the buyer's email. Can only be used for paid or processing orders that are not yet completed or cancelled.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Confirmation code resent successfully",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Confirmation code resent successfully")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID or order state"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order"),
            new OA\Response(response: 500, description: "Internal server error - Failed to send email")
        ]
    )]
    public function resendOrderConfirmationCode(string $id, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $order = $this->orderService->getOrderById($id);

            // Validate order ownership and status
            if (!$order instanceof Order || $order->getBuyer() !== $user) {
                throw new NotFoundHttpException('Order not found');
            }

            // Only allow resending for paid or processing orders
            if (
                $order->getPaymentStatus() !== OrderPaymentStatus::Paid &&
                $order->getPaymentStatus() !== OrderPaymentStatus::Processing
            ) {
                throw new BadRequestHttpException('Confirmation code can only be resent for paid or processing orders');
            }

            // Don't allow resending for completed/cancelled orders
            if ($order->getStatus() === OrderStatus::Completed) {
                throw new BadRequestHttpException('Order is already completed');
            }
            if ($order->getStatus() === OrderStatus::Cancelled) {
                throw new BadRequestHttpException('Order is cancelled');
            }

            try {
                $locale = $this->getLocale($request);
                $this->orderService->sendOrderConfirmationCodeEmail($user, $order, $locale);
            } catch (\RuntimeException $e) {
                throw new \RuntimeException('Failed to resend confirmation code');
            }

            return $this->json([
                'message' => 'Confirmation code resent successfully'
            ], JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException | BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\RuntimeException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    //categories

    #[Route('/category-types', name: 'categories_types_list', methods: ['GET'])]
    #[OA\Get(
        summary: "Get all available category types",
        description: "Retrieves all available category type options with labels in multiple languages.",
        tags: ["Buyer - Categories"],
        parameters: [
            new OA\Parameter(
                name: "locale",
                in: "query",
                required: false,
                description: "Locale for the label (default: 'en'). Available locales: 'en', 'fr'",
                schema: new OA\Schema(type: "string", enum: ["en", "fr"], default: "en")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "List of category types",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(
                        type: "object",
                        properties: [
                            new OA\Property(property: "value", type: "string", description: "Category type value"),
                            new OA\Property(property: "labelEn", type: "string", description: "Label in English"),
                            new OA\Property(property: "labelFr", type: "string", description: "Label in French"),
                            new OA\Property(property: "label", type: "string", description: "Label in requested locale")
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
        summary: "Search and filter categories",
        description: "Fetches a paginated list of dish categories with sorting, filtering, and search options.",
        tags: ["Buyer - Categories"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'name', 'createdAt')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "search", in: "query", description: "Search term", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "type", in: "query", description: "Filter by category type", schema: new OA\Schema(type: "string"))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated categories",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(type: "object")
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters")
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


    #[Route('/dishes/{dishId}/ratings', name: 'dish_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get ratings for a specific dish",
        description: "Retrieves a paginated list of ratings for a specific available dish with filtering and sorting options.",
        tags: ["Buyer - Ratings"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "UUID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'rating', 'createdAt')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "minRating", in: "query", description: "Minimum rating filter (1-5)", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)),
            new OA\Parameter(name: "maxRating", in: "query", description: "Maximum rating filter (1-5)", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated ratings",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishRatingDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters"),
            new OA\Response(response: 404, description: "Dish not found or user not authenticated")
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

            $dish = $this->dishRepository->findAvailableById($dishId);
            if (!$dish instanceof Dish) {
                throw new NotFoundHttpException('Dish not found');
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $minRating = $request->query->get('minRating');
            $maxRating = $request->query->get('maxRating');

            $filters = [];

            if ($minRating !== null && is_numeric($minRating)) {
                $filters['minRating'] = max(1, min(5, (int) $minRating));
            }

            if ($maxRating !== null && is_numeric($maxRating)) {
                $filters['maxRating'] = max(1, min(5, (int) $maxRating));
            }

            $data = $this->dishRatingService->getFilteredRatings(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                null, // search
                $dishId,
                null, // buyerId
                null, // orderId
                $filters
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/dishes/{dishId}/ratings', name: 'create_dish_rating', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a rating for a dish",
        description: "Allows a buyer to rate a dish from a completed order. A rating consists of a numeric value (1-5) and an optional comment. Each buyer can only have one rating per dish.",
        tags: ["Buyer - Ratings"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "UUID of the dish to rate",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                required: ["orderId", "rating"],
                properties: [
                    new OA\Property(
                        property: "orderId",
                        type: "string",
                        format: "uuid",
                        description: "UUID of the completed order containing the dish"
                    ),
                    new OA\Property(
                        property: "rating",
                        type: "integer",
                        minimum: 1,
                        maximum: 5,
                        description: "Rating value (1-5)"
                    ),
                    new OA\Property(
                        property: "comment",
                        type: "string",
                        nullable: true,
                        minLength: 3,
                        maxLength: 1000,
                        description: "Optional rating comment (3-1000 characters, must contain at least one letter)"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Rating created successfully",
                content: new OA\JsonContent(ref: new Model(type: DishRatingDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid rating or validation error"),
            new OA\Response(response: 404, description: "Dish, order, or user not found"),
            new OA\Response(response: 409, description: "Conflict - Rating already exists for this dish")
        ]
    )]
    public function createRating(string $dishId, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $data = $this->getRequestData($request);

            if ($data == null) {
                // throw new InvalidArgumentException('Invalid request payload.');
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            if (!ValidationHelper::isCorrectUuid($dishId)) {
                throw new InvalidArgumentException('Invalid UUID format for Dish ID');
            }
            $dish = $this->dishRepository->findActiveById($dishId);
            if (!$dish instanceof Dish) {
                throw new NotFoundHttpException('Dish not found');
            }

            if (!empty($data['rating'])) {
                $data['rating'] = (int) $data['rating'];
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'orderId' => [
                        new Assert\NotBlank(),
                        new Assert\Type('string'),
                        new Assert\Uuid(),
                    ],
                    'rating' => [
                        new Assert\NotBlank(),
                        new Assert\Type('integer'),
                        new Assert\Range([
                            'min' => 1,
                            'max' => 5,
                        ])
                    ],
                    'comment' => [
                        new Assert\Optional([
                            new Assert\Type('string'),
                            new Assert\Length(['min' => 3, 'max' => 1000]),
                            new Assert\Regex([
                                'pattern' => '/[a-zA-Z]/',
                                'message' => 'The comment must contain at least one alphabetic character.',
                            ])
                        ])
                    ]
                ],
                'allowExtraFields' => true
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            // if (!ValidationHelper::isCorrectUuid($data['orderId'])) {
            //     throw new InvalidArgumentException('Invalid UUID format for Order ID');
            // }
            $order = $this->orderRepository->find($data['orderId']);
            if (!$order instanceof Order || $order->getBuyer() !== $user) {
                throw new NotFoundHttpException('Order not found');
            }

            $ratingValue = (int) $data['rating'];
            $comment = $data['comment'] ?? null;

            $ratingDTO = $this->dishRatingService->createRating(
                $dish,
                $user,
                $order,
                $ratingValue,
                $comment
            );

            return $this->json($ratingDTO, Response::HTTP_CREATED);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    // #[Route('/ratings/{ratingId}', name: 'rating_detail', methods: ['GET'])]
    // public function getRating(string $ratingId): JsonResponse
    // {
    //     try {
    //         /** @var User $user */
    //         $user = $this->getUser();
    //         if (!$user instanceof User) {
    //             throw new NotFoundHttpException('User not found');
    //         }

    //         if (!ValidationHelper::isCorrectUuid($ratingId)) {
    //             throw new InvalidArgumentException('Invalid UUID format for Rating ID');
    //         }
    //         $ratingDTO = $this->dishRatingService->getRatingDTOById($ratingId);

    //         return $this->json($ratingDTO, JsonResponse::HTTP_OK);

    //     } catch (\InvalidArgumentException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     } catch (NotFoundHttpException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
    //     }
    // }

    #[Route('/ratings/{ratingId}', name: 'update_rating', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a rating",
        description: "Updates an existing rating created by the authenticated buyer. The buyer can modify the rating value and/or comment.",
        tags: ["Buyer - Ratings"],
        parameters: [
            new OA\Parameter(
                name: "ratingId",
                in: "path",
                required: true,
                description: "UUID of the rating to update",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "rating",
                        type: "integer",
                        nullable: true,
                        minimum: 1,
                        maximum: 5,
                        description: "Updated rating value (1-5, optional)"
                    ),
                    new OA\Property(
                        property: "comment",
                        type: "string",
                        nullable: true,
                        minLength: 3,
                        maxLength: 1000,
                        description: "Updated rating comment (3-1000 characters, must contain at least one letter, optional)"
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Rating updated successfully",
                content: new OA\JsonContent(ref: new Model(type: DishRatingDTO::class))
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid data or validation error"),
            new OA\Response(response: 404, description: "Rating not found or user does not own the rating")
        ]
    )]
    public function updateRating(string $ratingId, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            if (!ValidationHelper::isCorrectUuid($ratingId)) {
                throw new InvalidArgumentException('Invalid UUID format for Rating ID');
            }

            $rating = $this->dishRatingService->getRatingById($ratingId);
            if (!$rating instanceof DishRating) {
                throw new NotFoundHttpException('Rating not found');
            }

            // Verify user owns the rating
            if ($rating->getBuyer() !== $user) {
                throw new NotFoundHttpException('Rating not found');
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'rating' => [
                        new Assert\Optional([
                            new Assert\Type('integer'),
                            new Assert\Range([
                                'min' => 1,
                                'max' => 5,
                            ])
                        ])
                    ],
                    'comment' => [
                        new Assert\Optional([
                            new Assert\Type('string'),
                            new Assert\Length(['min' => 3, 'max' => 1000]),
                            new Assert\Regex([
                                'pattern' => '/[a-zA-Z]/',
                                'message' => 'The comment must contain at least one alphabetic character.',
                            ])
                        ])
                    ]
                ],
                'allowExtraFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $ratingValue = $data['rating'] ?? $rating->getRating();
            $comment = $data['comment'] ?? $rating->getComment();

            $ratingDTO = $this->dishRatingService->updateRating(
                $rating,
                $ratingValue,
                $comment
            );

            return $this->json($ratingDTO, JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (ValidationException $e) {
            return $this->json(['error' => (string) $e], JsonResponse::HTTP_BAD_REQUEST);
        }
    }

    #[Route('/ratings', name: 'user_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get buyer's ratings",
        description: "Retrieves a paginated list of all ratings created by the authenticated buyer with filtering and sorting options.",
        tags: ["Buyer - Ratings"],
        parameters: [
            new OA\Parameter(name: "limit", in: "query", description: "Number of results per page (default: 50)", schema: new OA\Schema(type: "integer", default: 50, minimum: 1)),
            new OA\Parameter(name: "page", in: "query", description: "Page number", schema: new OA\Schema(type: "integer", default: 1, minimum: 1)),
            new OA\Parameter(name: "sortBy", in: "query", description: "Sort field (e.g., 'rating', 'createdAt')", schema: new OA\Schema(type: "string", default: "createdAt")),
            new OA\Parameter(name: "sortOrder", in: "query", description: "Sort order ('asc' or 'desc')", schema: new OA\Schema(type: "string", default: "DESC")),
            new OA\Parameter(name: "minRating", in: "query", description: "Minimum rating filter (1-5)", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)),
            new OA\Parameter(name: "maxRating", in: "query", description: "Maximum rating filter (1-5)", schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated ratings",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "current_page", type: "integer", default: 1),
                        new OA\Property(property: "limit", type: "integer", default: 50),
                        new OA\Property(property: "total_items", type: "integer", default: 100),
                        new OA\Property(property: "total_pages", type: "integer", default: 2),
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishRatingDTO::class))
                        )
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid parameters"),
            new OA\Response(response: 404, description: "User not found")
        ]
    )]
    public function getUserRatings(Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $minRating = $request->query->get('minRating');
            $maxRating = $request->query->get('maxRating');

            $filters = [
                'buyerId' => $user->getId()
            ];


            if ($minRating !== null && is_numeric($minRating)) {
                $filters['minRating'] = max(1, min(5, (int) $minRating));
            }

            if ($maxRating !== null && is_numeric($maxRating)) {
                $filters['maxRating'] = max(1, min(5, (int) $maxRating));
            }

            $data = $this->dishRatingService->getFilteredRatings(
                $page,
                $limit,
                $sortBy,
                $sortOrder,
                null, // search
                null, // dishId
                $user->getId(),
                null, // orderId
                $filters
            );

            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    /**
     * Get proxy phone numbers for order communication
     */
    #[Route('/orders/{id}/proxy-numbers', name: 'order_proxy_numbers', methods: ['GET'])]
    #[OA\Get(
        summary: "Get proxy phone numbers for order communication",
        description: "Retrieves Twilio proxy phone numbers for buyer-seller communication. Only available for paid orders.",
        tags: ["Buyer - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "UUID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Proxy numbers retrieved successfully",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "buyer_proxy_number", type: "string", description: "Proxy phone number for the buyer"),
                        new OA\Property(property: "seller_proxy_number", type: "string", description: "Proxy phone number for the seller"),
                        new OA\Property(property: "session_sid", type: "string", description: "Twilio Proxy session ID")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Order not paid or invalid UUID"),
            new OA\Response(response: 404, description: "Order not found or user does not own the order"),
            new OA\Response(response: 503, description: "Service unavailable - Twilio proxy pool exhausted, try again shortly"),
            new OA\Response(response: 500, description: "Internal server error - Failed to retrieve proxy numbers")
        ]
    )]
    public function getOrderProxyNumbers(string $id): JsonResponse
    {
        // TODO: Move this function to a service as it's shared between buyer and seller controllers
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }
            $order = $this->orderService->getOrderById($id);

            if ($order->getPaymentStatus() !== OrderPaymentStatus::Paid) {
                throw new BadRequestHttpException('Order must be paid to access communication');
            }

            //TODO: add order completion check if needed

            // TODO: Temporary fallback — Twilio Proxy is currently disabled due to service issues.
            //       Return direct phone numbers instead of proxy numbers.
            //       Revert to $this->twilioProxyService->getProxyNumbers($order) once resolved.
            $buyer = $order->getBuyer();
            $seller = $order->getStore()->getSeller();

            if (!$buyer->getPhoneNumber() || !$seller->getPhoneNumber()) {
                throw new BadRequestHttpException('Both buyer and seller must have phone numbers');
            }

            return $this->json(
                [
                    'buyer_proxy_number' => $buyer->getPhoneNumber(),
                    'seller_proxy_number' => $seller->getPhoneNumber(),
                    'session_sid' => "tmp-session-sid"
                ]
            );


            // $proxyNumbers = $this->twilioProxyService->getProxyNumbers($order);

            // return $this->json(
            //     [
            //         'buyer_proxy_number' => $proxyNumbers['buyer_proxy_number'],
            //         'seller_proxy_number' => $proxyNumbers['seller_proxy_number'],
            //         'session_sid' => $proxyNumbers['session_sid'],
            //     ]
            // );
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (InvalidArgumentException | BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\RuntimeException $e) {
            // Pool exhausted or Twilio service unavailable
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_SERVICE_UNAVAILABLE); // 503
        } catch (\Exception $e) {
            // return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
            return $this->json(['error' => 'Failed to get proxy numbers'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[OA\Get(
        summary: "Get basic statistics",
        description: "Retrieves basic statistics for the authenticated buyer including total orders, and pending orders.",
        tags: ["Buyer - Statistics"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with basic statistics",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "totalOrders", type: "integer", description: "Total number of orders"),
                        new OA\Property(property: "totalPendingOrders", type: "integer", description: "Number of pending orders"),
                    ],
                    example: [
                        "totalOrders" => 45,
                        "totalPendingOrders" => 3,
                    ]
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 500, description: "Internal server error")
        ]
    )]
    #[Route('/stats', name: 'get_basic_stats', methods: ['GET'])]
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
}
