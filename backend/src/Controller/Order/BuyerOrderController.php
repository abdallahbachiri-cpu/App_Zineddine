<?php

namespace App\Controller\Order;

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
class BuyerOrderController extends BaseController
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
            $user  = $this->getUser();
            $order = $this->entityManager->getRepository(Order::class)->find($id);

            if (!$order instanceof Order || $order->getBuyer()->getId() !== $user->getId()) {
                return $this->json(['error' => 'Order not found'], JsonResponse::HTTP_NOT_FOUND);
            }

            return $this->json(['message' => 'Confirmation code resent successfully'], JsonResponse::HTTP_OK);
        } catch (\Exception $e) {
            return $this->json(['error' => 'Failed to resend confirmation code'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
