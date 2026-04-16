<?php

namespace App\Service\Wallet;

use App\DTO\PayoutConfigDTO;
use App\Entity\Enum\Wallet\WalletTransactionStatus;
use App\Entity\Enum\Wallet\WalletTransactionType;
use App\Entity\FoodStore;
use App\Entity\Order;
use App\Entity\PayoutConfiguration;
use App\Entity\Wallet;
use App\Entity\WalletTransaction;
use App\Helper\MoneyHelper;
use App\Repository\PayoutConfigurationRepository;
use App\Repository\WalletRepository;
use App\Repository\WalletTransactionRepository;
use App\Service\Payout\PayoutConfigMapper;
use App\Service\Stripe\StripeService;
use Doctrine\DBAL\LockMode;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;

class WalletService
{
    // const COMMISSION_RATE = 0.20;
    // const MINIMUM_PAYOUT = "5.00";
    // const MAXIMUM_PAYOUT = "500.00";
    // const DAILY_LIMIT = "1000.00"; // Daily payout limit
    // const PAYOUT_COOLDOWN_HOURS = 1; // 1h cooldown between payouts


    public function __construct(
        private EntityManagerInterface $entityManager,
        private WalletRepository $walletRepository,
        private WalletTransactionRepository $walletTransactionRepository,
        private LoggerInterface $logger,
        private StripeService $stripeService,
        private PayoutConfigurationRepository $payoutConfigurationRepository,
        private PayoutConfigMapper $payoutConfigMapper
    ) {}

    public function getPayoutConfig(): PayoutConfigDTO
    {
        $config = $this->payoutConfigurationRepository->findOneBy([]) ?? new PayoutConfiguration();
        return $this->payoutConfigMapper->mapToDTO($config);
    }


    public function creditOrderIncome(Order $order): void
    {
        $foodStore = $order->getStore();
        $this->entityManager->beginTransaction();

        $config = $this->getPayoutConfig();

        $orderGrossTotal = $order->getGrossTotal();

        $commissionAmount = MoneyHelper::multiply($orderGrossTotal, $config->commissionRate);

        $amountToPay = MoneyHelper::subtract($orderGrossTotal, $commissionAmount);

        try {
            $wallet = $this->walletRepository->createQueryBuilder('w')
                ->where('w.foodStore = :store')
                ->setParameter('store', $foodStore)
                ->getQuery()
                ->setLockMode(LockMode::PESSIMISTIC_WRITE)
                ->getOneOrNullResult();

            if (!$wallet instanceof Wallet) {
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
            }


            // $newBalance = MoneyHelper::add($wallet->getAvailableBalance(), $amountToPay);
            // $wallet->setAvailableBalance($newBalance);
            $wallet->add($amountToPay);

            $transaction = (new WalletTransaction())
                ->setWallet($wallet)
                ->setOrder($order)
                ->setAmount($amountToPay) // net amount
                ->setCommissionRate($config->commissionRate)
                ->setCommissionAmount($commissionAmount)
                ->setGrossAmount($orderGrossTotal) // gross amount (before applying commission)
                ->setType(WalletTransactionType::ORDER_INCOME)
                ->setStatus(WalletTransactionStatus::COMPLETED)
                ->setAvailableAt(new \DateTimeImmutable())
                ->setNote(sprintf(
                    "Payout for completed order #%s (Commission: %.0f%%)",
                    $order->getOrderNumber(),
                    $config->commissionRate * 100
                ));

            $this->entityManager->persist($transaction);

            $this->entityManager->persist($wallet);
            $this->entityManager->flush();
            $this->entityManager->commit();

            $this->logger->info('Payout: Order income credited to wallet successfully', [
                'orderId' => $order->getId(),
                'orderNumber' => $order->getOrderNumber(),
                'storeId' => $order->getStore()->getId(),
                'orderGrossTotal' => $orderGrossTotal,
                'commissionRate' => $config->commissionRate,
                'commissionAmount' => $commissionAmount,
                'orderIncome' => $amountToPay,
            ]);
        } catch (\Throwable $e) {
            $this->entityManager->rollback();

            $this->logger->error('Failed to credit payout for completed order', [
                'orderId' => $order->getId(),
                'orderNumber' => $order->getOrderNumber(),
                'storeId' => $order->getStore()->getId(),
                'orderGrossTotal' => $orderGrossTotal,
                'commissionRate' => $config->commissionRate,
                'commissionAmount' => $commissionAmount,
                'orderIncome' => $amountToPay,
                'exception' => $e->getMessage(),
            ]);

            throw $e;
        }
    }


    public function creditTipIncome(Order $order): void
    {
        $foodStore = $order->getStore();
        try {
            $tipAmount = $order->getTipAmount();
            $wallet = $this->walletRepository->createQueryBuilder('w')
                ->where('w.foodStore = :store')
                ->setParameter('store', $foodStore)
                ->getQuery()
                ->setLockMode(LockMode::PESSIMISTIC_WRITE)
                ->getOneOrNullResult();

            if (!$wallet instanceof Wallet) {
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
            }

            // Credit tip (no commission)


            if ($tipAmount) {
                $wallet->add($tipAmount);
                $tipTransaction = (new WalletTransaction())
                    ->setWallet($wallet)
                    ->setOrder($order)
                    ->setAmount($tipAmount)
                    ->setType(WalletTransactionType::TIP_INCOME)
                    ->setStatus(WalletTransactionStatus::COMPLETED)
                    ->setAvailableAt(new \DateTimeImmutable())
                    ->setNote(sprintf("Tip for order #%s", $order->getOrderNumber()));

                $this->entityManager->persist($tipTransaction);
            }

            $this->entityManager->persist($wallet);
            $this->entityManager->flush();

            $this->logger->info('Payout: order tip credited to wallet successfully', [
                'orderId' => $order->getId(),
                'orderNumber' => $order->getOrderNumber(),
                'storeId' => $order->getStore()->getId(),
                'tipIncome' => $tipAmount,
            ]);
        } catch (\Throwable $e) {
            $this->logger->error('Failed to credit tip payout', [
                'orderId' => $order->getId(),
                'orderNumber' => $order->getOrderNumber(),
                'storeId' => $order->getStore()->getId(),
                'tipIncome' => $tipAmount,
                'exception' => $e->getMessage(),
            ]);

            throw $e;
        }
    }


    /* Transfer funds from wallet to seller's Stripe account (Stripe Transfer) */
    /**
     * SAFE PAYOUT FLOW:
     *
     *  1.  Lock wallet (pessimistic write)
     *  2.  Run all validations (cooldown, Stripe account, balance, limits)
     *  3.  Deduct wallet balance in memory
     *  4.  Persist PENDING transaction + deducted wallet → flush + COMMIT
     *      (DB is now consistent: money is "reserved")
     *  5.  Call Stripe createTransfer()
     *      ├── SUCCESS → mark COMPLETED → flush  (happy path)
     *      └── FAILURE → mark FAILED, restore wallet balance → flush
     *                    If that flush also fails → log CRITICAL for manual reconciliation
     *
     * WHY this order matters:
     *   - Committing the deduction BEFORE hitting Stripe means the wallet can
     *     never be double-spent even if the process crashes mid-flight.
     *   - If Stripe fails we restore the balance in a clean, separate transaction.
     *   - There is no longer a scenario where Stripe succeeds but our rolled-back
     *     transaction leaves the wallet balance intact (the old double-spend bug).
     */
    public function processPayout(FoodStore $foodStore, ?float $amount = null): array
    {
        $config = $this->getPayoutConfig();

        $this->entityManager->beginTransaction();

        try {
            // ----------------------------------------------------------------
            // 1. Lock wallet (pessimistic write — prevents race conditions)
            // ----------------------------------------------------------------
            $wallet = $this->walletRepository->createQueryBuilder('w')
                ->where('w.foodStore = :store')
                ->setParameter('store', $foodStore)
                ->getQuery()
                ->setLockMode(LockMode::PESSIMISTIC_WRITE)
                ->getOneOrNullResult();

            if (!$wallet instanceof Wallet) {
                $wallet = new Wallet($foodStore);
                $this->entityManager->persist($wallet);
            }

            // ----------------------------------------------------------------
            // 2. Validations (all inside the lock so they're consistent)
            // ----------------------------------------------------------------

            // 2a. Cooldown
            $lastPayout = $this->walletTransactionRepository->findLastWithdrawal($wallet);
            if ($lastPayout && $this->isInCooldownPeriod($lastPayout, $config)) {
                $nextAvailable = $lastPayout->getCreatedAt()
                    ->modify('+' . $config->payoutCooldownHours . ' hours');
                throw new \RuntimeException(sprintf(
                    'Please wait before next payout. Next payout available at %s.',
                    $nextAvailable->format('Y-m-d H:i:s')
                ));
            }

            // 2b. Stripe account capability
            $stripeAccountId = $foodStore->getStripeAccountId();
            if (!$stripeAccountId || !$this->stripeService->canReceivePayouts($stripeAccountId)) {
                throw new \RuntimeException('Payouts not enabled for this account.');
            }

            // 2c. Available balance
            if (!MoneyHelper::isGreaterThanZero($wallet->getAvailableBalance())) {
                throw new \RuntimeException('Insufficient balance for payout.');
            }

            // 2d. Determine & validate payout amount
            $payoutAmount = $amount !== null
                ? MoneyHelper::normalize($amount)
                : $wallet->getAvailableBalance();

            if (MoneyHelper::compare($payoutAmount, $config->minimumPayout) < 0) {
                throw new \RuntimeException(sprintf('Minimum payout is %s.', $config->minimumPayout));
            }
            if (MoneyHelper::compare($payoutAmount, $config->maximumPayout) > 0) {
                throw new \RuntimeException(sprintf('Maximum payout is %s.', $config->maximumPayout));
            }
            if (MoneyHelper::compare($payoutAmount, $wallet->getAvailableBalance()) > 0) {
                throw new \RuntimeException('Requested amount exceeds available balance.');
            }

            //
            // 2e. Daily limits: REMOVED after making cooldown by hours/days

            // ----------------------------------------------------------------
            // 3. Deduct balance in memory (not yet flushed)
            // ----------------------------------------------------------------
            $balanceBefore = $wallet->getAvailableBalance();
            $wallet->deduct($payoutAmount);   // ← balance is updated in-memory here

            // ----------------------------------------------------------------
            // 4. Create PENDING transaction record
            // ----------------------------------------------------------------
            $transaction = new WalletTransaction();
            $transaction->setWallet($wallet)
                ->setAmount($payoutAmount)
                ->setType(WalletTransactionType::WITHDRAWAL)
                ->setStatus(WalletTransactionStatus::PENDING)
                ->setCurrency($wallet->getCurrency())
                ->setNote('Payout initiated');
            $this->entityManager->persist($transaction);

            // ----------------------------------------------------------------
            // 5. Commit deduction + PENDING record to DB
            //    After this point the wallet balance is officially reduced.
            //    Even if the process crashes, the money is "reserved" and the
            //    PENDING transaction acts as a reconciliation trail.
            // ----------------------------------------------------------------
            $this->entityManager->flush();
            $this->entityManager->commit();
        } catch (\Throwable $e) {
            // Validation or DB errors before Stripe — safe to rollback cleanly.
            // No money has moved yet.
            $this->entityManager->rollback();

            $this->logger->error('Payout validation/DB error (pre-Stripe)', [
                'store_id' => $foodStore->getId(),
                'amount'   => $amount,
                'error'    => $e->getMessage(),
            ]);

            throw $e;
        }

        // --------------------------------------------------------------------
        // 6. Call Stripe OUTSIDE the DB transaction.
        //    The wallet is already deducted. Now we attempt the actual transfer.
        // --------------------------------------------------------------------
        try {
            $transferId = $this->stripeService->createTransfer(
                $stripeAccountId,
                MoneyHelper::toStripeAmount($payoutAmount),
                $wallet->getCurrency(),
                [
                    'food_store_id'         => (string) $foodStore->getId(),
                    'wallet_transaction_id' => (string) $transaction->getId(),
                ]
            );

            // ----------------------------------------------------------------
            // 7. Stripe succeeded — mark transaction COMPLETED
            // ----------------------------------------------------------------
            $transaction->setStripePayoutId($transferId)
                ->setStatus(WalletTransactionStatus::COMPLETED)
                ->setAvailableAt(new \DateTimeImmutable())
                ->setNote('Payout completed');

            $this->entityManager->flush();

            $cooldownUntil = (new \DateTime())
                ->modify('+' . $config->payoutCooldownHours . ' hours')
                ->format(\DateTimeInterface::ATOM);

            $this->logger->info('Payout completed successfully', [
                'store_id'       => $foodStore->getId(),
                'seller_id'      => $foodStore->getSeller()->getId(),
                'transfer_id'    => $transferId,
                'amount'         => $payoutAmount,
                'currency'       => $wallet->getCurrency(),
                'balance_before' => $balanceBefore,
                'balance_after'  => $wallet->getAvailableBalance(),
                'cooldown_until' => $cooldownUntil,
            ]);

            return [
                'success'           => true,
                'transfer_id'       => $transferId,
                'amount'            => $payoutAmount,
                'currency'          => $wallet->getCurrency(),
                'transaction_id'    => $transaction->getId(),
                'remaining_balance' => $wallet->getAvailableBalance(),
                'cooldown_until'    => $cooldownUntil,
            ];
        } catch (\Throwable $stripeException) {
            // ----------------------------------------------------------------
            // 8. Stripe failed (API error, network timeout, etc.)
            //    The wallet was already deducted in DB. We must restore it.
            // ----------------------------------------------------------------
            $this->logger->error('Stripe transfer failed after wallet deduction — reversing', [
                'store_id'       => $foodStore->getId(),
                'transaction_id' => $transaction->getId(),
                'amount'         => $payoutAmount,
                'error'          => $stripeException->getMessage(),
            ]);

            try {
                // Restore wallet balance and mark transaction FAILED
                $wallet->add($payoutAmount); // ← reverse the deduction

                $transaction->setStatus(WalletTransactionStatus::FAILED)
                    ->setNote('Stripe transfer failed — balance restored. Error: ' . $stripeException->getMessage());

                $this->entityManager->flush();

                $this->logger->info('Wallet balance restored after Stripe failure', [
                    'store_id'       => $foodStore->getId(),
                    'transaction_id' => $transaction->getId(),
                    'restored_amount' => $payoutAmount,
                    'balance_after'  => $wallet->getAvailableBalance(),
                ]);
            } catch (\Throwable $restoreException) {
                // ----------------------------------------------------------------
                // CRITICAL: Stripe failed AND we couldn't restore the wallet.
                // The wallet is deducted but no transfer happened.
                // This MUST be resolved manually / via a reconciliation job.
                // ----------------------------------------------------------------
                $this->logger->critical('RECONCILIATION REQUIRED: Wallet deducted but Stripe transfer failed and balance restore also failed', [
                    'store_id'         => $foodStore->getId(),
                    'transaction_id'   => $transaction->getId(),
                    'amount'           => $payoutAmount,
                    'stripe_error'     => $stripeException->getMessage(),
                    'restore_error'    => $restoreException->getMessage(),
                ]);
            }

            // Re-throw the original Stripe exception so the controller handles
            // it correctly (ApiErrorException vs generic \Throwable).
            throw $stripeException;
        }
    }

    private function isInCooldownPeriod(WalletTransaction $lastPayout, PayoutConfigDTO $config): bool
    {
        $cooldownEnd = $lastPayout->getCreatedAt()->modify('+' . $config->payoutCooldownHours . ' hours');
        return new \DateTime() < $cooldownEnd;
    }
}
