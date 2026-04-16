# Stripe Integration - Technical Architecture

This document provides an in-depth look at the Stripe integration implementation for developers.

---

## System Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Frontend (React/Vue)                       │
│  - Payment form with Stripe Elements                         │
│  - Seller onboarding link handler                            │
└────────────┬────────────────────────────────────┬────────────┘
             │                                    │
             │ HTTP                               │ HTTP
             ▼                                    ▼
┌────────────────────────────┐     ┌──────────────────────────┐
│  API Endpoints             │     │  Return/Refresh URLs     │
│  - POST /order             │     │  - /seller/stripe/return │
│  - POST /payment           │     │  - /seller/stripe/refresh│
│  - POST /refund            │     └──────────────────────────┘
└──────────┬─────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────┐
│          OrderService / StripeService (Backend)              │
│  - StripeService handles all Stripe API calls                │
│  - OrderService manages order & payment status               │
│  - Database transactions ensure consistency                  │
└────────────────────┬─────────────────────────────────────────┘
                     │ REST API
                     ▼
        ┌────────────────────────────┐
        │   Stripe API              │
        │  - PaymentIntent          │
        │  - Transfers              │
        │  - Refunds                │
        │  - Connect Accounts       │
        └─────────────┬──────────────┘
                      │
                      ├─ Async Events (Webhooks)
                      │
                      ▼
        ┌────────────────────────────┐
        │  Webhook Endpoint          │
        │  POST /api/webhook/stripe  │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ StripeWebhookController    │
        │ - Signature verification   │
        │ - Event routing            │
        │ - Handler dispatching      │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ Event Handlers             │
        │ - handlePayment*           │
        │ - handleRefund*            │
        │ - handleTransfer*          │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ Database (Doctrine ORM)    │
        │ - Order status updates     │
        │ - Wallet transactions      │
        │ - FoodStore sync           │
        └────────────────────────────┘
```

---

## File Structure

```
src/
├── Service/Stripe/
│   └── StripeService.php              # Main Stripe API wrapper
├── Controller/
│   ├── StripeController.php           # Onboarding redirect handlers
│   └── Webhook/
│       └── StripeWebhookController.php # Webhook event processor
├── Entity/
│   ├── Order.php                      # Order entity with payment status
│   ├── FoodStore.php                  # Seller account with Stripe ID
│   ├── WalletTransaction.php          # Payout tracking
│   └── Enum/
│       ├── OrderPaymentStatus.php     # paid, failed, refunded, etc.
│       └── Wallet/WalletTransactionStatus.php
├── Repository/
│   ├── OrderRepository.php
│   ├── FoodStoreRepository.php
│   └── WalletTransactionRepository.php
└── Exception/
    └── OrderRefundException.php       # Refund-specific exception

config/
├── services.yaml                      # Service configuration & DI
├── packages/
│   ├── security.yaml                  # Webhook endpoint auth config
│   └── framework.yaml                 # Routing configuration
└── routes/
    └── [platform].yaml                # API route definitions
```

---

## Service Layer: StripeService

### Initialization

```php
$stripeService = new StripeService(
    platformSecretKey: $secretKey,     // sk_live_*** from Stripe
    publishableKey: $pubKey,           // pk_live_*** from Stripe
    entityManager: $em,                // Doctrine EntityManager
    logger: $logger                    // PSR-3 Logger
);
```

### Key Implementation Details

#### 1. StripeClient Initialization

```php
private StripeClient $client;

public function __construct(...) {
    $this->client = new StripeClient($this->platformSecretKey);
}
```

The Stripe SDK is initialized once during service instantiation and reused for all API calls.

#### 2. Currency Handling

```php
public const DEFAULT_CURRENCY = 'CAD';

public function createTransfer(
    string $accountId,
    int $amount,
    string $currency = 'cad',  // lowercase for API
    array $metadata = []
): string
```

Always convert amounts to cents (multiply by 100) before sending to Stripe.

#### 3. Connected Account Operations

```php
public function createAndConfirmPaymentIntent(
    ...,
    ?string $connectedAccountId = null,
    ...
): PaymentIntent {
    $requestOptions = [];
    if ($connectedAccountId) {
        $requestOptions['stripe_account'] = $connectedAccountId;
    }

    $paymentIntent = $this->client->paymentIntents->create(
        $options,
        $connectedAccountId ? $requestOptions : []
    );
}
```

When operating on a connected account, pass the account ID in request options.

#### 4. Error Handling Pattern

```php
try {
    // Stripe API call
    return $this->client->paymentIntents->create($options);
} catch (ApiErrorException $e) {
    $this->logger->error('Stripe API error', [
        'error_code' => $e->getStripeCode(),
        'error' => $e->getMessage()
    ]);
    throw $e;  // Re-throw for caller to handle
}
```

All API errors are caught, logged, and re-thrown.

---

## Controller Layer

### StripeWebhookController

#### Webhook Signature Verification

```php
public function __invoke(Request $request): JsonResponse
{
    $payload = $request->getContent();
    $sigHeader = $request->headers->get('stripe-signature');

    try {
        // Verify signature using STRIPE_WEBHOOK_SECRET
        $event = Webhook::constructEvent(
            $payload,
            $sigHeader,
            $this->stripeWebhookSecret
        );
    } catch (SignatureVerificationException $e) {
        // Invalid signature - reject
        return new JsonResponse(['error' => 'Invalid signature'], 400);
    }
}
```

The webhook signature is verified using the secret from environment. Stripe SDK handles the cryptographic verification internally.

#### Event Routing

```php
switch ($event->type) {
    case 'payment_intent.succeeded':
        $this->handlePaymentIntentSucceeded($event->data->object);
        break;

    case 'payment_intent.payment_failed':
        $this->handlePaymentIntentFailed($event->data->object);
        break;

    // ... more cases
}
```

Events are routed to specific handler methods based on type.

#### Transaction Management

```php
try {
    $this->entityManager->beginTransaction();

    // Process payment, update order, etc.

    $this->entityManager->commit();
} catch (Throwable $e) {
    $this->entityManager->rollback();
    $this->logger->error($message, $context);
    throw $e;  // Let framework handle
}
```

Database transactions ensure atomicity - either all changes are saved or none.

### Payment Intent Succeeded Handler

```php
private function handlePaymentIntentSucceeded(PaymentIntent $paymentIntent): void
{
    $paymentType = $paymentIntent->metadata['payment_type'] ?? 'order';

    if ($paymentType === 'tip') {
        $order = $this->orderService->markTipAsPaidByPaymentIntent(
            $paymentIntent->id
        );
    } else {
        $order = $this->orderService->markOrderAsPaidByPaymentIntent(
            $paymentIntent->id
        );

        // Send confirmation email
        $user = $order->getBuyer();
        $this->orderService->sendOrderConfirmationCodeEmail(
            $user,
            $order,
            $user->getLocale()
        );
    }

    $this->logger->info('Order marked as paid', [
        'order_id' => $order->getId(),
        'payment_intent' => $paymentIntent->id,
    ]);
}
```

#### Metadata Extraction

The `metadata` field is used to identify the order and payment type:

```php
// Metadata is set when creating PaymentIntent
$metadata = [
    'order_id' => $order->getId(),
    'payment_type' => 'order',  // or 'tip'
    'buyer_id' => $buyer->getId()
];
```

#### Error Handling

```php
try {
    $order = $this->orderService->markOrderAsPaidByPaymentIntent($id);
} catch (InvalidArgumentException $e) {
    // Payment intent not found or invalid
    $this->logger->error('Failed to mark order as paid', [
        'payment_intent' => $paymentIntent->id,
        'error' => $e->getMessage()
    ]);
    // Don't re-throw - webhook already processed
} catch (Throwable $e) {
    // Unexpected error
    $this->logger->error('Unexpected error', ['error' => $e->getMessage()]);
    throw $e;  // Will be caught by outer try-catch
}
```

### Refund Handler

```php
private function handleRefundWebhook(Refund $refund): void
{
    // Transaction management
    $this->entityManager->beginTransaction();
    try {
        // 1. Validate refund has payment_intent reference
        if (!$refund->payment_intent) {
            throw new RuntimeException('Missing payment_intent');
        }

        // 2. Fetch order by payment intent ID
        $order = $this->orderService->getOrderByStripePaymentIntentId(
            $refund->payment_intent
        );

        // 3. Store Stripe refund ID
        $order->setStripeRefundId($refund->id);

        // 4. Check if already processed (idempotency)
        if ($this->isRefundFullyProcessed($order, $refund)) {
            $this->entityManager->commit();
            return;
        }

        // 5. Update status based on refund status
        switch ($refund->status) {
            case 'succeeded':
                $order->setPaymentStatus(OrderPaymentStatus::Refunded);
                break;
            case 'failed':
                $order->setPaymentStatus(OrderPaymentStatus::RefundFailed);
                break;
            case 'pending':
                $order->setPaymentStatus(OrderPaymentStatus::RefundPending);
                break;
        }

        $this->entityManager->commit();
    } catch (Throwable $e) {
        $this->entityManager->rollback();
        throw $e;
    }
}
```

#### Idempotency Check

```php
private function isRefundFullyProcessed(Order $order, Refund $refund): bool
{
    return match ($refund->status) {
        'succeeded' =>
            $order->getPaymentStatus() === OrderPaymentStatus::Refunded
            && $order->getStripeRefundId() === $refund->id,
        'failed' =>
            $order->getPaymentStatus() === OrderPaymentStatus::RefundFailed
            && $order->getStripeRefundId() === $refund->id,
        default => false,
    };
}
```

Webhooks can be delivered multiple times. This check prevents duplicate processing.

---

## Integration Points

### 1. Order Creation Flow

```
Frontend creates form data
    ↓
POST /api/orders → OrderController
    ↓
OrderService validates order
    ↓
StripeService::createPaymentIntent() called
    ↓
PaymentIntent ID returned to frontend
    ↓
Frontend displays payment form with client secret
    ↓
Buyer confirms payment
    ↓
payment_intent status: succeeded/requires_action/failed
```

### 2. Seller Onboarding Flow

```
Seller clicks "Connect to Stripe"
    ↓
StripeService::createExpressAccount()
    ↓
StripeService::createAccountLink()
    ↓
Account link URL redirected to
    ↓
Seller completes identity/banking in Stripe-hosted form
    ↓
Stripe redirects to STRIPE_ONBOARDING_RETURN_URL
    ↓
Frontend fetches seller status via API
    ↓
StripeService::getAccountStatus() shows payouts_enabled
```

### 3. Payout Flow

```
Order payment received → Settled to platform account
    ↓
WalletService calculates seller portion
    ↓
WalletTransaction created
    ↓
StripeService::createTransfer() to seller's connected account
    ↓
Transfer metadata includes wallet_transaction_id
    ↓
Webhook: transfer.updated received
    ↓
WalletTransaction status updated
    ↓
Seller sees payout in their Stripe account
    ↓
Seller's bank receives ACH transfer on payout schedule
```

---

## Database Entity Relationships

### Order Entity

```php
class Order {
    #[ORM\ManyToOne(targetEntity: User::class)]
    private User $buyer;

    #[ORM\Column(enumType: OrderPaymentStatus::class)]
    private OrderPaymentStatus $paymentStatus;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripePaymentIntentId = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeRefundId = null;
}
```

### FoodStore Entity (Seller Account)

```php
class FoodStore {
    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeAccountId = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $stripeOnboardingCompletedAt = null;
}
```

### WalletTransaction Entity

```php
class WalletTransaction {
    #[ORM\ManyToOne(targetEntity: FoodStore::class)]
    private FoodStore $seller;

    #[ORM\Column(enumType: WalletTransactionStatus::class)]
    private WalletTransactionStatus $status;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeTransferId = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripePayoutId = null;
}
```

---

## Logging Strategy

### Log Levels Used

```php
$this->logger->info()    // Normal operations: PaymentIntent created
$this->logger->warning() // Unexpected but handled: Payment failed
$this->logger->error()   // Errors that require attention: API failure
$this->logger->debug()   // Detailed debugging: Duplicate webhook
```

### Log Context Structure

```php
$this->logger->info('Payment processed', [
    'order_id'          => $order->getId(),
    'payment_intent'    => $paymentIntent->id,
    'amount'            => $paymentIntent->amount,
    'currency'          => $paymentIntent->currency,
    'buyer_id'          => $order->getBuyer()->getId(),
    'payment_status'    => $paymentIntent->status,
]);
```

Standard context keys:

- `order_id` - Order database ID
- `payment_intent` - Stripe PaymentIntent ID
- `amount` - Amount in cents
- `currency` - Currency code (CAD, USD, etc.)
- `stripe_account_id` - Connected account ID
- `error` - Error message from exception
- `exception` - Full exception object

---

## API Flow Examples

### Example 1: Creating a Payment

```php
// In OrderController or payment API endpoint
$stripeService->createPaymentIntent(
    amount: $totalAmount * 100,        // Convert to cents
    currency: 'CAD',
    metadata: [
        'order_id' => $orderId,
        'buyer_id' => $buyerId,
        'payment_type' => 'order'
    ],
    connectedAccountId: null,          // Payment to platform
    setupFutureUsage: false
);

// Response
PaymentIntent {
    id: "pi_1234567890",
    client_secret: "pi_1234567890_secret_abcdef",
    status: "requires_payment_method",
    amount: 5000,
    currency: "cad",
    metadata: { order_id: "123", ... }
}

// Frontend receives client_secret and displays payment form
```

### Example 2: Seller Onboarding

```php
// In seller onboarding endpoint
$accountId = $stripeService->createExpressAccount(
    email: $seller->getEmail(),
    country: 'CA'
);

// Store in database
$seller->setStripeAccountId($accountId);
$entityManager->flush();

// Generate onboarding link
$onboardingUrl = $stripeService->createAccountLink(
    accountId: $accountId,
    refreshUrl: 'https://dashboard.cuisinous.ca/seller/stripe/refresh',
    returnUrl: 'https://dashboard.cuisinous.ca/seller/stripe/return'
);

// Response
"https://connect.stripe.com/onboarding/v2/..."

// Frontend redirects user to this URL
```

### Example 3: Transferring Funds

```php
// After order payment settles and seller's portion calculated
$transferId = $stripeService->createTransfer(
    accountId: $seller->getStripeAccountId(),
    amount: $sellerAmount * 100,       // Convert to cents
    currency: 'CAD',
    metadata: [
        'wallet_transaction_id' => $transaction->getId()
    ]
);

// Response
"tr_1234567890"

// Store in database for webhook correlation
$transaction->setStripeTransferId($transferId);
$entityManager->flush();
```

---

## Constants & Enums

### Currency

```php
public const DEFAULT_CURRENCY = 'CAD';
```

### Payment Statuses

```php
enum OrderPaymentStatus {
    case Pending;
    case Succeeded;
    case Failed;
    case Refunded;
    case RefundFailed;
    case RefundPending;
}
```

### Webhook Event Types

```
payment_intent.succeeded
payment_intent.payment_failed
refund.created
refund.updated
refund.succeeded
account.updated (commented out)
transfer.updated (commented out)
```

---

## Testing Considerations

### Unit Testing StripeService

```php
public function testCreatePaymentIntentReturnsPaymentIntent()
{
    $mockHttpClient = $this->createMock(StripeClient::class);
    // Mock API calls

    $service = new StripeService($secret, $pub, $em, $logger);
    $result = $service->createPaymentIntent(...);

    $this->assertInstanceOf(PaymentIntent::class, $result);
}
```

### Integration Testing Webhooks

```php
public function testPaymentIntentSucceededWebhook()
{
    $payload = json_encode([
        'id' => 'evt_123',
        'type' => 'payment_intent.succeeded',
        'data' => ['object' => ['id' => 'pi_123', ...]]
    ]);

    $request = Request::create(
        '/api/webhook/stripe',
        'POST',
        [],
        [],
        [],
        ['HTTP_STRIPE_SIGNATURE' => 'valid_sig'],
        $payload
    );

    $response = $controller->__invoke($request);
    $this->assertResponseStatusCode(200, $response);
}
```

### E2E Testing

Use Stripe CLI to trigger webhooks in a staging environment:

```bash
stripe trigger payment_intent.succeeded \
  --override metadata.order_id=123
```

---

## Performance Considerations

### API Call Overhead

Each Stripe API call has ~100-200ms latency. Consider:

- Async webhooks for status updates (not blocking)
- Batch operations when possible
- Caching account status when appropriate

### Database Query Optimization

```php
// Fetch order with related entities
$order = $this->orderRepository->findOneBy(['id' => $orderId]);
// Will trigger additional queries for buyer, items, etc.

// Better: Use JOIN
$qb = $this->orderRepository->createQueryBuilder('o')
    ->join('o.buyer', 'b')
    ->where('o.id = :id')
    ->setParameter('id', $orderId);
```

### Connection Pool

For production, configure Stripe connection pooling in Doctrine if handling high volume.

---

## Monitoring & Alerts

### Key Metrics to Monitor

1. **Payment Success Rate** - Track failed_to_succeeded ratio
2. **Webhook Latency** - Time between event and processing
3. **Refund Processing Time** - Average time for refunds to complete
4. **Transfer Success Rate** - Failed transfers to sellers
5. **API Error Rate** - Stripe API errors over time

### Log Analysis

```bash
# Find all payment failures
grep "payment_intent.payment_failed" var/log/prod.log

# Find API errors
grep "Stripe API error" var/log/prod.log

# Find webhook failures
grep "Stripe webhook processing failed" var/log/prod.log
```

---

## Version Compatibility

- **Stripe PHP SDK**: Uses `stripe/stripe-php` (auto-updated via Composer)
- **Symfony**: 6.x+
- **PHP**: 8.1+

Check `composer.json` for pinned versions.

---

## Related Documentation

- [STRIPE_SETUP_GUIDE.md](./STRIPE_SETUP_GUIDE.md) - Setup and configuration
- [StripeService.php](./src/Service/Stripe/StripeService.php) - API wrapper code
- [StripeWebhookController.php](./src/Controller/Webhook/StripeWebhookController.php) - Webhook handler code
- Stripe API Reference: https://stripe.com/docs/api
