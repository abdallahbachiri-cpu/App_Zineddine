<?php

namespace App\Controller\Payment;

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
class WalletController extends BaseController
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

}
