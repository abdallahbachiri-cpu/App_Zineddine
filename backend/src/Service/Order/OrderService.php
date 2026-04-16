<?php

namespace App\Service\Order;

use App\DTO\OrderDTO;
use App\Entity\Notification;
use App\Entity\Enum\OrderDeliveryStatus;
use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\OrderStatus;
use App\Entity\Enum\OrderTipPaymentStatus;
use App\Entity\Order;
use App\Entity\User;
use App\Exception\OrderRefundException;
use App\Helper\MoneyHelper;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\OrderRepository;
use App\Service\Email\EmailTemplateRenderer;
use App\Service\Mailer\MailService;
use App\Service\Fcm\FcmNotificationService;
use App\Service\Order\OrderMapper;
use App\Service\Stripe\StripeService;
use App\Service\Wallet\WalletService;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Contracts\Translation\TranslatorInterface;
use Symfony\Component\Mercure\HubInterface;
use Symfony\Component\Mercure\Update;

class OrderService
{
    // Maps English notification titles to Mercure event type strings
    private const TITLE_TO_EVENT = [
        'New Order Payment'  => 'ORDER_CREATED',
        'Order Cancelled'    => 'ORDER_CANCELLED',
        'Refund Successful'  => 'REFUND_COMPLETED',
        'Refund Failed'      => 'REFUND_FAILED',
        'Order Confirmed'    => 'ORDER_CONFIRMED',
        'Order Preparing'    => 'ORDER_PREPARING',
        'Order Ready'        => 'ORDER_READY',
        'Order Picked Up'    => 'ORDER_PICKED_UP',
        'Order Delivered'    => 'ORDER_DELIVERED',
    ];

    public function __construct(
        private OrderRepository $orderRepository,
        private EntityManagerInterface $entityManager,
        private OrderMapper $orderMapper,
        private readonly StripeService $stripeService,
        private MailService $mailService,
        private EmailTemplateRenderer $emailTemplateRenderer,
        private TranslatorInterface $translator,
        private WalletService $walletService,
        private readonly LoggerInterface $logger,
        private FcmNotificationService $fcmNotificationService,
        private ?HubInterface $hub = null
    ) {
    }


    public function getFilteredOrders(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        ?string $search,
        mixed $minPrice,
        mixed $maxPrice,
        ?string $buyerId = null,
        ?string $foodStoreId = null,
        array $filters = [],
        bool $isSeller = false
    ): array {

        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, Order::ALLOWED_SORT_FIELDS);
        $search = SearchHelper::validate($search);

        if ($buyerId) {
            if (!ValidationHelper::isCorrectUuid($buyerId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
        }

        if ($foodStoreId) {
            if (!ValidationHelper::isCorrectUuid($foodStoreId)) {
                throw new InvalidArgumentException('Invalid UUID format');
            }
        }

        if ($minPrice !== null) {
            if (!is_numeric($minPrice) || (float) $minPrice < 0) {
                throw new InvalidArgumentException('Min price must be a valid positive number.');
            }
            $minPrice = MoneyHelper::normalize((float) $minPrice);
        }

        if ($maxPrice !== null) {
            if (!is_numeric($maxPrice) || (float) $maxPrice < 0) {
                throw new InvalidArgumentException('Max price must be a valid positive number.');
            }
            $maxPrice = MoneyHelper::normalize((float) $maxPrice);
        }

        if ($minPrice !== null && $maxPrice !== null && $minPrice > $maxPrice) {
            throw new InvalidArgumentException('Min price cannot be greater than max price.');
        }

        $orders = $this->orderRepository->findFilteredOrders(
            $buyerId,
            $foodStoreId,
            $search,
            $sortBy,
            $sortOrder,
            $limit,
            $offset,
            $minPrice,
            $maxPrice,
            $filters
        );

        $totalOrders = $this->orderRepository->countFilteredOrders(
            $buyerId,
            $foodStoreId,
            $search,
            $minPrice,
            $maxPrice,
            $filters
        );

        $ordersDTO = $this->orderMapper->mapToDTOs($orders, $isSeller);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalOrders, $ordersDTO);
    }

    public function getOrderById(string $id): Order
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $order = $this->orderRepository->find($id);
        if (!$order instanceof Order) {
            throw new NotFoundHttpException('Order not found.');
        }

        return $order;
    }

    public function getOrderDTOById(string $id, bool $isSeller = false): OrderDTO
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $order = $this->orderRepository->find($id);
        if (!$order instanceof Order) {
            throw new NotFoundHttpException('Order not found.');
        }

        $orderDTO = $this->orderMapper->mapToDTO($order, $isSeller);
        return $orderDTO;
    }

    public function getOrderByStripePaymentIntentId(string $paymentIntentId): Order
    {
        if (empty($paymentIntentId)) {
            throw new InvalidArgumentException('Payment Intent ID cannot be empty');
        }
        $order = $this->orderRepository->findOneBy([
            'stripePaymentIntentId' => $paymentIntentId
        ]);

        if (!$order instanceof Order) {
            throw new NotFoundHttpException("Order not found for PaymentIntent: $paymentIntentId");
        }

        return $order;
    }

    public function getOrderByTipStripePaymentIntentId(string $paymentIntentId): Order
    {
        if (empty($paymentIntentId)) {
            throw new InvalidArgumentException('Payment Intent ID cannot be empty');
        }
        $order = $this->orderRepository->findOneBy([
            'tipStripePaymentIntentId' => $paymentIntentId
        ]);

        if (!$order instanceof Order) {
            throw new NotFoundHttpException("Order not found for PaymentIntent: $paymentIntentId");
        }

        return $order;
    }

    /**
     * Mark an order as paid using the PaymentIntent ID.
     *
     * @param string $paymentIntentId The Stripe PaymentIntent ID
     */
    public function markOrderAsPaidByPaymentIntent(string $paymentIntentId): Order
    {
        $this->entityManager->beginTransaction();

        try {
            $order = $this->getOrderByStripePaymentIntentId($paymentIntentId);

            $paymentIntent = $this->stripeService->retrievePaymentIntent($paymentIntentId);

            if ($paymentIntent->status !== 'succeeded') {
                throw new InvalidArgumentException('Cannot mark order as paid with non-succeeded PaymentIntent');
            }

            // Idempotency check
            if ($order->getPaymentStatus() === OrderPaymentStatus::Paid) {
                return $order;
            }

            // Business rule validation
            if ($order->getStatus() === OrderStatus::Cancelled) {
                throw new InvalidArgumentException('Cannot mark cancelled order as paid');
            }

            $order->setPaymentStatus(OrderPaymentStatus::Paid);
            $order->setPaidAt(new \DateTimeImmutable());
            $order->setPaidAmount($paymentIntent->amount_received / 100);
            $order->setPaymentCurrency($paymentIntent->currency);

            if (!empty($paymentIntent->payment_method_types)) {
                $order->setPaymentMethod($paymentIntent->payment_method_types[0]);
            }

            $this->entityManager->flush();
            $this->entityManager->commit();

            // Notify seller that order is paid
            $this->createAndSendNotification(
                $order->getBuyer(),
                $order->getStore()->getSeller(),
                'New Order Payment',
                'Customer ' . $order->getBuyer()->getFirstName() . ' has paid for order ' . $order->getOrderNumber() . '. Please confirm the order.',
                'Nouveau paiement',
                'Le client ' . $order->getBuyer()->getFirstName() . ' a paye la commande ' . $order->getOrderNumber() . '. Veuillez confirmer la commande.',
                $order->getId()
            );

            return $order;
        } catch (\InvalidArgumentException | NotFoundHttpException $e) {
            //don't throw logic/not found exceptions to stripe
            $this->entityManager->rollback();
            return $order;
        } catch (\Throwable $e) {
            $this->entityManager->rollback();
            throw $e;
        }
    }

    /**
     * Mark an order tip as paid using the PaymentIntent ID.
     *
     * @param string $paymentIntentId The Stripe PaymentIntent ID
     */
    public function markTipAsPaidByPaymentIntent(string $paymentIntentId): Order
    {
        $this->entityManager->beginTransaction();
        try {
            $order = $this->getOrderByTipStripePaymentIntentId($paymentIntentId);

            $paymentIntent = $this->stripeService->retrievePaymentIntent($paymentIntentId);

            if ($paymentIntent->status !== 'succeeded') {
                throw new InvalidArgumentException('Cannot mark order tip as paid with non-succeeded PaymentIntent');
            }

            // Idempotency check
            if ($order->getTipPaymentStatus() === OrderTipPaymentStatus::Paid) {
                $this->entityManager->rollback();
                return $order;
            }

            $order->setTipPaymentStatus(OrderTipPaymentStatus::Paid);
            $order->setTipAmount($paymentIntent->amount_received / 100);
            $order->setTipPaidAt(new \DateTimeImmutable());
            //TODO: store paid tip amount, currency and payment method seperatly same way as order payment
            // $order->setTipPaidAmount($paymentIntent->amount_received / 100);
            // $order->setPaymentCurrency($paymentIntent->currency);
            // if (!empty($paymentIntent->payment_method_types)) {
            //     $order->setTipPaymentMethod($paymentIntent->payment_method_types[0]);
            // }
            $this->entityManager->flush();

            $this->walletService->creditTipIncome($order);

            $this->entityManager->commit();

            return $order;
        } catch (\InvalidArgumentException | NotFoundHttpException $e) {
            //don't throw logic/not found exceptions to stripe
            $this->entityManager->rollback();
            return $order;
        } catch (\Throwable $e) {
            $this->entityManager->rollback();

            $this->logger->error('Failed to mark tip as paid', [
                'order_id' => $order->getId(),
                'payment_intent' => $paymentIntentId,
                'error' => $e->getMessage()
            ]);

            throw $e;
        }
    }

    /**
     * Mark an order payment status as failed using the PaymentIntent ID.
     *
     * @param string $paymentIntentId The Stripe PaymentIntent ID
     */
    public function markOrderPaymentAsFailedByPaymentIntent(string $paymentIntentId): void
    {
        $order = $this->getOrderByStripePaymentIntentId($paymentIntentId);

        // Only transition from Processing to Failed
        if ($order->getPaymentStatus() === OrderPaymentStatus::Processing) {
            $order->setPaymentStatus(OrderPaymentStatus::Failed);
            $this->entityManager->flush();
        }
    }

    /**
     * Mark an order tip payment status as failed using the PaymentIntent ID.
     *
     * @param string $paymentIntentId The Stripe PaymentIntent ID
     */
    public function markOrderTipPaymentAsFailedByPaymentIntent(string $paymentIntentId): void
    {
        $order = $this->getOrderByTipStripePaymentIntentId($paymentIntentId);

        if ($order->getTipPaymentStatus() === OrderTipPaymentStatus::Processing) {
            $order->setTipPaymentStatus(OrderTipPaymentStatus::Failed);
            $this->entityManager->flush();
        }
    }

    public function markRefundFailed(string $paymentIntentId): Order
    {
        $order = $this->getOrderByStripePaymentIntentId($paymentIntentId);

        if ($order->getPaymentStatus() === OrderPaymentStatus::Refunded) {
            return $order;
        }
        // Only allow failure marking from requested state
        if ($order->getPaymentStatus() !== OrderPaymentStatus::RefundRequested) {
            throw new InvalidArgumentException(
                sprintf('Cannot mark as failed from current status: %s', $order->getPaymentStatus()->value)
            );
        }

        $order->setPaymentStatus(OrderPaymentStatus::RefundFailed);
        $this->entityManager->flush();

        // Notify buyer about refund failure
        $this->createAndSendNotification(
            $order->getStore()->getSeller(),
            $order->getBuyer(),
            'Refund Failed',
            'Your refund for order ' . $order->getOrderNumber() . ' has failed. Please contact support.',
            'Remboursement echoue',
            'Votre remboursement pour la commande ' . $order->getOrderNumber() . ' a echoue. Veuillez contacter le support.',
            $order->getId()
        );

        return $order;
    }

    public function requestRefund(Order $order, string $initiator): void
    {
        $this->validateRefundRequest($order, $initiator);

        if ($order->getPaymentStatus() === OrderPaymentStatus::Paid) {
            try {

                $refund = $this->stripeService->createRefund(
                    paymentIntentId: $order->getStripePaymentIntentId(),
                    metadata: [
                        'order_id' => $order->getId(),
                        'cancellation_initiated_by' => $initiator
                    ]
                );

                $order->setPaymentStatus(OrderPaymentStatus::RefundRequested);
                $order->setStripeRefundId($refund->id);
            } catch (OrderRefundException $e) {
                // dd($e->getStripeCode());
                if ($e->getStripeCode() === 'charge_already_refunded') {
                    $this->reconcileExistingRefund($order);
                    return;
                }
                throw $e;
            }
        }

        $order->setStatus(OrderStatus::Cancelled);
        $this->entityManager->flush();

        // Notify the other party about the cancellation
        if ($initiator === User::TYPE_SELLER) {
            $this->createAndSendNotification(
                $order->getStore()->getSeller(),
                $order->getBuyer(),
                'Order Cancelled',
                'Your order ' . $order->getOrderNumber() . ' has been cancelled by the store.',
                'Commande annulee',
                'Votre commande ' . $order->getOrderNumber() . ' a ete annulee par le restaurant.',
                $order->getId()
            );
        } else {
            $this->createAndSendNotification(
                $order->getBuyer(),
                $order->getStore()->getSeller(),
                'Order Cancelled',
                'Order ' . $order->getOrderNumber() . ' has been cancelled by the customer.',
                'Commande annulee',
                'La commande ' . $order->getOrderNumber() . ' a ete annulee par le client.',
                $order->getId()
            );
        }
    }

    public function confirmRefund(string $paymentIntentId): Order
    {
        $order = $this->getOrderByStripePaymentIntentId($paymentIntentId);

        if ($order->getPaymentStatus() === OrderPaymentStatus::Refunded) {
            return $order; // Idempotency
        }

        // Validate allowed transitions
        $validPaymentStates = [
            OrderPaymentStatus::Paid,
            OrderPaymentStatus::RefundRequested,
            OrderPaymentStatus::RefundFailed
        ];

        if (!in_array($order->getPaymentStatus(), $validPaymentStates)) {
            throw new InvalidArgumentException(
                sprintf('Cannot refund order in current status: %s', $order->getPaymentStatus()->value)
            );
        }

        $order->setPaymentStatus(OrderPaymentStatus::Refunded);
        $order->setRefundedAt(new \DateTimeImmutable());
        // $order->setRefundedAmount($amountRefunded);
        // $order->setPaidAmount($amountRefunded); // Update with actual refunded amount

        $this->entityManager->flush();

        // Notify buyer about refund success
        $this->createAndSendNotification(
            $order->getStore()->getSeller(),
            $order->getBuyer(),
            'Refund Successful',
            'Your refund for order ' . $order->getOrderNumber() . ' has been processed successfully.',
            'Remboursement effectue',
            'Votre remboursement pour la commande ' . $order->getOrderNumber() . ' a ete effectue avec succes.',
            $order->getId()
        );

        return $order;
    }

    public function validateRefundRequest(Order $order, string $initiator): void
    {
        // Common validations
        if ($order->getStatus() === OrderStatus::Cancelled) {
            throw new ConflictHttpException('Order is already cancelled');
        }

        if ($order->getStatus() === OrderStatus::Completed) {
            throw new BadRequestHttpException('Completed orders cannot be cancelled');
        }

        if ($order->getDeliveryStatus() === OrderDeliveryStatus::Delivered) {
            throw new BadRequestHttpException('Order cannot be cancelled after it has been delivered');
        }

        // Payment-specific validations
        if ($order->getPaymentStatus() === OrderPaymentStatus::Refunded) {
            throw new ConflictHttpException('Order is already refunded');
        }

        if ($order->getPaymentStatus() === OrderPaymentStatus::RefundRequested) {
            throw new ConflictHttpException('Refund is already being processed');
        }

        // Role-specific validations
        if ($initiator === User::TYPE_BUYER) {
            // if ($order->getStatus() === OrderStatus::Confirmed) {
            //     throw new BadRequestHttpException('Confirmed orders cannot be cancelled by buyer');
            // }

            if ($order->getDeliveryStatus() === OrderDeliveryStatus::Transit) {
                throw new BadRequestHttpException('Orders in transit cannot be cancelled by buyer');
            }
        }
    }


    public function validateOrderStateForPayment(Order $order): void
    {
        // Final states that cannot be changed
        if ($order->getPaymentStatus() === OrderPaymentStatus::Refunded) {
            throw new ConflictHttpException('Cannot pay a refunded order. Please create a new order.');
        }

        if ($order->getPaymentStatus() === OrderPaymentStatus::Paid) {
            throw new ConflictHttpException('Order has already been paid');
        }

        // Order lifecycle checks
        if ($order->getStatus() === OrderStatus::Completed) {
            throw new BadRequestHttpException('Order is already completed');
        }

        if ($order->getStatus() === OrderStatus::Cancelled) {
            throw new BadRequestHttpException('Order is cancelled');
        }

        if ($order->getStatus() !== OrderStatus::Confirmed) {
            throw new BadRequestHttpException('Order must be confirmed by the seller before payment');
        }

        // Check existing payment intent
        if ($order->getStripePaymentIntentId()) {
            $this->handleExistingPaymentIntent($order);
        }
    }

    public function validateOrderStateForTipPayment(Order $order): void
    {
        if ($order->getStatus() !== OrderStatus::Completed) {
            throw new BadRequestHttpException('Order is not completed yet. Tips can only be added to completed orders.');
        }
        if ($order->getTipStripePaymentIntentId()) {
            $this->handleExistingTipPaymentIntent($order);
        }
    }

    private function handleExistingTipPaymentIntent(Order $order): void
    {
        $existingIntent = $this->stripeService->retrievePaymentIntent(
            $order->getTipStripePaymentIntentId()
        );

        switch ($existingIntent->status) {
            case 'succeeded':
                if ($order->getTipPaymentStatus() !== OrderTipPaymentStatus::Paid) {
                    $order->setTipPaymentStatus(OrderTipPaymentStatus::Paid);
                    $order->setTipPaidAt(new \DateTimeImmutable());
                    $order->setTipAmount($existingIntent->amount_received / 100);
                    //TODO: store paid tip amount seperatly same way as order payment
                    // $order->setTipAmount($existingIntent->amount_received / 100);

                    // $order->setPaymentCurrency($existingIntent->currency);
                    // TODO: add tip payment method to order
                    // if (!empty($existingIntent->payment_method_types)) {
                    //     $order->setTipPaymentMethod($existingIntent->payment_method_types[0]);
                    // }
                    $this->entityManager->flush();
                }
                throw new ConflictHttpException('Order tip has already been paid (Stripe verification)');

            case 'processing':
            case 'requires_action':
            case 'requires_confirmation':
                throw new ConflictHttpException('Tip payment is already being processed for this order');

            case 'requires_payment_method':
                // Clear failed intent to allow retry
                $order->setTipStripePaymentIntentId(null);
                $this->entityManager->flush();
                break;

            case 'canceled':
                // Allow creating new payment intent
                $order->setTipStripePaymentIntentId(null);
                $this->entityManager->flush();
                break;
        }
    }

    private function handleExistingPaymentIntent(Order $order): void
    {
        $existingIntent = $this->stripeService->retrievePaymentIntent(
            $order->getStripePaymentIntentId()
        );

        switch ($existingIntent->status) {
            case 'succeeded':
                if ($order->getPaymentStatus() !== OrderPaymentStatus::Paid) {
                    $this->markOrderAsPaidByPaymentIntent($existingIntent->id);
                }
                throw new ConflictHttpException('Order has already been paid (Stripe verification)');

            case 'processing':
            case 'requires_action':
            case 'requires_confirmation':
                throw new ConflictHttpException('Payment is already being processed for this order');

            case 'requires_payment_method':
                // Clear failed intent to allow retry
                $order->setStripePaymentIntentId(null);
                $this->entityManager->flush();
                break;

            case 'canceled':
                // Allow creating new payment intent
                $order->setStripePaymentIntentId(null);
                $this->entityManager->flush();
                break;

            default:
                $this->logger->warning('Unexpected Stripe PaymentIntent status encountered', [
                    'order_id' => $order->getId(),
                    'intent_id' => $existingIntent->id,
                    'intent_status' => $existingIntent->status,
                ]);
                throw new ConflictHttpException(
                    'Payment is in an unexpected state. Please contact support.'
                );
        }
    }


    public function sendOrderConfirmationCodeEmail(User $user, Order $order, string $locale): void
    {
        try {
            $emailContent = $this->emailTemplateRenderer->renderOrderConfirmationEmail(
                $locale,
                $user,
                $order
            );


            $subject = $this->translator->trans(
                'order_confirmation.subject',
                ['%order_number%' => $order->getOrderNumber()],
                'messages',
                $locale
            );

            $this->mailService->send(
                $user->getEmail(),
                $subject,
                $emailContent['html'],
                $emailContent['text']
            );
        } catch (\RuntimeException $e) {
            throw $e;
        }
    }


    private function reconcileExistingRefund(Order $order): void
    {
        $refund = $this->stripeService->getLatestRefund($order->getStripePaymentIntentId());

        if ($refund && $refund->status === 'succeeded') {
            $this->confirmRefund($order->getStripePaymentIntentId());
        } else {
            $order->setPaymentStatus(OrderPaymentStatus::RefundFailed);
        }

        if ($refund) {
            $order->setStripeRefundId($refund->id);
        }

        if ($order->getStatus() !== OrderStatus::Cancelled) {
            // Always mark as cancelled since this is a cancellation flow
            $order->setStatus(OrderStatus::Cancelled);
        }

        $this->entityManager->flush();
    }

    /**
     * Save a notification to the database and send an FCM push notification.
     * $sender   = who triggers the notification (e.g. seller, buyer)
     * $receiver = who receives the notification (gets push only if they have an fcmToken)
     */
    public function createAndSendNotification(User $sender, User $receiver, string $title, string $body, string $title_fr = '', string $body_fr = '', string $orderId = ''): void
    {
        $notification = new Notification();
        $notification->setTitle($title);
        $notification->setBody($body);
        $notification->setSender($sender);
        $notification->setReceiver($receiver);
        $notification->setTitleFr($title_fr);
        $notification->setBodyFr($body_fr);
        $notification->setIsShow(false);

        $order = null;
        if ($orderId) {
            $order = $this->orderRepository->find($orderId);
            if ($order) {
                $notification->setOrder($order);
            }
        }

        $this->entityManager->persist($notification);
        $this->entityManager->flush();

        // Publish real-time SSE event to Mercure hub (web dashboard)
        if ($order !== null) {
            $eventType = self::TITLE_TO_EVENT[$title] ?? 'ORDER_UPDATED';
            $this->publishOrderEvent($order, $eventType, $receiver->getId());
        }

        if ($receiver->getFcmToken()) {
            try {
                $this->fcmNotificationService->sendNotification(
                    $receiver->getFcmToken(),
                    $title,
                    $body,
                    // 'key' carries the order ID — Flutter reads notification.data['key'] to navigate to the order
                    $orderId !== '' ? ['key' => $orderId] : []
                );
            } catch (\Exception $e) {
                // Push failed but notification is saved in DB — do not crash
                $this->logger->error('FCM Push failed: ' . $e->getMessage());
            }
        }
    }

    /**
     * Publish an order status event to Mercure hub.
     * Topics published:
     *   - /orders/all            (admin dashboard sees everything)
     *   - /orders/user/{userId}  (targeted to the receiver)
     */
    private function publishOrderEvent(Order $order, string $eventType, int $receiverUserId): void
    {
        if ($this->hub === null) {
            return;
        }

        try {
            $storeName = $order->getStore()?->getName() ?? '';
            $totalAmount = method_exists($order, 'getTotalPrice') ? (float) $order->getTotalPrice() : 0.0;

            $payload = json_encode([
                'id'          => $order->getId(),
                'orderNumber' => $order->getOrderNumber(),
                'status'      => $order->getStatus()->value,
                'eventType'   => $eventType,
                'storeName'   => $storeName,
                'totalAmount' => $totalAmount,
                'updatedAt'   => (new \DateTimeImmutable())->format(\DateTimeInterface::ATOM),
            ]);

            $update = new Update(
                topics: [
                    '/orders/all',
                    '/orders/user/' . $receiverUserId,
                ],
                data: $payload
            );

            $this->hub->publish($update);
        } catch (\Throwable $e) {
            // Mercure unavailable — fail silently, do not disrupt order flow
            $this->logger->warning('Mercure publish failed: ' . $e->getMessage(), [
                'order_id' => $order->getId(),
                'event'    => $eventType,
            ]);
        }
    }
}
