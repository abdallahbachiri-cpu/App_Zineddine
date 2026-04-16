<?php

namespace App\Controller\Order;


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
class CartController extends BaseController
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
}
