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
class DishController extends BaseController
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
}
