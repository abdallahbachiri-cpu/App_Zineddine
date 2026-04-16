<?php

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
class SellerController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        // private SerializerInterface $serializer,
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
        // private DishRatingMapper $dishRatingMapper,
        private WalletMapper $walletMapper,
        private WalletTransactionRepository $walletTransactionRepository,
        private WalletTransactionMapper $walletTransactionMapper,
        // private BankAccountMapper $bankAccountMapper,
        private StripeService $stripeService,
        private IngredientMapper $ingredientMapper,
        private TwilioProxyService $twilioProxyService,
        private AllergenMapper $allergenMapper,
        private StatisticsService $statisticsService,
        private readonly LoggerInterface $logger,
    ) {
    }

    // user info and management
    #[Route('', name: 'info', methods: ['GET'])]
    #[OA\Get(
        summary: "Get the logged-in seller's information",
        description: "Retrieves the profile details of the authenticated seller.",
        tags: ["Seller - profile"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with user data",
                content: new OA\JsonContent(
                    ref: "#/components/schemas/UserDTO"
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function getSellerInfo(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        // return $this->json($user, Response::HTTP_OK, [], ['groups' => 'user:read']);
        $userDTO = $this->userMapper->mapToDTO($user);

        return $this->json($userDTO);
    }

    #[Route('', name: 'update', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update the logged-in seller's profile",
        description: "Updates the profile of the authenticated seller. Only provided fields will be updated.",
        tags: ["Seller - profile"],
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
                        example: "seller@example.com",
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
                    ref: "#/components/schemas/UserDTO"
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid request payload"),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 422, description: "Unprocessable entity - Business logic validation failed"),
        ]
    )]
    public function updateSeller(Request $request): JsonResponse
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
        tags: ["Seller - profile"],
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
    //     description: "Suspends the authenticated seller account. The user will no longer be able to access their account until reactivated.",
    //     tags: ["Seller - profile"],
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
        tags: ["Seller - profile"],
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
        tags: ["Seller - Locations"],
        responses: [
            new OA\Response(
                response: 200,
                description: "User locations retrieved successfully",
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
        tags: ["Seller - Locations"],
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
        tags: ["Seller - Locations"],
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
        tags: ["Seller - Locations"],
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
        tags: ["Seller - Locations"],
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

    // get user food store, create, and manage the store
    #[Route('/food-store', name: 'food_store_info', methods: ['GET'])]
    #[OA\Get(
        summary: "Get authenticated seller's food store",
        description: "Retrieves details of the food store associated with the authenticated seller.",
        tags: ["Seller - Food Store"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Food store retrieved successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/FoodStoreDTO")
            ),
            new OA\Response(
                response: 404,
                description: "No food store found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            )
        ]
    )]
    public function getFoodStore(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], Response::HTTP_NOT_FOUND);
        }

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, Response::HTTP_OK);
    }

    #[Route('/food-store', name: 'create_food_store', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a new food store",
        description: "Allows an authenticated seller to create a new food store. The seller cannot create more than one store.",
        tags: ["Seller - Food Store"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    type: "object",
                    required: ['name', 'location'],
                    properties: [
                        new OA\Property(property: "name", type: "string", example: "Pizza Haven"),
                        new OA\Property(property: "description", type: "string", example: "Authentic Italian Pizzeria"),
                        new OA\Property(property: "profileImage", type: "string", format: "binary", description: "Profile image file"),
                        new OA\Property(property: "location", ref: "#/components/schemas/LocationDTO", description: "eg: location[latitude], location[longitude].. etc")
                    ]
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Food store created successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/FoodStoreDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Invalid request payload or validation errors",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid request payload."),
                        new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
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
            ),
            new OA\Response(
                response: 409,
                description: "User already has a food store",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "You already have a food store.")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error (e.g., file upload failure)",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to upload media.")
                    ]
                )
            )
        ]
    )]
    public function createFoodStore(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if ($user->getFoodStore() instanceof FoodStore) {
            return $this->json(['message' => 'You already have a food store.'], JsonResponse::HTTP_CONFLICT);
        }
        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['location']) && is_array($data['location'])) {
            $locationData = $this->locationService->normalizeLocationData($data['location']);
            $data['location'] = $locationData;
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'name' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ],
                'description' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 3, 'max' => 1500]),
                        new Assert\Regex([
                            'pattern' => '/[a-zA-Z]/',
                            'message' => 'The description must contain at least one alphabetic character.',
                        ])
                    ])
                ],
                'type' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Choice([
                            'choices' => array_map(fn(StoreType $type) => $type->value, StoreType::cases()),
                            'message' => 'Invalid store type. Valid types are: {{ choices }}',
                        ])
                    ])
                ],
                'deliveryOption' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Choice([
                            'choices' => array_map(fn($opt) => $opt->value, StoreDeliveryOption::cases()),
                            'message' => 'Invalid delivery option. Valid options are: {{ choices }}'
                        ])
                    ])
                ],
                'profileImage' => [new Assert\Optional([new Assert\Image()])],
                'location' => $this->locationService::getConstraints(false, true)
            ],
            'allowMissingFields' => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        $sameNameFoodStore = $this->foodStoreRepository->findOneBy(['name' => $data['name']]);
        if ($sameNameFoodStore instanceof FoodStore) {
            return $this->json(['error' => 'Food store with this name already exists.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $type = isset($data['type']) ? StoreType::from($data['type']) : StoreType::Home;


        $foodStore = new FoodStore();
        $foodStore->setName($data['name'])
            ->setDescription($data['description'] ?? null)
            ->setSeller($user)
            ->setType($type);

        $deliveryOption = isset($data['deliveryOption']) ? StoreDeliveryOption::from($data['deliveryOption']) : StoreDeliveryOption::PickupOnly;
        $foodStore->setDeliveryOption($deliveryOption);

        // Handle optional profile image file upload
        if (array_key_exists('profileImage', $data)) {
            $file = $data['profileImage'];
            if ($file instanceof UploadedFile) {
                try {
                    $profileImageMedia = $this->mediaService->upload($file);
                    $foodStore->setProfileImage($profileImageMedia);
                } catch (\Exception $e) {
                    return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
                }
            }
        }

        $this->entityManager->persist($foodStore);
        $this->entityManager->flush();

        if (isset($locationData) && is_array($locationData)) {
            try {
                $location = $this->locationService->createLocation($foodStore, null, $locationData);
                $foodStore->setLocation($location);
                $this->entityManager->flush();
            } catch (ValidationException $e) {
                return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
            } catch (\InvalidArgumentException $e) {
                return new JsonResponse(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
            }
        }

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, JsonResponse::HTTP_CREATED);
    }

    #[Route('/food-store', name: 'update_food_store', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update food store details",
        description: "Allows an authenticated seller to update their food store details (excluding profile image).",
        tags: ["Seller - Food Store"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "description", type: "string", example: "New description for the pizzeria"),
                    new OA\Property(property: "location", ref: "#/components/schemas/LocationDTO")
                ],
                type: "object"
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Food store updated successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/FoodStoreDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation errors or invalid request",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
                    ]
                )
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
    public function updateFoodStore(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['location']) && is_array($data['location'])) {
            $locationData = $this->locationService->normalizeLocationData($data['location']);
            $data['location'] = $locationData;
        }

        // Define constraints for update
        $constraints = new Assert\Collection([
            'fields' => [
                'type' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Choice([
                            'choices' => array_map(fn(StoreType $type) => $type->value, StoreType::cases()),
                            'message' => 'Invalid store type. Valid types are: {{ choices }}',
                        ])
                    ])
                ],
                'description' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 3, 'max' => 1500]),
                        new Assert\Regex([
                            'pattern' => '/[a-zA-Z]/',
                            'message' => 'The description must contain at least one alphabetic character.',
                        ])
                    ])
                ],
                'deliveryOption' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Choice([
                            'choices' => array_map(fn($opt) => $opt->value, StoreDeliveryOption::cases()),
                            'message' => 'Invalid delivery option. Valid options are: {{ choices }}'
                        ])
                    ])
                ],
                'location' => $this->locationService::getConstraints(true, true)
            ],
            'allowMissingFields' => true,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['description'])) {
            $foodStore->setDescription($data['description']);
        }

        if (isset($data['type'])) {
            $type = StoreType::from($data['type']);
            $foodStore->setType($type);
        }

        if (isset($data['deliveryOption'])) {
            $deliveryOption = StoreDeliveryOption::from($data['deliveryOption']);
            $foodStore->setDeliveryOption($deliveryOption);
        }

        if (isset($locationData) && is_array($locationData)) {
            try {
                $location = $this->locationService->upsertFoodStoreLocation($foodStore, $locationData);
                $foodStore->setLocation($location);
                $this->entityManager->persist($foodStore);
            } catch (ValidationException $e) {
                return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
            } catch (\InvalidArgumentException $e) {
                return new JsonResponse(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
            }
        }

        $this->entityManager->flush();

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, JsonResponse::HTTP_OK);
    }

    //due to PHP PATCH and PUT limitations with form-data and file uploads, we will use POST for file update
    #[Route('/food-store/profile-image', name: 'update_food_store_profile_image', methods: ['POST'])]
    #[OA\Post(
        summary: "Update food store profile image",
        description: "Allows an authenticated seller to update the profile image of their food store.",
        tags: ["Seller - Food Store"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    type: "object",
                    required: ["profileImage"],
                    properties: [
                        new OA\Property(
                            property: "profileImage",
                            type: "string",
                            format: "binary",
                            description: "Profile image file to upload"
                        )
                    ]
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Profile image updated successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/FoodStoreDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation errors or invalid file",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "errors", type: "array", items: new OA\Items(type: "string"))
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Food store not found",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error during file upload",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to upload media.")
                    ]
                )
            )
        ]
    )]
    public function updateFoodStoreProfileImage(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'profileImage' => [new Assert\NotBlank(), new Assert\Image()]
            ],
            'allowMissingFields' => false,
            'allowExtraFields' => false
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (array_key_exists('profileImage', $data)) {
            $file = $data['profileImage'];
            if ($file instanceof UploadedFile) {
                try {
                    $profileImageMedia = $this->mediaService->upload($file);
                    $foodStore->setProfileImage($profileImageMedia);
                } catch (\Exception $e) {
                    return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
                }
            }
        }

        $this->entityManager->flush();

        $foodStoreDto = $this->foodStoreMapper->mapToDTO($foodStore);

        return $this->json($foodStoreDto, JsonResponse::HTTP_OK);
    }


    #[Route('/food-store', name: 'delete_food_store', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete food store",
        description: "Deletes the authenticated seller's food store. (Soft delete logic will be implemented in the future.)",
        tags: ["Seller - Food Store"],
        responses: [
            new OA\Response(
                response: 204,
                description: "Food store deleted successfully"
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
    public function deleteFoodStore(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore) {
            return $this->json(['message' => 'No food store found.'], Response::HTTP_NOT_FOUND);
        }

        /**
         * TODO: Implement soft delete logic here instead of real delete
         */

        $this->entityManager->remove($foodStore);
        $this->entityManager->flush();

        return $this->json(null, Response::HTTP_NO_CONTENT);
    }


    // get food store dishes, create and manage them

    #[Route('/food-store/dishes', name: 'list_food_store_dishes', methods: ['GET'])]
    #[OA\Get(
        summary: "List all dishes of the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with a list of dishes",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: "#/components/schemas/DishDTO")
                )
            ),
            new OA\Response(
                response: 404,
                description: "No food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            ),
        ]
    )]
    public function listDishes(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dishes = $this->dishRepository->findActiveByStore($foodStore);

        $dishesDto = $this->dishMapper->mapToDTOs($dishes);

        return $this->json($dishesDto, Response::HTTP_OK);
    }

    #[Route('/food-store/dishes', name: 'create_food_store_dish', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a new dish for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    type: "object",
                    properties: [
                        new OA\Property(property: "name", type: "string", example: "Margherita Pizza"),
                        new OA\Property(property: "description", type: "string", example: "A classic Italian pizza with fresh basil and mozzarella.", nullable: true),
                        new OA\Property(property: "price", type: "number", example: 12.99),
                        new OA\Property(
                            property: "gallery",
                            type: "array",
                            items: new OA\Items(type: "string", format: "binary"),
                            description: "Array of image files,  use `gallery[]` as the key in the form data."
                        )
                    ],
                    required: ["name", "price"]
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Dish successfully created",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "errors", type: "object", example: "[name] The name must contain at least one alphabetic character.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "No food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "No food store found.")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Failed to upload media",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to upload media: File size too large.")
                    ]
                )
            )
        ]
    )]
    public function createDish(Request $request): JsonResponse
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

        if (!isset($data['name'], $data['price'])) {
            $errorMessage = 'Required fields are missing.';
            return $this->json(['error' => $errorMessage], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            "fields" => [
                'name' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ],
                'description' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 3, 'max' => 1500]),
                        new Assert\Regex([
                            'pattern' => '/[a-zA-Z]/',
                            'message' => 'The description must contain at least one alphabetic character.',
                        ])
                    ])
                ],
                'price' => [
                    new Assert\NotBlank(),
                    new Assert\Type('numeric'),
                    new Assert\Positive()
                ],
                'gallery' => new Assert\Optional([
                    new Assert\All([
                        new Assert\Image()
                    ])
                ])
            ],
            "allowMissingFields" => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        $dish = new Dish();
        $dish->setName($data['name'])
            ->setDescription($data['description'] ?? null)
            ->setBasePrice((float) $data['price'])
            ->setFoodStore($foodStore);

        // Handle optional gallery images
        if (isset($data['gallery']) && is_array($data['gallery'])) {
            foreach ($data['gallery'] as $file) {
                if ($file instanceof UploadedFile) {
                    try {
                        $media = $this->mediaService->upload($file);
                        $dish->addMedia($media);
                    } catch (\Exception $e) {
                        return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
                    }
                }
            }
        }

        $this->entityManager->persist($dish);
        $this->entityManager->flush();


        $dishDto = $this->dishMapper->mapToDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_CREATED);
    }

    #[Route('/food-store/dishes/{id}', name: 'get_food_store_dish', methods: ['GET'])]
    #[OA\Get(
        summary: "Get a dish by ID for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to retrieve",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Dish retrieved successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
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
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function getDish(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }
        $dishDto = $this->dishMapper->mapToDetailDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_OK);
    }

    #[Route('/food-store/dishes/{id}', name: 'delete_food_store_dish', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete a dish by ID for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to delete",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Dish successfully deleted"
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
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Dish cannot be deleted because it is referenced by existing records",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish cannot be deleted because it is referenced by existing records.")
                    ]
                )
            )
        ]
    )]
    public function deleteDish(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $dish = $this->dishRepository->findByIdAndStore($id, $foodStore);

            if (!$dish instanceof Dish) {
                return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if ($dish->isDeleted()) {
                return $this->json(['message' => 'Dish already deleted.'], JsonResponse::HTTP_CONFLICT);
            }

            $dish->softDelete();
            $this->entityManager->flush();

            return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    //update dish, update dish gallery, add image, delete image

    #[Route('/food-store/dishes/{id}', name: 'update_food_store_dish', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update a dish for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to update",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\MediaType(
                mediaType: "application/json",
                schema: new OA\Schema(
                    type: "object",
                    properties: [
                        new OA\Property(property: "name", type: "string", example: "Updated Pizza", nullable: true),
                        new OA\Property(property: "description", type: "string", example: "Updated description", nullable: true),
                        new OA\Property(property: "price", type: "number", example: 14.99, nullable: true)
                    ],
                    description: "At least one field should be provided for an update. Fields left out will remain unchanged."
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Dish successfully updated",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "errors", type: "object", example: "[name] The name must contain at least one alphabetic character.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function updateDish(string $id, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'name' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 3, 'max' => 255]),
                        new Assert\Regex([
                            'pattern' => '/[a-zA-Z]/',
                            'message' => 'The name must contain at least one alphabetic character.',
                        ])
                    ])
                ],
                'description' => [
                    new Assert\Optional([
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 3, 'max' => 1500]),
                        new Assert\Regex([
                            'pattern' => '/[a-zA-Z]/',
                            'message' => 'The description must contain at least one alphabetic character.',
                        ])
                    ])
                ],
                'price' => [
                    new Assert\Optional([
                        new Assert\Type('numeric'),
                        new Assert\Positive()
                    ])
                ],
                'available' => new Assert\Optional([
                    new Assert\Type('bool')
                ])
            ],
            'allowMissingFields' => true,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['name'])) {
            $dish->setName($data['name']);
        }
        if (isset($data['description'])) {
            $dish->setDescription($data['description']);
        }
        if (isset($data['price'])) {
            $dish->setBasePrice($data['price']);
        }
        if (isset($data['available'])) {
            $dish->setAvailable($data['available']);
        }

        $this->entityManager->flush();

        $dishDto = $this->dishMapper->mapToDetailDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_OK);
    }

    #[Route('/food-store/dishes/{id}/activate', name: 'activate_food_store_dish', methods: ['POST'])]
    #[OA\POST(
        summary: "activate (make available) a dish for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to activate",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Dish successfully activated",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "object", example: "The provided ID is not a valid UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Dish already active",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish already active.")
                    ]
                )
            )
        ]
    )]
    public function activateDish(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

            if (!$dish instanceof Dish) {
                return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if ($dish->isAvailable()) {
                return $this->json(['message' => 'Dish already active.'], JsonResponse::HTTP_CONFLICT);
            }
            $dish->setAvailable(true);

            $this->entityManager->flush();

            $dishDto = $this->dishMapper->mapToDetailDTO($dish);

            return $this->json($dishDto, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/food-store/dishes/{id}/deactivate', name: 'deactivate_food_store_dish', methods: ['POST'])]
    #[OA\POST(
        summary: "Deactivate (make unavailable) a dish for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to deactivate",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Dish successfully updated to unavailable",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Validation error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "object", example: "The provided ID is not a valid UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Dish already inactive",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish already inactive.")
                    ]
                )
            )
        ]
    )]
    public function deactivateDish(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

            if (!$dish instanceof Dish) {
                return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            if (!$dish->isAvailable()) {
                return $this->json(['message' => 'Dish already inactive.'], JsonResponse::HTTP_CONFLICT);
            }
            $dish->setAvailable(false);

            $this->entityManager->flush();

            $dishDto = $this->dishMapper->mapToDetailDTO($dish);

            return $this->json($dishDto, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    //working route but replaced with multiple images upload instead of one file on the route below
    // #[Route('/food-store/dishes/{id}/add-image', name: 'update_food_store_dish_add_image', methods: ['POST'])]
    // public function addDishImage(string $id, Request $request): JsonResponse
    // {
    //     /** @var User $user */
    //     $user = $this->getUser();
    //     $foodStore = $user->getFoodStore();

    //     if (!$foodStore instanceof FoodStore) {
    //         return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
    //     }

    //     $dish = $this->dishRepository->findOneBy(['id' => $id, 'foodStore' => $foodStore]);

    //     if (!$dish instanceof Dish) {
    //         return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
    //     }

    //     $data = $this->getRequestData($request);

    //     if ($data === null) {
    //         return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     $constraints = new Assert\Collection([
    //         'fields' => [
    //             'image' => [
    //                 new Assert\Image()
    //             ]
    //         ],
    //         'allowMissingFields' => false,
    //     ]);

    //     $errors = $this->validator->validate($data, $constraints);

    //     if (count($errors) > 0) {
    //         $formattedErrors = ValidationHelper::formatErrors($errors);
    //         return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     if (isset($data['image']) && $data['image'] instanceof UploadedFile) {
    //         $file = $data['image'];
    //         try {
    //             $media = $this->mediaService->upload($file);
    //             $dish->addMedia($media);
    //         } catch (\Exception $e) {
    //             return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
    //         }
    //     }

    //     $this->entityManager->flush();

    //     $dishDto = $this->dishMapper->mapToDTO($dish);

    //     return $this->json($dishDto, JsonResponse::HTTP_OK);
    // }

    #[Route('/food-store/dishes/{id}/add-images', name: 'update_food_store_dish_add_images', methods: ['POST'])]
    #[OA\Post(
        summary: "Add images to an existing dish for the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes - Media"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "gallery",
                            type: "array",
                            items: new OA\Items(type: "string", format: "binary"),
                            description: "Array of image files, use `gallery[]` as the key in the form data."
                        )
                    ],
                    required: ["gallery"]
                )
            )
        ),
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish to update (must be a valid UUID)",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Images successfully added to the dish",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Invalid request payload or invalid dish ID format (must be a UUID)",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "errors", type: "object", example: "The uploaded file is not a valid image."),
                        new OA\Property(property: "error", type: "string", example: "Invalid ID format. Expected a UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish not found or no food store found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Failed to upload media",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to upload media: File size too large.")
                    ]
                )
            )
        ]
    )]
    public function addDishImages(string $id, Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'gallery' => new Assert\Optional([
                    new Assert\All([
                        new Assert\Image()
                    ])
                ])
            ],
            'allowMissingFields' => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['gallery']) && is_array($data['gallery'])) {
            foreach ($data['gallery'] as $file) {
                if ($file instanceof UploadedFile) {
                    try {
                        $media = $this->mediaService->upload($file);
                        $dish->addMedia($media);
                    } catch (\Exception $e) {
                        return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
                    }
                }
            }
        }

        $this->entityManager->flush();

        $dishDto = $this->dishMapper->mapToDetailDTO($dish);

        return $this->json($dishDto, JsonResponse::HTTP_OK);
    }

    #[Route('/food-store/dishes/{id}/media/{mediaId}', name: 'remove_food_store_dish_image', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove an image from a dish in the authenticated user's food store",
        tags: ["Seller - Food Store - Dishes - Media"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the dish (must be a valid UUID)",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "mediaId",
                in: "path",
                required: true,
                description: "The ID of the media to remove (must be a valid UUID)",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Image successfully removed from the dish"
            ),
            new OA\Response(
                response: 400,
                description: "Invalid dish ID or media ID format (must be a UUID) or media is not linked to this dish",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Media is not linked to this dish."),
                        new OA\Property(property: "error", type: "string", example: "Invalid ID format. Expected a UUID.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish or media not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found.")
                    ]
                )
            )
        ]
    )]
    public function deleteDishImage(string $id, string $mediaId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        $dish = $this->dishRepository->findActiveByIdAndStore($id, $foodStore);

        if (!$dish instanceof Dish) {
            return $this->json(['message' => 'Dish not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $media = $this->mediaRepository->find($mediaId);

        if (!$media instanceof Media) {
            return $this->json(['message' => 'Media not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!$dish->getGallery()->contains($media)) {
            return $this->json(['message' => 'Media is not linked to this dish.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $dish->removeMedia($media);
        $this->entityManager->flush();

        return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
    }

    // manage dishes ingredients (isSupplement, price, avilability, etc)

    // #[Route('/ingredients', name: 'get_all_ingredients', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Get all ingredients",
    //     description: "Fetches a paginated list of ingredients with sorting and filtering options.",
    //     tags: ["Seller - Ingredients"],
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
    //     tags: ["Seller - Ingredients"],
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
    #[Route('/food-store/orders', name: 'food_store_orders', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store orders",
        description: "Retrieves a paginated list of orders for the authenticated seller's food store. Supports filtering by status, payment status, delivery status, price range, and buyer.",
        tags: ["Seller - Food Store - Orders"],
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
                description: "Search term to filter orders",
                schema: new OA\Schema(type: "string")
            ),
            new OA\Parameter(
                name: "status",
                in: "query",
                required: false,
                description: "Filter by order status",
                schema: new OA\Schema(type: "string", enum: ["pending", "confirmed", "cancelled", "completed"])
            ),
            new OA\Parameter(
                name: "paymentStatus",
                in: "query",
                required: false,
                description: "Filter by payment status",
                schema: new OA\Schema(type: "string", enum: ["pending", "processing", "paid", "failed", "refund_requested", "refunded", "refund_failed"])
            ),
            new OA\Parameter(
                name: "deliveryStatus",
                in: "query",
                required: false,
                description: "Filter by delivery status",
                schema: new OA\Schema(type: "string", enum: ["pending", "transit", "delivered"])
            ),
            new OA\Parameter(
                name: "minPrice",
                in: "query",
                required: false,
                description: "Minimum order price",
                schema: new OA\Schema(type: "number", format: "float", minimum: 0)
            ),
            new OA\Parameter(
                name: "maxPrice",
                in: "query",
                required: false,
                description: "Maximum order price",
                schema: new OA\Schema(type: "number", format: "float", minimum: 0)
            ),
            new OA\Parameter(
                name: "buyerId",
                in: "query",
                required: false,
                description: "Filter by buyer ID",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated order list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: OrderDTO::class))
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
    public function getOrders(Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $limit = $request->query->getInt('limit', PaginationHelper::DEFAULT_LIMIT);
            $page = $request->query->getInt('page', 1);

            $sortBy = $request->query->getString('sortBy', SortingHelper::DEFAULT_SORT_BY);
            $sortOrder = $request->query->getString('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

            $search = $request->query->getString('search', '') ?: null;

            $minPrice = $request->query->get('minPrice', null);
            $maxPrice = $request->query->get('maxPrice', null);

            $buyerId = $request->query->getString('buyerId', '') ?: null;

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
                $foodStore->getId(),
                $filters,
                true // exclude confirmationCode
            );

            // return $this->json($data, Response::HTTP_OK, [], ['groups' => ['seller']]);
            return $this->json($data, Response::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    // get single order
    #[Route('/food-store/orders/{id}', name: 'food_store_order_detail', methods: ['GET'])]
    #[OA\Get(
        summary: "Get order details",
        description: "Retrieves detailed information about a specific order from the authenticated seller's food store.",
        tags: ["Seller - Food Store - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with order details",
                content: new OA\JsonContent(ref: new Model(type: OrderDetailDTO::class))
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid order ID",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid order ID format")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order not found")
                    ]
                )
            )
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

            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getStore() !== $foodStore) {
                throw new NotFoundHttpException('Order not found');
            }

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);

            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (\InvalidArgumentException | BadRequestException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    // manage orders (accept, reject, cancel, etc)
    #[Route('/food-store/orders/{id}/confirm', name: 'food_store_order_confirm', methods: ['POST'])]
    #[OA\Post(
        summary: "Confirm an order",
        description: "Confirms a pending order. The order must be in 'pending' status and have 'paid' payment status.",
        tags: ["Seller - Food Store - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order to confirm",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Order confirmed successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/OrderDetailDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Order cannot be confirmed",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Only pending orders can be confirmed"
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Order already confirmed",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order has already been confirmed")
                    ]
                )
            )
        ]
    )]
    public function confirmOrder(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getStore() !== $foodStore) {
                throw new NotFoundHttpException('Order not found');
            }

            if ($order->getStatus() === OrderStatus::Confirmed) {
                throw new ConflictHttpException('Order has already been confirmed');
            }

            if ($order->getStatus() !== OrderStatus::Pending) {
                throw new BadRequestHttpException('Only pending orders can be confirmed');
            }

            // Seller can now confirm orders even if not paid yet
            // if ($order->getPaymentStatus() !== OrderPaymentStatus::Paid) {
            //     throw new BadRequestHttpException('Order is not paid yet');
            // }
            $order->setStatus(OrderStatus::Confirmed);
            $this->entityManager->flush();

            // Notify buyer that order is confirmed
            $this->orderService->createAndSendNotification(
                $order->getStore()->getSeller(),
                $order->getBuyer(),
                'Order Confirmed',
                'Your order ' . $order->getOrderNumber() . ' from ' . $order->getStore()->getName() . ' has been confirmed!',
                'Commande confirmee',
                'Votre commande ' . $order->getOrderNumber() . ' de ' . $order->getStore()->getName() . ' a ete confirmee !',
                $order->getId()
            );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);

            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        }
    }




    // Mark order as ready for pickup
    #[Route('/food-store/orders/{id}/ready', name: 'food_store_order_ready', methods: ['POST'])]
    #[OA\Post(
        summary: "Mark order as ready for pickup",
        description: "Marks a confirmed order as ready for pickup and notifies the buyer.",
        tags: ["Seller - Food Store - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Order marked as ready",
                content: new OA\JsonContent(ref: "#/components/schemas/OrderDetailDTO")
            ),
            new OA\Response(response: 400, description: "Bad request"),
            new OA\Response(response: 404, description: "Order or food store not found"),
            new OA\Response(response: 409, description: "Order is not in a state that can be marked ready")
        ]
    )]
    public function markOrderReady(string $id): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $order = $this->orderService->getOrderById($id);

            if (!$order instanceof Order || $order->getStore() !== $foodStore) {
                throw new NotFoundHttpException('Order not found');
            }

            if ($order->getStatus() !== OrderStatus::Confirmed) {
                throw new BadRequestHttpException('Only confirmed orders can be marked as ready');
            }

            $order->setStatus(OrderStatus::Ready);
            $this->entityManager->flush();

            // Notify buyer that order is ready
            $this->orderService->createAndSendNotification(
                $order->getStore()->getSeller(),
                $order->getBuyer(),
                'Order Ready for Pickup',
                'Your order ' . $order->getOrderNumber() . ' from ' . $order->getStore()->getName() . ' is ready for pickup!',
                'Commande prete',
                'Votre commande ' . $order->getOrderNumber() . ' de ' . $order->getStore()->getName() . ' est prete a etre recuperee !',
                $order->getId()
            );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);
            return $this->json($orderDTO, JsonResponse::HTTP_OK);

        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }






    // Cancel order
    #[Route('/food-store/orders/{id}/cancel', name: 'food_store_order_cancel', methods: ['POST'])]
    #[OA\Post(
        summary: "Cancel an order",
        description: "Cancels an order and processes a refund if applicable. Cannot cancel completed orders or orders in transit/delivered status.",
        tags: ["Seller - Food Store - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order to cancel",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Order cancelled successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/OrderDetailDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Order cannot be cancelled",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Completed orders cannot be cancelled"
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order or food store not found",
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
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            $order = $this->orderService->getOrderById($id);
            if (!$order instanceof Order || $order->getStore() !== $foodStore) {
                throw new NotFoundHttpException('Order not found');
            }

            //process refund
            $this->orderService->requestRefund($order, USER::TYPE_SELLER);
            $this->twilioProxyService->closeProxySession($order);

            $this->entityManager->flush();

            // Notify buyer that seller cancelled the order
            $this->orderService->createAndSendNotification(
                $order->getStore()->getSeller(),
                $order->getBuyer(),
                'Order Cancelled',
                'Your order ' . $order->getOrderNumber() . ' has been cancelled by the store.',
                'Commande annulee',
                'Votre commande ' . $order->getOrderNumber() . ' a ete annulee par le restaurant.',
                $order->getId()
            );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);
            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (\Exception $e) {
            // dd($e->getMessage());
            return $this->json(['error' => 'An error occurred while cancelling the order.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    //make order completed
    #[Route('/food-store/orders/{id}/confirm-delivery', name: 'food_store_order_confirm_delivery', methods: ['POST'])]
    #[OA\Post(
        summary: "Confirm order delivery",
        description: "Marks an order as delivered and completed. Requires the confirmation code from the buyer. This action credits the order income to the seller's wallet and closes the proxy communication session.",
        tags: ["Seller - Food Store - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "confirmationCode",
                        type: "string",
                        description: "Confirmation code provided by the buyer",
                        example: "ABC123"
                    )
                ],
                required: ["confirmationCode"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Order delivery confirmed and marked as completed",
                content: new OA\JsonContent(ref: "#/components/schemas/OrderDetailDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid confirmation code or order cannot be completed",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid confirmation code")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Order already completed or delivered",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order has already been completed")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Something went wrong.")
                    ]
                )
            )
        ]
    )]
    public function confirmDelivery(string $id, Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            if (!ValidationHelper::isCorrectUuid($id)) {
                throw new InvalidArgumentException('Invalid order ID format');
            }

            $order = $this->orderService->getOrderById($id);
            if (!$order instanceof Order || $order->getStore() !== $foodStore) {
                throw new NotFoundHttpException('Order not found');
            }

            if ($order->getStatus() === OrderStatus::Completed) {
                throw new ConflictHttpException('Order has already been completed');
            }

            if ($order->getDeliveryStatus() === OrderDeliveryStatus::Delivered) {
                throw new ConflictHttpException('Order has already been delivered');
            }

            if ($order->getPaymentStatus() !== OrderPaymentStatus::Paid) {
                throw new BadRequestHttpException('Order is not paid');
            }

            $data = $this->getRequestData($request);

            if ($data === null) {
                throw new BadRequestHttpException('Invalid request payload.');
            }

            $confirmationCode = $data['confirmationCode'] ?? null;

            if ($confirmationCode === null) {
                throw new BadRequestHttpException('Confirmation code is required');
            }

            if ($confirmationCode !== $order->getConfirmationCode()) {
                throw new BadRequestHttpException('Invalid confirmation code');
            }

            //get paid amount and add it to seller food store wallet
            $order->setDeliveryStatus(OrderDeliveryStatus::Delivered);
            $order->setStatus(OrderStatus::Completed);

            $this->twilioProxyService->closeProxySession($order);

            $this->walletService->creditOrderIncome($order);

            $this->entityManager->flush();

            // Notify buyer that order is delivered and completed
            $this->orderService->createAndSendNotification(
                $order->getStore()->getSeller(),
                $order->getBuyer(),
                'Order Completed',
                'Enjoy your meal! Your order ' . $order->getOrderNumber() . ' has been delivered.',
                'Commande livree',
                'Bon appetit ! Votre commande ' . $order->getOrderNumber() . ' a ete livree.',
                $order->getId()
            );

            $orderDTO = $this->orderMapper->mapToDetailDTO($order, true);
            return $this->json($orderDTO, JsonResponse::HTTP_OK);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (InvalidArgumentException | BadRequestHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_CONFLICT);
        } catch (\Throwable $e) {
            // dd($e->getMessage());
            return $this->json(['error' => 'Something went wrong.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/food-store/verification-requests', name: 'send_food_store_verification_request', methods: ['POST'])]
    #[OA\Post(
        summary: "Send food store verification request",
        description: "Submits a verification request for the food store with supporting documents. Requires multipart/form-data with file uploads. Maximum 15 files, each up to 10MB. Accepted formats: PDF, JPEG, PNG.",
        tags: ["Seller - Food Store - Verification"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Multipart form data with verification documents",
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "documents",
                            type: "array",
                            description: "Array of verification documents (PDF, JPEG, PNG)",
                            items: new OA\Items(type: "string", format: "binary")
                        )
                    ],
                    required: ["documents"]
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Verification request created successfully",
                content: new OA\JsonContent(ref: new Model(type: FoodStoreVerificationRequestDTO::class))
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Validation errors or no food store",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string")
                        ),
                        new OA\Property(property: "error", type: "string", example: "You must create a food store first.")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "User not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "User not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Store already active or request already pending",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "A verification request is already pending for your store."
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to send verification request")
                    ]
                )
            )
        ]
    )]
    public function sendFoodStoreVerificationRequest(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['error' => 'You must create a food store first.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        if ($foodStore->isActive()) {
            return $this->json(['error' => 'Your food store is already active'], JsonResponse::HTTP_CONFLICT);
        }

        // Prevent sending if already has a pending request
        $existingRequest = $this->foodStoreVerificationRequestRepository->findOneBy([
            'foodStore' => $foodStore,
            'status' => StoreVerificationStatus::Pending,
        ]);

        if ($existingRequest instanceof FoodStoreVerificationRequest) {
            return $this->json(['error' => 'A verification request is already pending for your store.'], JsonResponse::HTTP_CONFLICT);
        }

        // Get and validate request data
        // $data = $this->getRequestData($request);

        // dd($data);

        // if ($data === null) {
        //     return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        // }

        $uploadedFiles = $request->files->get('documents', []);

        // dd($uploadedFiles);/

        $constraints = new Assert\Sequentially([
            new Assert\NotBlank([
                'message' => 'At least one file must be uploaded.',
            ]),
            new Assert\Count([
                'min' => 1,
                'max' => 15,
                'minMessage' => 'You must upload at least one file.',
                'maxMessage' => 'You cannot upload more than {{ limit }} files.',
            ]),
            new Assert\Type([
                'type' => 'array',
                'message' => 'Invalid file format.',
            ]),
            new Assert\Count([
                'min' => 1,
                'minMessage' => 'You must upload at least one file.',
            ]),
            new Assert\All([
                new Assert\File([
                    'maxSize' => '10M',
                    'mimeTypes' => [
                        'application/pdf',
                        'image/jpeg',
                        'image/png',
                    ],
                    'mimeTypesMessage' => 'Please upload valid files (PDF, JPEG, PNG).',
                ]),
            ]),
        ]);

        $errors = $this->validator->validate($uploadedFiles, $constraints);


        // $constraints = new Assert\Collection([
        //     'fields' => [
        //         'verificationDocument' => new Assert\File(
        //             [
        //                 'maxSize' => '10M',
        //                 'mimeTypes' => [
        //                     'application/pdf',
        //                 ],
        //                 'mimeTypesMessage' => 'Please upload a valid PDF file.',
        //             ]
        //         ),
        //     ],
        //     'allowMissingFields' => false,
        // ]);

        // $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        // $verificationRequest = new FoodStoreVerificationRequest($foodStore);

        try {
            $verificationRequest = $this->foodStoreVerificationService->createVerificationRequest(
                $foodStore,
                $uploadedFiles
            );

            $verificationRequestDTO = $this->foodStoreVerificationRequestMapper->mapToDto($verificationRequest);

            return $this->json($verificationRequestDTO, JsonResponse::HTTP_CREATED);

            return $this->json(
                $this->foodStoreVerificationRequestMapper->mapToDto($verificationRequest),
                JsonResponse::HTTP_CREATED
            );
        } catch (\Exception $e) {
            return $this->json(['error' => 'Failed to send verification request'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }

        // if (isset($data['verificationDocument']) && $data['verificationDocument'] instanceof UploadedFile) {
        //     try {
        //         // $uploadedMedia = $this->mediaService->upload($data['verificationDocument']);
        //         $uploadedMedia = $this->mediaService->uploadSecure($data['verificationDocument']);

        //         $verificationRequest->setVerificationDocument($uploadedMedia);
        //     } catch (\Exception $e) {
        //         return $this->json(['error' => 'Failed to upload verification document: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        //     }
        // }

    }

    #[Route('/food-store/verification-requests', name: 'get_food_store_verification_requests', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store verification requests",
        description: "Retrieves a paginated list of verification requests for the authenticated seller's food store. Supports filtering by status.",
        tags: ["Seller - Food Store - Verification"],
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
                name: "status",
                in: "query",
                required: false,
                description: "Filter by verification status",
                schema: new OA\Schema(type: "string", enum: ["pending", "approved", "rejected"])
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated verification request list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: "#/components/schemas/FoodStoreVerificationRequestDTO")
                        ),
                        new OA\Property(property: "page", type: "integer", description: "Current page number"),
                        new OA\Property(property: "limit", type: "integer", description: "Items per page"),
                        new OA\Property(property: "total", type: "integer", description: "Total number of items"),
                        new OA\Property(property: "totalPages", type: "integer", description: "Total number of pages")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid query parameters or no food store"),
            new OA\Response(response: 404, description: "User not found")
        ]
    )]
    public function getFoodStoreVerificationRequests(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['error' => 'You must create a food store first.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        try {
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

    #[Route('/food-store/verification-requests/{requestId}/documents/{mediaId}', name: 'download_verification_document', methods: ['GET'])]
    #[OA\Get(
        summary: "Download verification document",
        description: "Downloads a specific verification document from a verification request. Returns the file with appropriate Content-Type and Content-Disposition headers.",
        tags: ["Seller - Food Store - Verification"],
        parameters: [
            new OA\Parameter(
                name: "requestId",
                in: "path",
                required: true,
                description: "The ID of the verification request",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "mediaId",
                in: "path",
                required: true,
                description: "The ID of the document/media to download",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "File download successful",
                content: new OA\MediaType(
                    mediaType: "application/octet-stream",
                    schema: new OA\Schema(type: "string", format: "binary")
                ),
                headers: [
                    new OA\Header(
                        header: "Content-Type",
                        description: "MIME type of the file",
                        schema: new OA\Schema(type: "string")
                    ),
                    new OA\Header(
                        header: "Content-Disposition",
                        description: "Attachment filename",
                        schema: new OA\Schema(type: "string")
                    )
                ]
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format")
                    ]
                )
            ),
            new OA\Response(
                response: 403,
                description: "Forbidden - Access denied",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Access denied")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Verification request, document, or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Verification request not found")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to download document")
                    ]
                )
            )
        ]
    )]
    public function downloadVerificationDocument(string $requestId, string $mediaId): Response
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!$user instanceof User) {
                return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
            }

            $foodStore = $user->getFoodStore();
            if (!$foodStore instanceof FoodStore) {
                return $this->json(['error' => 'No food store found'], Response::HTTP_FORBIDDEN);
            }

            if (!ValidationHelper::isCorrectUuid($requestId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $verificationRequest = $this->foodStoreVerificationRequestRepository->find($requestId);
            if (!$verificationRequest instanceof FoodStoreVerificationRequest) {
                return $this->json(['error' => 'Verification request not found'], Response::HTTP_NOT_FOUND);
            }

            // Verify the request belongs to the seller's food store
            if ($verificationRequest->getFoodStore() !== $foodStore) {
                return $this->json(['error' => 'Access denied'], Response::HTTP_FORBIDDEN);
            }

            $media = $this->foodStoreVerificationService->findMediaDocumentInVerificationRequest($verificationRequest, $mediaId);

            // $document = $verificationRequest->getVerificationDocument();
            // if (!$document instanceof Media) {
            //     return $this->json(['error' => 'No document found'], Response::HTTP_NOT_FOUND);
            // }
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

    #[Route('/food-store/verification-requests/{id}', name: 'delete_food_store_verification_request', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete verification request",
        description: "Deletes a pending verification request. Only pending requests can be deleted.",
        tags: ["Seller - Food Store - Verification"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the verification request to delete",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Verification request deleted successfully"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid request ID or cannot delete",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Cannot delete non-pending verification request")
                    ]
                )
            ),
            new OA\Response(
                response: 401,
                description: "Unauthorized - Authentication required",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Authentication required")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Verification request or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Verification request not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Request cannot be deleted",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Only pending requests can be deleted")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "An error occurred while deleting the verification request")
                    ]
                )
            )
        ]
    )]
    public function deleteVerificationRequest(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['error' => 'Authentication required'], Response::HTTP_UNAUTHORIZED);
        }

        $foodStore = $user->getFoodStore();
        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $this->foodStoreVerificationService->deletePendingRequest($id, $foodStore);
            return $this->json(null, Response::HTTP_NO_CONTENT);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => 'An error occurred while deleting the verification request'],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
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


    #[Route('/food-store/dishes/{dishId}/categories', name: 'add_dish_category', methods: ['POST'])]
    #[OA\Post(
        summary: "Add category to dish",
        description: "Adds a category to a specific dish in the authenticated seller's food store.",
        tags: ["Seller - Food Store - Dishes - Categories"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "categoryId",
                        type: "string",
                        description: "The ID of the category to add",
                        format: "uuid",
                        example: "123e4567-e89b-12d3-a456-426614174000"
                    )
                ],
                required: ["categoryId"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Category added successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
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
                        ),
                        new OA\Property(property: "error", type: "string", example: "Invalid category ID")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish, category, or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found"),
                        new OA\Property(property: "error", type: "string", example: "Category not found")
                    ]
                )
            )
        ]
    )]
    public function addDishCategory(string $dishId, Request $request): JsonResponse
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

        // Validate request data
        $constraints = new Assert\Collection([
            'fields' => [
                'categoryId' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Uuid()
                ]
            ],
            'allowMissingFields' => false,
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }


        try {
            $dishDTO = $this->dishService->addDishCategory(
                $dishId,
                $data['categoryId'],
                $foodStore->getId()
            );

            // Verify the dish belongs to the seller's food store
            if ($dishDTO->foodStoreId !== $foodStore->getId()) {
                return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
            }

            return $this->json($dishDTO, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-store/dishes/{dishId}/categories/{categoryId}', name: 'remove_dish_category', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove category from dish",
        description: "Removes a category from a specific dish in the authenticated seller's food store.",
        tags: ["Seller - Food Store - Dishes - Categories"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "categoryId",
                in: "path",
                required: true,
                description: "The ID of the category to remove",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Category removed successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/DishDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid IDs",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid dish or category ID")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish, category, or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found"),
                        new OA\Property(property: "error", type: "string", example: "Category not found")
                    ]
                )
            )
        ]
    )]
    public function removeDishCategory(string $dishId, string $categoryId): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $dishDTO = $this->dishService->removeDishCategory(
                $dishId,
                $categoryId,
                $foodStore->getId()
            );

            // Verify the dish belongs to the seller's food store
            if ($dishDTO->foodStoreId !== $foodStore->getId()) {
                return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
            }

            return $this->json($dishDTO, JsonResponse::HTTP_OK);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-store/dishes/{dishId}/allergens', name: 'add_dish_allergen', methods: ['POST'])]
    #[OA\Post(
        summary: "Add allergen to dish",
        description: "Adds an allergen to a specific dish in the authenticated seller's food store. If the allergen requires a specification, it must be provided in the request body.",
        tags: ["Seller - Food Store - Dishes - Allergens"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "allergenId",
                        type: "string",
                        description: "The ID of the allergen to add",
                        format: "uuid",
                        example: "123e4567-e89b-12d3-a456-426614174000"
                    ),
                    new OA\Property(
                        property: "specification",
                        type: "string",
                        description: "Specification for the allergen (required if allergen requires specification)",
                        example: "Contains traces of peanuts"
                    )
                ],
                required: ["allergenId"]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: "Allergen added successfully",
                content: new OA\JsonContent(ref: "#/components/schemas/DishAllergenDTO")
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Validation errors or invalid UUID format",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string")
                        ),
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish, allergen, or food store not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found"),
                        new OA\Property(property: "error", type: "string", example: "Allergen not found")
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Allergen is already assigned to this dish",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Allergen is already assigned to this dish.")
                    ]
                )
            )
        ]
    )]
    public function addDishAllergen(string $dishId, Request $request): JsonResponse
    {
        try {
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

            if (!ValidationHelper::isCorrectUuid($dishId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }

            $dish = $this->dishRepository->findActiveById($dishId);

            if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
                return $this->json(['message' => 'Dish not found'], JsonResponse::HTTP_NOT_FOUND);
            }


            $constraints = new Assert\Collection([
                "fields" => [
                    'allergenId' => [
                        new Assert\NotBlank(),
                        new Assert\Type('string'),
                        new Assert\Uuid()
                    ],
                ],
                "allowMissingFields" => false,
                "allowExtraFields" => true,
            ]);

            $errors = $this->validator->validate($data, $constraints);

            if (count($errors) > 0) {
                $formattedErrors = ValidationHelper::formatErrors($errors);
                return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
            }

            $allergenId = $data['allergenId'];

            $allergen = $this->allergenRepository->find($allergenId);

            if (!$allergen instanceof Allergen) {
                return $this->json(['message' => 'Allergen not found.'], JsonResponse::HTTP_NOT_FOUND);
            }

            $existingDishAllergen = $this->dishAllergenRepository
                ->findOneBy([
                    'dish' => $dish,
                    'allergen' => $allergen
                ]);

            if ($existingDishAllergen instanceof DishAllergen) {
                return $this->json(['error' => 'Allergen is already assigned to this dish.'], JsonResponse::HTTP_CONFLICT);
            }

            $specificationRequired = $allergen->getRequiresSpecification();

            $specification = $data['specification'] ?? null;

            $specificationConstraint = $specificationRequired
                ? new Assert\Required([
                    new Assert\NotBlank(['message' => 'The specification is required for this allergen']),
                    new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 1500]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The specification must contain at least one alphabetic character.',
                    ]),
                ])
                : new Assert\Optional([
                    new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 1500]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The specification must contain at least one alphabetic character.',
                    ]),
                ]);

            $specConstraints = new Assert\Collection([
                'fields' => ['specification' => $specificationConstraint],
                "allowMissingFields" => $specificationRequired ? false : true,
            ]);

            $errors = $this->validator->validate(['specification' => $specification], $specConstraints);
            if (count($errors) > 0) {
                $formattedErrors = ValidationHelper::formatErrors($errors);
                return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
            }

            $dishAllergen = new DishAllergen();
            $dishAllergen->setDish($dish)
                ->setAllergen($allergen);

            if (is_string($specification)) {
                $dishAllergen->setSpecification(trim($specification));
            }

            $this->entityManager->persist($dishAllergen);
            $this->entityManager->flush();


            $dishAllergenDTO = $this->dishAllergenMapper->mapToDTO($dishAllergen);
            return $this->json($dishAllergenDTO, JsonResponse::HTTP_CREATED);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    #[Route('/food-store/dishes/{dishId}/allergens/{allergenId}', name: 'remove_dish_allergen', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Remove allergen from dish",
        description: "Removes an allergen from a specific dish in the authenticated seller's food store. Returns 204 No Content on successful deletion.",
        tags: ["Seller - Food Store - Dishes - Allergens"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "allergenId",
                in: "path",
                required: true,
                description: "The ID of the allergen to remove",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 204,
                description: "Allergen removed successfully - No content returned"
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid UUID format",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Invalid UUID format")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Dish, allergen, food store not found, or allergen not assigned to dish",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Dish not found"),
                        new OA\Property(property: "error", type: "string", example: "Allergen not found")
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Something went wrong.")
                    ]
                )
            )
        ]
    )]
    public function removeDishAllergen(string $dishId, string $allergenId): JsonResponse
    {
        try {
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

            $allergen = $this->allergenRepository->find($allergenId);
            if (!$allergen instanceof Allergen) {
                return $this->json(['message' => 'Allergen not found'], JsonResponse::HTTP_NOT_FOUND);
            }

            $dishAllergen = $this->dishAllergenRepository->findOneBy([
                'dish' => $dish,
                'allergen' => $allergen
            ]);

            if (!$dishAllergen instanceof DishAllergen) {
                return $this->json(['message' => 'Allergen is not assigned to this dish.'], JsonResponse::HTTP_NOT_FOUND);
            }

            $this->entityManager->remove($dishAllergen);
            $this->entityManager->flush();

            return $this->json(null, JsonResponse::HTTP_NO_CONTENT);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (\Throwable $e) {
            // dd($e->getMessage());
            return $this->json(['error' => 'Something went wrong.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/food-store/ratings', name: 'food_store_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store ratings",
        description: "Retrieves a paginated list of ratings for all dishes in the authenticated seller's food store. Supports filtering by rating range, buyer, and order.",
        tags: ["Seller - Food Store - Ratings"],
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
                description: "Search term",
                schema: new OA\Schema(type: "string")
            ),
            new OA\Parameter(
                name: "buyerId",
                in: "query",
                required: false,
                description: "Filter by buyer ID",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "orderId",
                in: "query",
                required: false,
                description: "Filter by order ID",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "minRating",
                in: "query",
                required: false,
                description: "Minimum rating (1-5)",
                schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)
            ),
            new OA\Parameter(
                name: "maxRating",
                in: "query",
                required: false,
                description: "Maximum rating (1-5)",
                schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated ratings list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: new Model(type: DishRatingDTO::class))
                        ),
                        new OA\Property(property: "page", type: "integer", description: "Current page number"),
                        new OA\Property(property: "limit", type: "integer", description: "Items per page"),
                        new OA\Property(property: "total", type: "integer", description: "Total number of items"),
                        new OA\Property(property: "totalPages", type: "integer", description: "Total number of pages")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid query parameters"),
            new OA\Response(response: 404, description: "Food store or user not found")
        ]
    )]
    public function getRatings(Request $request): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();

            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();

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

    #[Route('/food-store/dishes/{dishId}/ratings', name: 'food_store_dish_ratings', methods: ['GET'])]
    #[OA\Get(
        summary: "Get dish ratings",
        description: "Retrieves a paginated list of ratings for a specific dish in the authenticated seller's food store. Supports filtering by rating range, buyer, and order.",
        tags: ["Seller - Food Store - Ratings"],
        parameters: [
            new OA\Parameter(
                name: "dishId",
                in: "path",
                required: true,
                description: "The ID of the dish",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
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
                description: "Search term",
                schema: new OA\Schema(type: "string")
            ),
            new OA\Parameter(
                name: "buyerId",
                in: "query",
                required: false,
                description: "Filter by buyer ID",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "orderId",
                in: "query",
                required: false,
                description: "Filter by order ID",
                schema: new OA\Schema(type: "string", format: "uuid")
            ),
            new OA\Parameter(
                name: "minRating",
                in: "query",
                required: false,
                description: "Minimum rating (1-5)",
                schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)
            ),
            new OA\Parameter(
                name: "maxRating",
                in: "query",
                required: false,
                description: "Maximum rating (1-5)",
                schema: new OA\Schema(type: "integer", minimum: 1, maximum: 5)
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with paginated ratings list",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "data",
                            type: "array",
                            items: new OA\Items(ref: "#/components/schemas/DishRatingDTO")
                        ),
                        new OA\Property(property: "page", type: "integer", description: "Current page number"),
                        new OA\Property(property: "limit", type: "integer", description: "Items per page"),
                        new OA\Property(property: "total", type: "integer", description: "Total number of items"),
                        new OA\Property(property: "totalPages", type: "integer", description: "Total number of pages")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid UUID format or query parameters"),
            new OA\Response(response: 404, description: "Dish, food store, or user not found")
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

            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found.');
            }

            // Verify dish belongs to this food store
            if (!ValidationHelper::isCorrectUuid($dishId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
            $dish = $this->dishRepository->findActiveById($dishId);
            if (!$dish instanceof Dish || $dish->getFoodStore() !== $foodStore) {
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

    #[Route('/food-store/wallet', name: 'food_store_wallet', methods: ['GET'])]
    #[OA\Get(
        summary: "Get food store wallet",
        description: "Retrieves the wallet information for the authenticated seller's food store. If no wallet exists, one will be created automatically.",
        tags: ["Seller - Food Store - Wallet"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with wallet details",
                content: new OA\JsonContent(ref: new Model(type: WalletDTO::class))
            ),
            new OA\Response(response: 404, description: "Food store or user not found")
        ]
    )]
    public function getFoodStoreWallet(): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();

            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found');
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

    #[Route('/food-store/wallet/transactions', name: 'food_store_wallet_transactions', methods: ['GET'])]
    #[OA\Get(
        summary: "Get wallet transactions",
        description: "Retrieves all transactions for the authenticated seller's food store wallet, ordered by creation date (newest first).",
        tags: ["Seller - Food Store - Wallet"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with transaction list",
                content: new OA\JsonContent(
                    type: "array",
                    items: new OA\Items(ref: new Model(type: WalletTransactionDTO::class))
                )
            ),
            new OA\Response(response: 404, description: "Food store or user not found")
        ]
    )]
    public function getFoodStoreWalletTransactions(): JsonResponse
    {
        try {
            /** @var User $user */
            $user = $this->getUser();
            if (!$user instanceof User) {
                throw new NotFoundHttpException('User not found');
            }

            $foodStore = $user->getFoodStore();
            if (!$foodStore instanceof FoodStore) {
                throw new NotFoundHttpException('No food store found');
            }

            $wallet = $foodStore->getWallet();
            if (!$wallet instanceof Wallet) {
                // throw new NotFoundHttpException('Wallet not found');
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
                $this->entityManager->flush();
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
        }
    }

    // #[Route('/food-store/bank-account', name: 'food_store_bank_account_get', methods: ['GET'])]
    // public function getFoodStoreBankAccount(): JsonResponse
    // {
    //     try {
    //         /** @var User $user */
    //         $user = $this->getUser();
    //         if (!$user instanceof User) {
    //             throw new NotFoundHttpException('User not found');
    //         }

    //         $foodStore = $user->getFoodStore();

    //         if (!$foodStore instanceof FoodStore) {
    //             throw new NotFoundHttpException('No food store found');
    //         }

    //         $bankAccount = $foodStore->getBankAccount();

    //         if (!$bankAccount instanceof BankAccount) {
    //             throw new NotFoundHttpException('No bank account found');
    //         }

    //         $bankAccountDTO = $this->bankAccountMapper->mapToDTO($bankAccount);

    //         return $this->json($bankAccountDTO, JsonResponse::HTTP_OK);

    //     } catch (NotFoundHttpException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
    //     }
    // }


    // #[Route('/food-store/bank-account', name: 'food_store_bank_account_upsert', methods: ['POST'])]
    // public function upsertBankAccount(Request $request): JsonResponse
    // {
    //     $data = $this->getRequestData($request);

    //     if ($data === null) {
    //         return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     /** @var User $user */
    //     $user = $this->getUser();
    //     $foodStore = $user->getFoodStore();

    //     if (!$foodStore instanceof FoodStore) {
    //         return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
    //     }

    //     // Validate request data
    //     $constraints = new Assert\Collection([
    //         'fields' => [
    //             'accountHolderName' => [
    //                 new Assert\NotBlank(),
    //                 new Assert\Type('string'),
    //                 new Assert\Length(['max' => 100])
    //             ],
    //             'transitNumber' => [
    //                 new Assert\NotBlank(),
    //                 new Assert\Type('string'),
    //                 new Assert\Length(['min' => 5, 'max' => 5]),
    //                 new Assert\Regex('/^\d{5}$/')
    //             ],
    //             'institutionNumber' => [
    //                 new Assert\NotBlank(),
    //                 new Assert\Type('string'),
    //                 new Assert\Length(['min' => 3, 'max' => 3]),
    //                 new Assert\Regex('/^\d{3}$/')
    //             ],
    //             'accountNumber' => [
    //                 new Assert\NotBlank(),
    //                 new Assert\Type('string'),
    //                 new Assert\Length(['min' => 7, 'max' => 12]),
    //                 new Assert\Regex('/^\d{7,12}$/')
    //             ],
    //             // 'currency' => [
    //             //     new Assert\NotBlank(),
    //             //     new Assert\Currency(),
    //             //     new Assert\Length(['min' => 3, 'max' => 3])
    //             // ]
    //         ],
    //         'allowMissingFields' => false,
    //     ]);

    //     $errors = $this->validator->validate($data, $constraints);

    //     if (count($errors) > 0) {
    //         $formattedErrors = ValidationHelper::formatErrors($errors);
    //         return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     try {
    //         $bankAccount = $foodStore->getBankAccount() ?? new BankAccount($foodStore);

    //         // Update bank account details
    //         $bankAccount
    //             ->setAccountHolderName($data['accountHolderName'])
    //             ->setTransitNumber($data['transitNumber'])
    //             ->setInstitutionNumber($data['institutionNumber'])
    //             ->setAccountNumber($data['accountNumber'])
    //             // ->setCurrency(strtoupper($data['currency']))
    //             ->setLastFourDigits(substr($data['accountNumber'], -4));

    //         // Create Stripe bank account token (no seller Stripe account needed)
    //         $stripeBankToken = $this->stripeService->createBankToken(
    //             $bankAccount->getAccountHolderName(),
    //             $bankAccount->getRoutingNumber(),
    //             $bankAccount->getAccountNumber(),
    //             $bankAccount->getCurrency()
    //         );

    //         $bankAccount->setStripeBankToken($stripeBankToken);
    //         $bankAccount->setVerifiedAt(null); // Reset verification status

    //         $this->entityManager->persist($bankAccount);
    //         $this->entityManager->flush();

    //         return $this->json([
    //             'bankAccount' => $this->bankAccountMapper->mapToDTO($bankAccount),
    //             'requiresVerification' => true,
    //             'message' => 'Bank account added successfully. Please verify micro-deposits.'
    //         ], JsonResponse::HTTP_CREATED);

    //     } catch (InvalidArgumentException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     } catch (NotFoundHttpException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
    //     } catch (ApiErrorException $e) {
    //         return $this->json(['error' => 'Stripe error: ' . $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     }
    // }

    // #[Route('/food-store/bank-account/verify', name: 'food_store_bank_account_verify', methods: ['POST'])]
    // public function verifyBankAccount(Request $request): JsonResponse
    // {
    //     $data = $this->getRequestData($request);

    //     if ($data === null) {
    //         return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     /** @var User $user */
    //     $user = $this->getUser();
    //     $foodStore = $user->getFoodStore();

    //     if (!$foodStore instanceof FoodStore) {
    //         return $this->json(['message' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
    //     }

    //     $bankAccount = $foodStore->getBankAccount();
    //     if (!$bankAccount instanceof BankAccount) {
    //         return $this->json(['message' => 'No bank account found.'], JsonResponse::HTTP_NOT_FOUND);
    //     }

    //     // Validate request data
    //     $constraints = new Assert\Collection([
    //         'fields' => [
    //             'amounts' => [
    //                 new Assert\NotBlank(),
    //                 new Assert\Type('array'),
    //                 new Assert\Count(['min' => 2, 'max' => 2]),
    //                 new Assert\All([
    //                     new Assert\Type('integer'),
    //                     new Assert\Positive()
    //                 ])
    //             ]
    //         ],
    //         'allowMissingFields' => false,
    //     ]);

    //     $errors = $this->validator->validate($data, $constraints);
    //     if (count($errors) > 0) {
    //         $formattedErrors = ValidationHelper::formatErrors($errors);
    //         return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     try {
    //         // Verify micro-deposits using the stored bank token
    //         $isVerified = $this->stripeService->verifyBankAccount(
    //             $bankAccount->getStripeBankToken(),
    //             $data['amounts']
    //         );

    //         if ($isVerified) {
    //             $bankAccount->markAsVerified();
    //             $this->entityManager->flush();

    //             return $this->json([
    //                 'bankAccount' => $this->bankAccountMapper->mapToDTO($bankAccount),
    //                 'message' => 'Bank account verified successfully'
    //             ], JsonResponse::HTTP_OK);
    //         }

    //         return $this->json(['error' => 'Verification failed'], JsonResponse::HTTP_BAD_REQUEST);

    //     } catch (InvalidArgumentException $e) {
    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     } catch (ApiErrorException $e) {
    //         return $this->json(['error' => 'Stripe verification failed: ' . $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     }
    // }


    /**
     * POST /food-store/stripe/setup
     *
     * Unified setup endpoint. Handles all three cases:
     *   - No Stripe account yet       → creates account + returns onboarding URL (201)
     *   - Account exists, incomplete  → returns fresh onboarding URL (200)
     *   - Account exists, complete    → returns status only, no URL (200)
     *
     * Frontend should always call this endpoint first. If the response contains
     * an `onboarding_url`, redirect the user there. If not, onboarding is done.
     */
    #[Route('/food-store/stripe/setup', name: 'food_store_stripe_setup', methods: ['POST'])]
    #[OA\Post(
        summary: 'Setup or resume Stripe onboarding',
        description: <<<DESC
        Unified Stripe setup endpoint. Behaviour depends on current account state:

        - **No account**: Creates a new Stripe Express account and returns an onboarding URL. (HTTP 201)
        - **Account exists, onboarding incomplete**: Returns a fresh onboarding URL. (HTTP 200)
        - **Account exists, onboarding complete**: Returns account status with no onboarding URL. (HTTP 200)

        The frontend should always call this endpoint when the seller wants to set up or resume Stripe.
        If `onboarding_url` is present in the response, redirect the user there immediately — Stripe links expire quickly.
        DESC,
        tags: ['Seller - Food Store - Stripe'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Account exists — either returning a fresh onboarding URL (incomplete) or status only (complete)',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'stripe_account_id', type: 'string', description: 'Existing Stripe account ID'),
                        new OA\Property(property: 'onboarding_complete', type: 'boolean', description: 'Whether onboarding has been fully completed'),
                        new OA\Property(property: 'onboarding_url', type: 'string', format: 'url', nullable: true, description: 'Fresh onboarding URL if onboarding is still incomplete, null otherwise'),
                        new OA\Property(property: 'message', type: 'string', example: 'Please complete Stripe onboarding.'),
                    ]
                )
            ),
            new OA\Response(
                response: 201,
                description: 'Stripe account created successfully',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'stripe_account_id', type: 'string', description: 'Newly created Stripe account ID'),
                        new OA\Property(property: 'onboarding_complete', type: 'boolean', example: false),
                        new OA\Property(property: 'onboarding_url', type: 'string', format: 'url', description: 'URL to complete Stripe onboarding'),
                        new OA\Property(property: 'message', type: 'string', example: 'Stripe account created. Please complete onboarding.'),
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: 'Stripe API error',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'Unable to process Stripe request. Please try again later.'),
                    ]
                )
            ),
            new OA\Response(response: 404, description: 'Food store not found'),
        ]
    )]
    public function setupStripeAccount(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['error' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $stripeAccountId = $foodStore->getStripeAccountId();

        // Case 1: No Stripe account yet — create one
        if (!$stripeAccountId) {
            return $this->createStripeAccount($user, $foodStore);
        }

        // Case 2 & 3: Account exists — ask Stripe for ground truth
        try {
            $accountStatus = $this->stripeService->getAccountStatus($stripeAccountId);
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe getAccountStatus failed during setup', [
                'stripe_account_id' => $stripeAccountId,
                'food_store_id' => $foodStore->getId(),
                'stripe_error' => $e->getMessage(),
                'stripe_code' => $e->getStripeCode(),
            ]);

            return $this->json(
                ['error' => 'Unable to process Stripe request. Please try again later.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        if ($this->stripeService->isOnboardingComplete($accountStatus)) {
            return $this->json([
                'stripe_account_id' => $stripeAccountId,
                'onboarding_complete' => true,
                'onboarding_url' => null,
                'message' => 'Stripe account is fully set up.',
            ], JsonResponse::HTTP_OK);
        }

        // Stripe says incomplete — return a fresh onboarding link
        return $this->generateOnboardingLinkResponse($stripeAccountId);
    }

    /**
     * GET /food-store/stripe/status
     *
     * Returns the live Stripe account status by querying the Stripe API.
     * Also auto-marks onboarding as complete in the DB when Stripe confirms it.
     *
     * Frontend should call this:
     *   - On seller dashboard load, to show/hide Stripe-dependent features.
     *   - After the user returns from the Stripe onboarding flow.
     */
    #[Route('/food-store/stripe/status', name: 'food_store_stripe_status', methods: ['GET'])]
    #[OA\Get(
        summary: 'Get Stripe account status',
        description: <<<DESC
        Returns the live status of the food store's Stripe account by querying the Stripe API directly.

        Use this endpoint:
        - On the seller dashboard to conditionally enable payout and payment features.
        - After the user returns from the Stripe onboarding redirect, to confirm completion.

        When Stripe confirms `details_submitted` and `payouts_enabled`, onboarding is automatically
        marked as complete
        DESC,
        tags: ['Seller - Food Store - Stripe'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Stripe account status',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'has_stripe_account', type: 'boolean', description: 'Whether a Stripe account has been created'),
                        new OA\Property(property: 'stripe_account_id', type: 'string', nullable: true),
                        new OA\Property(property: 'onboarding_complete', type: 'boolean', description: 'Whether details_submitted and charges_enabled are true on Stripe (can withdraw funds)'),
                        // new OA\Property(property: 'can_receive_payouts', type: 'boolean', description: 'Whether payouts_enabled is true on Stripe'),
                        // new OA\Property(property: 'can_accept_payments', type: 'boolean', description: 'Whether charges_enabled is true on Stripe'),
                        new OA\Property(property: 'requirements', type: 'object', nullable: true, description: 'Outstanding Stripe requirements'),
                        new OA\Property(property: 'capabilities', type: 'object', nullable: true, description: 'Stripe account capabilities'),
                        // new OA\Property(property: 'onboarding_completed_at', type: 'string', format: 'date-time', nullable: true, description: 'Timestamp when onboarding was first confirmed complete'),
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: 'Stripe API error',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'Unable to retrieve Stripe account status. Please try again later.'),
                    ]
                )
            ),
            new OA\Response(response: 404, description: 'Food store not found'),
        ]
    )]
    public function getStripeStatus(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['error' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $stripeAccountId = $foodStore->getStripeAccountId();

        if (!$stripeAccountId) {
            return $this->json([
                'has_stripe_account' => false,
                'stripe_account_id' => null,
                'onboarding_complete' => false,
                // 'can_receive_payouts' => false,
                // 'can_accept_payments' => false,
                // 'can_request_transfer'   => false,
                'requirements' => null,
                'capabilities' => null,
                // 'onboarding_completed_at' => null,
            ], JsonResponse::HTTP_OK);
        }

        try {
            $accountStatus = $this->stripeService->getAccountStatus($stripeAccountId);
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe getAccountStatus failed', [
                'stripe_account_id' => $stripeAccountId,
                'food_store_id' => $foodStore->getId(),
                'stripe_error' => $e->getMessage(),
                'stripe_code' => $e->getStripeCode(),
            ]);

            return $this->json(
                ['error' => 'Unable to retrieve Stripe account status. Please try again later.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        return $this->json([
            'has_stripe_account' => true,
            'stripe_account_id' => $stripeAccountId,
            'onboarding_complete' => $this->stripeService->isOnboardingComplete($accountStatus),
            // 'can_receive_payouts'     => $accountStatus['payouts_enabled'],
            // 'can_accept_payments'     => $accountStatus['charges_enabled'],
            // 'can_request_transfer'    => $this->stripeService->isOnboardingComplete($accountStatus),
            'requirements' => $accountStatus['requirements'],
            'capabilities' => $accountStatus['capabilities'],
        ], JsonResponse::HTTP_OK);
    }

    // @TODO move the onboarding helpers and functions to a seperate service
    // -------------------------------------------------------------------------
    // Stripe onboarding helpers
    // -------------------------------------------------------------------------

    private function createStripeAccount(User $user, FoodStore $foodStore): JsonResponse
    {
        try {
            $stripeAccountId = $this->stripeService->createExpressAccount($user->getEmail());
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe createExpressAccount failed', [
                'user_id' => $user->getId(),
                'stripe_error' => $e->getMessage(),
                'stripe_code' => $e->getStripeCode(),
            ]);

            return $this->json(
                ['error' => 'Unable to create Stripe account. Please try again later.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // Persist the account ID before generating the link.
        // If link generation fails below, the seller can still resume via POST /setup.
        $foodStore->setStripeAccountId($stripeAccountId);
        $this->entityManager->persist($foodStore);
        $this->entityManager->flush();

        return $this->generateOnboardingLinkResponse($stripeAccountId, isNew: true);
    }

    private function generateOnboardingLinkResponse(string $stripeAccountId, bool $isNew = false): JsonResponse
    {
        try {
            $returnUrl = $this->generateUrl('stripe_onboarding_return', [], UrlGeneratorInterface::ABSOLUTE_URL);
            $refreshUrl = $this->generateUrl('stripe_onboarding_refresh', [], UrlGeneratorInterface::ABSOLUTE_URL);
            $onboardingUrl = $this->stripeService->createAccountLink($stripeAccountId, $refreshUrl, $returnUrl);
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe createAccountLink failed', [
                'stripe_account_id' => $stripeAccountId,
                'stripe_error' => $e->getMessage(),
                'stripe_code' => $e->getStripeCode(),
            ]);

            return $this->json(
                ['error' => 'Unable to generate Stripe onboarding link. Please try again later.'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $statusCode = $isNew ? JsonResponse::HTTP_CREATED : JsonResponse::HTTP_OK;
        $message = $isNew
            ? 'Stripe account created. Please complete onboarding.'
            : 'Please complete Stripe onboarding.';

        return $this->json([
            'stripe_account_id' => $stripeAccountId,
            'onboarding_complete' => false,
            'onboarding_url' => $onboardingUrl,
            'message' => $message,
        ], $statusCode);
    }

    #[Route('/food-store/stripe/payout', name: 'food_store_stripe_payout', methods: ['POST'])]
    #[OA\Post(
        summary: 'Request payout (Stripe Transfer)',
        description: 'Requests a payout from the food store wallet to the seller\'s Stripe account. If no amount is specified, the entire wallet balance will be paid out (if it meets minimum requirements).',
        tags: ['Seller - Food Store - Stripe'],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: 'amount',
                        type: 'number',
                        format: 'float',
                        nullable: true,
                        description: 'Amount to payout in the wallet currency. Optional — defaults to full available balance if omitted.',
                        minimum: 0,
                        example: 100.50
                    ),
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Payout initiated successfully. Status will be confirmed asynchronously via webhook.',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'success', type: 'boolean', example: true),
                        new OA\Property(property: 'transfer_id', type: 'string', description: 'Stripe transfer ID'),
                        new OA\Property(property: 'amount', type: 'number', format: 'float', description: 'Payout amount'),
                        new OA\Property(property: 'currency', type: 'string', example: 'usd'),
                        new OA\Property(property: 'transaction_id', type: 'string', format: 'uuid', description: 'Internal wallet transaction ID'),
                        new OA\Property(property: 'remaining_balance', type: 'number', format: 'float', description: 'Wallet balance after deduction'),
                        new OA\Property(property: 'cooldown_until', type: 'string', format: 'date-time', description: 'Earliest time the next payout can be requested'),
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: 'Validation error or payout not allowed',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'Insufficient balance'),
                        new OA\Property(
                            property: 'code',
                            type: 'string',
                            enum: ['invalid_payload', 'validation_error', 'payout_validation_error', 'stripe_api_error'],
                            description: 'Machine-readable error code for frontend handling'
                        ),
                        new OA\Property(
                            property: 'errors',
                            type: 'array',
                            nullable: true,
                            description: 'Field-level validation errors (only present for validation_error code)',
                            items: new OA\Items(type: 'string')
                        ),
                        new OA\Property(
                            property: 'stripe_code',
                            type: 'string',
                            nullable: true,
                            description: 'Stripe error code (only present for stripe_api_error code)'
                        ),
                    ]
                )
            ),
            new OA\Response(
                response: 403,
                description: 'Wallet is blocked — payout requests are not permitted',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'Your wallet is currently blocked. Please contact support.'),
                        new OA\Property(property: 'code', type: 'string', example: 'wallet_blocked'),
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: 'Food store or Stripe account not found',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'No Stripe account found.'),
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: 'Internal server error — payout could not be completed',
                content: new OA\JsonContent(
                    type: 'object',
                    properties: [
                        new OA\Property(property: 'error', type: 'string', example: 'An internal error occurred while processing your payout.'),
                        new OA\Property(property: 'code', type: 'string', example: 'server_error'),
                    ]
                )
            ),
        ]
    )]
    public function requestPayout(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(
                ['error' => 'Invalid request payload.', 'code' => 'invalid_payload'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        /** @var User $user */
        $user = $this->getUser();
        $foodStore = $user->getFoodStore();

        if (!$foodStore instanceof FoodStore) {
            return $this->json(['error' => 'No food store found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!$foodStore->getStripeAccountId()) {
            return $this->json(['error' => 'No Stripe account found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $wallet = $foodStore->getWallet();
        if (!$wallet instanceof Wallet || !$wallet->isActive()) {
            return $this->json(
                ['error' => 'Your wallet is currently blocked. Please contact support.', 'code' => 'wallet_blocked'],
                JsonResponse::HTTP_FORBIDDEN
            );
        }

        // Validate request data
        $payoutConfig = $this->walletService->getPayoutConfig();
        $constraints = new Assert\Collection([
            'fields' => [
                'amount' => new Assert\Optional([
                    new Assert\Type(['type' => 'numeric', 'message' => 'Amount must be a number.']),
                    new Assert\Positive(['message' => 'Amount must be positive.']),
                    new Assert\GreaterThanOrEqual([
                        'value' => $payoutConfig->minimumPayout,
                        'message' => sprintf('Minimum payout amount is %s.', $payoutConfig->minimumPayout),
                    ]),
                    new Assert\LessThanOrEqual([
                        'value' => $payoutConfig->maximumPayout,
                        'message' => sprintf('Maximum payout amount is %s.', $payoutConfig->maximumPayout),
                    ]),
                ]),
            ],
            'allowMissingFields' => true,
        ]);

        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            return $this->json(
                ['errors' => ValidationHelper::formatErrors($errors), 'code' => 'validation_error'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $amount = isset($data['amount']) ? (float) $data['amount'] : null;

        try {
            $result = $this->walletService->processPayout($foodStore, $amount);

            return $this->json($result);
        } catch (\RuntimeException $e) {
            return $this->json(
                ['error' => $e->getMessage(), 'code' => 'payout_validation_error'],
                JsonResponse::HTTP_BAD_REQUEST
            );
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe API error during payout', [
                'user_id' => $user->getId(),
                'stripe_code' => $e->getStripeCode(),
                'stripe_error' => $e->getMessage(),
            ]);

            return $this->json(
                ['error' => 'Payment processor error.', 'code' => 'stripe_api_error', 'stripe_code' => $e->getStripeCode()],
                JsonResponse::HTTP_BAD_REQUEST
            );
        } catch (\Throwable $e) {
            $this->logger->error('Payout system error', [
                'user_id' => $user->getId(),
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return $this->json(
                ['error' => 'An internal error occurred while processing your payout.', 'code' => 'server_error'],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Get proxy phone numbers for order communication
     */
    #[Route('/orders/{id}/proxy-numbers', name: 'order_proxy_numbers', methods: ['GET'])]
    #[OA\Get(
        summary: "Get proxy phone numbers for order",
        description: "Retrieves the proxy phone numbers for buyer-seller communication for a specific order. The order must be paid before proxy numbers can be accessed.",
        tags: ["Seller - Orders"],
        parameters: [
            new OA\Parameter(
                name: "id",
                in: "path",
                required: true,
                description: "The ID of the order",
                schema: new OA\Schema(type: "string", format: "uuid")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with proxy numbers",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "buyer_proxy_number", type: "string", description: "Proxy phone number for the buyer", example: "+1234567890"),
                        new OA\Property(property: "seller_proxy_number", type: "string", description: "Proxy phone number for the seller", example: "+1234567891"),
                        new OA\Property(property: "session_sid", type: "string", description: "Twilio proxy session SID")
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Order not paid or invalid order ID",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order must be paid to access communication")
                    ]
                )
            ),
            new OA\Response(
                response: 404,
                description: "Order or user not found",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Order not found")
                    ]
                )
            ),
            new OA\Response(response: 503, description: "Service unavailable - Twilio proxy pool exhausted, try again shortly"),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "Failed to get proxy numbers")
                    ]
                )
            )
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
