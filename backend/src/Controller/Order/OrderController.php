<?php

namespace App\Controller\Order;


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
class OrderController extends BaseController
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

}
