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
class FoodStoreController extends BaseController
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
}
