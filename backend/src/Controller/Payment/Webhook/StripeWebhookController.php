<?php

declare(strict_types=1);

namespace App\Controller\Payment\Webhook;

use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\Wallet\WalletTransactionStatus;
use App\Entity\FoodStore;
use App\Entity\Order;
use App\Entity\WalletTransaction;
use App\Helper\MoneyHelper;
use App\Helper\ValidationHelper;
use App\Repository\FoodStoreRepository;
use App\Repository\WalletTransactionRepository;
use App\Service\Order\OrderService;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Psr\Log\LoggerInterface;
use RuntimeException;
use Stripe\Account;
use Stripe\Exception\SignatureVerificationException;
use Stripe\PaymentIntent;
use Stripe\Refund;
use Stripe\Webhook;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/webhook/stripe', name: 'stripe_webhook', methods: ['POST'])]
class StripeWebhookController
{
    public function __construct(
        private readonly string                    $stripeWebhookSecret,
        private readonly LoggerInterface           $logger,
        private readonly OrderService              $orderService,
        private readonly FoodStoreRepository       $foodStoreRepository,
        private WalletTransactionRepository        $walletTransactionRepository,
        private readonly EntityManagerInterface    $entityManager,
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $payload   = $request->getContent();
        $sigHeader = $request->headers->get('stripe-signature');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $this->stripeWebhookSecret);
        } catch (\UnexpectedValueException | SignatureVerificationException $e) {
            $this->logger->error('Stripe webhook signature verification failed.', ['exception' => $e]);
            return new JsonResponse(['error' => 'Invalid signature'], 400);
        }

        try {
            switch ($event->type) {
                // case 'account.updated':
                //     $this->handleAccountUpdated($event->data->object);
                //     break;

                case 'payment_intent.succeeded':
                    $this->handlePaymentIntentSucceeded($event->data->object);
                    break;

                case 'payment_intent.payment_failed':
                    $this->handlePaymentIntentFailed($event->data->object);
                    break;

                case 'refund.created':
                case 'refund.updated':
                case 'refund.succeeded':
                    $this->handleRefundWebhook($event->data->object);
                    break;

                // case 'transfer.updated':
                // // case 'transfer.failed':
                //     $this->handleTransferWebhook($event->data->object->toArray());
                //     break;

                default:
                    $this->logger->info('Unhandled Stripe event type.', ['type' => $event->type]);
            }

            return new JsonResponse(['status' => 'received']);
        } catch (\Throwable $e) {
            $this->logger->error('Stripe webhook processing failed', [
                'event_id'   => $event->id,
                'event_type' => $event->type,
                'exception'  => $e,
            ]);
            return new JsonResponse(['error' => 'Processing failed'], 500);
        }
    }

    // -------------------------------------------------------------------------
    // account.updated
    // -------------------------------------------------------------------------

    /**
     * Fired by Stripe whenever a Connect account's state changes.
     * We use it to keep our DB in sync with Stripe's real account status:
     *
     *  - Onboarding just completed  → set stripeOnboardingCompletedAt
     *  - Account was disabled/restricted after onboarding → clear it
     *    (e.g. compliance issue, missing docs, fraud) so the seller is prompted to fix it.
     *
     * This is the production-grade alternative to relying solely on polling /status.
     */
    // private function handleAccountUpdated(Account $account): void
    // {
    //     $stripeAccountId = $account->id;

    //     $foodStore = $this->foodStoreRepository->findOneBy(['stripeAccountId' => $stripeAccountId]);

    //     if (!$foodStore instanceof FoodStore) {
    //         // Could be an account from a different context — not an error
    //         $this->logger->info('account.updated received for unknown food store', [
    //             'stripe_account_id' => $stripeAccountId,
    //         ]);
    //         return;
    //     }

    //     $detailsSubmitted = $account->details_submitted;
    //     $payoutsEnabled   = $account->payouts_enabled;
    //     $chargesEnabled   = $account->charges_enabled;

    //     $this->logger->info('Stripe account.updated received', [
    //         'stripe_account_id' => $stripeAccountId,
    //         'food_store_id'     => $foodStore->getId(),
    //         'details_submitted' => $detailsSubmitted,
    //         'payouts_enabled'   => $payoutsEnabled,
    //         'charges_enabled'   => $chargesEnabled,
    //     ]);

    //     $currentCompletedAt = $foodStore->getStripeOnboardingCompletedAt();

    //     // Case 1: Onboarding just completed — mark it
    //     if ($detailsSubmitted && $payoutsEnabled && $currentCompletedAt === null) {
    //         $foodStore->setStripeOnboardingCompletedAt(new \DateTimeImmutable());

    //         $this->logger->info('Stripe onboarding marked complete via webhook', [
    //             'stripe_account_id' => $stripeAccountId,
    //             'food_store_id'     => $foodStore->getId(),
    //         ]);
    //     }

    //     // Case 2: Account was previously complete but Stripe has disabled it
    //     // (compliance issue, fraud, missing docs requested later, etc.)
    //     // Reset so the seller is forced to fix it via the onboarding flow.
    //     if ($currentCompletedAt !== null && (!$detailsSubmitted || !$payoutsEnabled)) {
    //         $foodStore->setStripeOnboardingCompletedAt(null);

    //         $this->logger->warning('Stripe account disabled after onboarding — resetting completion', [
    //             'stripe_account_id' => $stripeAccountId,
    //             'food_store_id'     => $foodStore->getId(),
    //             'details_submitted' => $detailsSubmitted,
    //             'payouts_enabled'   => $payoutsEnabled,
    //             'charges_enabled'   => $chargesEnabled,
    //         ]);
    //     }

    //     $this->entityManager->persist($foodStore);
    //     $this->entityManager->flush();
    // }

    // -------------------------------------------------------------------------
    // payment_intent.succeeded
    // -------------------------------------------------------------------------

    private function handlePaymentIntentSucceeded(PaymentIntent $paymentIntent): void
    {
        $paymentType = $paymentIntent->metadata['payment_type'] ?? 'order';

        $this->logger->info('Processing successful payment', [
            'payment_type'   => $paymentType,
            'payment_intent' => $paymentIntent->id,
        ]);

        if ($paymentType === 'tip') {
            try {
                $order = $this->orderService->markTipAsPaidByPaymentIntent($paymentIntent->id);
                $this->logger->info('Tip marked as paid', [
                    'order_id'       => $order->getId(),
                    'payment_intent' => $paymentIntent->id,
                ]);
            } catch (InvalidArgumentException $e) {
                $this->logger->error('Failed to mark tip as paid', [
                    'payment_intent' => $paymentIntent->id,
                    'error'          => $e->getMessage(),
                ]);
            } catch (\Throwable $e) {
                $this->logger->error('Unexpected error during tip payment processing', [
                    'payment_intent' => $paymentIntent->id,
                    'error'          => $e->getMessage(),
                ]);
                throw $e;
            }
        } else {
            try {
                $order = $this->orderService->markOrderAsPaidByPaymentIntent($paymentIntent->id);
                $this->logger->info('Order marked as paid', [
                    'order_id'       => $order->getId(),
                    'payment_intent' => $paymentIntent->id,
                ]);
                $user = $order->getBuyer();
                $this->orderService->sendOrderConfirmationCodeEmail($user, $order, $user->getLocale());
            } catch (InvalidArgumentException $e) {
                $this->logger->error('Failed to mark order as paid', [
                    'payment_intent' => $paymentIntent->id,
                    'error'          => $e->getMessage(),
                ]);
            } catch (RuntimeException $e) {
                $this->logger->error('Failed to send confirmation email', [
                    'order_id' => $order->getId(),
                    'error'    => $e->getMessage(),
                ]);
            } catch (\Throwable $e) {
                $this->logger->error('Unexpected error during order payment processing', [
                    'order_id'       => $order->getId(),
                    'payment_intent' => $paymentIntent->id,
                    'error'          => $e->getMessage(),
                ]);
                throw $e;
            }
        }
    }

    // -------------------------------------------------------------------------
    // payment_intent.payment_failed
    // -------------------------------------------------------------------------

    private function handlePaymentIntentFailed(PaymentIntent $paymentIntent): void
    {
        $paymentType = $paymentIntent->metadata['payment_type'] ?? 'order';

        $this->logger->warning('Processing failed payment', [
            'payment_type'    => $paymentType,
            'order_id'        => $paymentIntent->metadata['order_id'] ?? null,
            'payment_intent'  => $paymentIntent->id,
            'failure_message' => $paymentIntent->last_payment_error?->message,
        ]);

        try {
            $this->entityManager->beginTransaction();

            if ($paymentType === 'tip') {
                $this->orderService->markOrderTipPaymentAsFailedByPaymentIntent($paymentIntent->id);
            } else {
                $this->orderService->markOrderPaymentAsFailedByPaymentIntent($paymentIntent->id);
            }

            $this->entityManager->commit();
        } catch (\InvalidArgumentException | NotFoundHttpException $e) {
            $this->entityManager->rollback();
            $this->logger->error('Failed to process failed payment intent', [
                'payment_type'   => $paymentType,
                'order_id'       => $paymentIntent->metadata['order_id'] ?? null,
                'payment_intent' => $paymentIntent->id,
                'error'          => $e->getMessage(),
            ]);
        } catch (\Throwable $e) {
            $this->entityManager->rollback();
            $this->logger->error('Failed to process failed payment intent', [
                'payment_type'   => $paymentType,
                'order_id'       => $paymentIntent->metadata['order_id'] ?? null,
                'payment_intent' => $paymentIntent->id,
                'error'          => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    // -------------------------------------------------------------------------
    // refund.*
    // -------------------------------------------------------------------------

    private function handleRefundWebhook(Refund $refund): void
    {
        $this->entityManager->beginTransaction();
        try {
            if (!$refund->payment_intent) {
                throw new RuntimeException('Missing payment_intent reference in refund');
            }

            $order = $this->orderService->getOrderByStripePaymentIntentId($refund->payment_intent);
            $order->setStripeRefundId($refund->id);

            if ($this->isRefundFullyProcessed($order, $refund)) {
                $this->logger->debug('Refund already processed', [
                    'refund_id'      => $refund->id,
                    'current_status' => $order->getPaymentStatus()->value,
                ]);
                $this->entityManager->commit();
                return;
            }

            switch ($refund->status) {
                case 'succeeded':
                    $this->orderService->confirmRefund($refund->payment_intent);
                    break;
                case 'failed':
                    $this->orderService->markRefundFailed($refund->payment_intent);
                    break;
                case 'pending':
                    break;
            }

            $this->entityManager->commit();
        } catch (\Throwable $e) {
            $this->entityManager->rollback();
            $this->logRefundError($refund, $e);
            throw $e;
        }
    }

    private function isRefundFullyProcessed(Order $order, Refund $refund): bool
    {
        return match ($refund->status) {
            'succeeded' => $order->getPaymentStatus() === OrderPaymentStatus::Refunded && $order->getStripeRefundId() === $refund->id,
            'failed'    => $order->getPaymentStatus() === OrderPaymentStatus::RefundFailed && $order->getStripeRefundId() === $refund->id,
            default     => false,
        };
    }

    private function logRefundError(?Refund $refund, \Throwable $e): void
    {
        $context = [
            'event' => 'refund_processing_error',
            'error' => $e->getMessage(),
            'stack' => $e->getTraceAsString(),
        ];

        if ($refund) {
            $context += [
                'refund_id'      => $refund->id,
                'payment_intent' => $refund->payment_intent,
                'status'         => $refund->status,
                'amount'         => $refund->amount,
            ];
        }

        $this->logger->error('Refund processing failed', $context);
    }

    // -------------------------------------------------------------------------
    // Transfer.*
    // -------------------------------------------------------------------------

    private function handleTransferWebhook(array $transfer): void
    {
        $transferId = $transfer['id'];
        $metadata   = $transfer['metadata'] ?? [];

        if ($this->walletTransactionRepository->findByPayoutId($transferId)) {
            $this->logger->debug('Duplicate transfer webhook received', ['transfer_id' => $transferId]);
            return;
        }

        if (
            empty($metadata['wallet_transaction_id'])
            || !is_string($metadata['wallet_transaction_id'])
            || !ValidationHelper::isCorrectUuid($metadata['wallet_transaction_id'])
        ) {
            $this->logger->warning('Transfer webhook missing transaction reference', [
                'transfer_id' => $transferId,
                'metadata'    => $metadata,
            ]);
            return;
        }

        $transaction = $this->walletTransactionRepository->find($metadata['wallet_transaction_id']);
        if (!$transaction instanceof WalletTransaction) {
            $this->logger->error('Transfer webhook references unknown transaction', [
                'transfer_id'    => $transferId,
                'transaction_id' => $metadata['wallet_transaction_id'],
            ]);
            return;
        }

        switch ($transfer['status'] ?? null) {
            case 'paid':
                if ($transaction->getStatus() !== WalletTransactionStatus::PENDING) {
                    $this->logger->warning('Invalid status transition for paid transfer', [
                        'current' => $transaction->getStatus(),
                        'new'     => 'COMPLETED',
                    ]);
                    return;
                }
                $transaction->setStripePayoutId($transferId);
                $transaction->setStatus(WalletTransactionStatus::COMPLETED);
                $transaction->setAvailableAt(new \DateTimeImmutable());

                $this->entityManager->persist($transaction);
                $this->entityManager->flush();
                break;

            case 'failed':
                if ($transaction->getStatus() === WalletTransactionStatus::FAILED) {
                    $this->logger->debug('Transfer already marked as failed', [
                        'transfer_id'    => $transferId,
                        'transaction_id' => $transaction->getId(),
                    ]);
                    return;
                }

                if ($transaction->getStatus() !== WalletTransactionStatus::PENDING) {
                    $this->logger->error('Illegal state transition for failed transfer', [
                        'current_status'     => $transaction->getStatus(),
                        'expected_status'    => 'PENDING',
                        'transfer_id'        => $transferId,
                        'transaction_amount' => $transaction->getAmount(),
                    ]);
                    return;
                }

                try {
                    $this->entityManager->beginTransaction();

                    $transaction->setStripePayoutId($transferId);
                    $transaction->setStatus(WalletTransactionStatus::FAILED);
                    $wallet = $transaction->getWallet();
                    $wallet->add($transaction->getAmount());

                    $this->entityManager->persist($wallet);
                    $this->entityManager->persist($transaction);
                    $this->entityManager->flush();
                    $this->entityManager->commit();

                    $this->logger->info('Transfer failed — funds returned to wallet', [
                        'amount'      => $transaction->getAmount(),
                        'wallet_id'   => $wallet->getId(),
                        'new_balance' => $wallet->getAvailableBalance(),
                    ]);
                } catch (\Exception $e) {
                    $this->entityManager->rollback();
                    $this->logger->critical('Failed to process transfer failure — funds not returned', [
                        'error'          => $e->getMessage(),
                        'transaction_id' => $transaction->getId(),
                        'transfer_id'    => $transferId,
                    ]);
                    throw $e;
                }
                return;

            default:
                $this->logger->info('Unhandled transfer status', [
                    'status'      => $transfer['status'] ?? 'unknown',
                    'transfer_id' => $transferId,
                ]);
                return;
        }
    }
}
