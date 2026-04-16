<?php

namespace App\Service\Stripe;

use App\Entity\Order;
use App\Exception\OrderRefundException;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Psr\Log\LoggerInterface;
use RuntimeException;
use Stripe\Exception\ApiErrorException;
use Stripe\StripeClient;
use Stripe\PaymentIntent;
use Stripe\Payout;
use Stripe\Refund;
use Stripe\Transfer;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class StripeService
{
    private StripeClient $client;
    public const DEFAULT_CURRENCY = 'CAD';

    public function __construct(
        private readonly string $platformSecretKey,
        private readonly string $publishableKey,
        private readonly EntityManagerInterface $entityManager,
        private readonly LoggerInterface $logger,
    ) {
        $this->client = new StripeClient($this->platformSecretKey);
    }

    public function getPublishableKey(): string
    {
        return $this->publishableKey;
    }

    public function createAndConfirmPaymentIntent(
        int $amount,
        string $currency,
        string $paymentMethodId,
        array $metadata = [],
        ?string $connectedAccountId = null,
        bool $allowRedirects = false,
        ?string $returnUrl = null,
        bool $offSession = false
        // array $paymentMethodTypes = ['card']
    ): PaymentIntent {
        $options = [
            'amount' => $amount,
            'currency' => $currency,
            'payment_method' => $paymentMethodId,
            'metadata' => $metadata,
            'confirm' => true, // Confirm immediately
            // 'payment_method_types' => $paymentMethodTypes,
            'automatic_payment_methods' => [
                'enabled' => true,
                'allow_redirects' => $allowRedirects ? 'always' : 'never',
            ],
            'use_stripe_sdk' => true, // Optimized for mobile
            'off_session'  => $offSession,
        ];

        // Required if allowing redirects (e.g., 3D Secure)
        if ($allowRedirects && $returnUrl) {
            $options['return_url'] = $returnUrl;
        }

        // Handle connected accounts (Stripe Connect)
        $requestOptions = [];
        if ($connectedAccountId) {
            $requestOptions['stripe_account'] = $connectedAccountId;
        }


        try {
            $paymentIntent = $this->client->paymentIntents->create(
                $options,
                $connectedAccountId ? ['stripe_account' => $connectedAccountId] : []
            );

            // Log payment intent creation
            // $this->logger->info('PaymentIntent created', [
            //     'id' => $paymentIntent->id,
            //     'status' => $paymentIntent->status
            // ]);

            return $paymentIntent;
        } catch (ApiErrorException $e) {
            // $this->logger->error('Stripe API error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Create a PaymentIntent for a buyer to pay.
     */
    public function createPaymentIntent(
        int $amount,
        string $currency,
        array $metadata = [],
        ?string $connectedAccountId = null,
        bool $setupFutureUsage = false,
        ?string $paymentMethodId = null,
    ): PaymentIntent {
        $options = [
            'amount' => $amount,
            'currency' => $currency,
            'metadata' => $metadata,
            'automatic_payment_methods' => [
                'enabled' => true,
                'allow_redirects' => 'never'
            ],
            'capture_method' => 'automatic',
        ];

        if ($paymentMethodId) {
            $options['payment_method'] = $paymentMethodId;
        }

        if ($setupFutureUsage) {
            $options['setup_future_usage'] = 'off_session';
        }

        $requestOptions = [];
        if ($connectedAccountId) {
            $requestOptions['stripe_account'] = $connectedAccountId;
        }

        try {
            return $this->client->paymentIntents->create($options, $requestOptions);
        } catch (ApiErrorException $e) {
            throw $e;
        }
    }

    public function createEphemeralKey(string $customerId): string
    {
        try {
            $key = $this->client->ephemeralKeys->create([
                'customer' => $customerId,
            ]);
            return $key->secret;
        } catch (ApiErrorException $e) {
            $this->logger->error('Ephemeral key creation failed', ['error' => $e->getMessage()]);
            throw new RuntimeException('Could not create ephemeral key');
        }
    }

    /**
     * Retrieve a PaymentIntent by its ID.
     */
    public function retrievePaymentIntent(string $paymentIntentId): PaymentIntent
    {
        return $this->client->paymentIntents->retrieve($paymentIntentId);
    }


    public function createRefund(string $paymentIntentId, array $metadata = []): Refund
    {
        $params = [
            'payment_intent' => $paymentIntentId,
            'metadata' => $metadata
        ];

        try {
            return $this->client->refunds->create($params);
        } catch (ApiErrorException $e) {
            $this->logger->error('Stripe refund failed', [
                'payment_intent' => $paymentIntentId,
                'error_code' => $e->getStripeCode(),
                'error' => $e->getMessage()
            ]);

            throw new OrderRefundException(
                'Refund processing failed: ' . $e->getMessage(),
                $e->getStripeCode() ?? 'unknown_error',
                $e
            );
        }
    }

    public function getLatestRefund(string $paymentIntentId): ?Refund
    {
        try {
            return $this->client->refunds->all([
                'payment_intent' => $paymentIntentId,
                'limit' => 1
            ])->first();
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to fetch refunds', [
                'payment_intent' => $paymentIntentId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Create a Stripe Express account for a seller
     */
    public function createExpressAccount(string $email, string $country = 'CA'): string
    {
        try {
            $account = $this->client->accounts->create([
                'type' => 'express',
                'country' => $country,
                'email' => $email,
                'capabilities' => [
                    'card_payments' => ['requested' => true],
                    'transfers' => ['requested' => true],
                ],
            ]);

            $this->logger->info('Stripe Express account created', [
                'account_id' => $account->id,
                'email' => $email
            ]);

            return $account->id;
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to create Stripe Express account', [
                'email' => $email,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    /**
     * Create an account link for seller onboarding
     */
    public function createAccountLink(string $accountId, string $refreshUrl, string $returnUrl): string
    {
        try {
            $accountLink = $this->client->accountLinks->create([
                'account' => $accountId,
                'refresh_url' => $refreshUrl,
                'return_url' => $returnUrl,
                'type' => 'account_onboarding',
            ]);

            return $accountLink->url;
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to create account link', [
                'account_id' => $accountId,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    /**
     * Get account status and capabilities
     */
    public function getAccountStatus(string $accountId): array
    {
        try {
            $account = $this->client->accounts->retrieve($accountId, [
                'expand' => ['capabilities']
            ]);

            return [
                'charges_enabled' => $account->charges_enabled,
                'payouts_enabled' => $account->payouts_enabled,
                'details_submitted' => $account->details_submitted,
                'requirements' => [
                    'currently_due' => $account->requirements->currently_due ?? [],
                    'eventually_due' => $account->requirements->eventually_due ?? [],
                    'past_due' => $account->requirements->past_due ?? [],
                    'pending_verification' => $account->requirements->pending_verification ?? [],
                ],
                'capabilities' => [
                    'card_payments' => $account->capabilities->card_payments ?? 'inactive',
                    'transfers' => $account->capabilities->transfers ?? 'inactive',
                ]
            ];
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to retrieve account status', [
                'account_id' => $accountId,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    /**
     * Create a transfer to seller's stripe account (Stripe Transfer)
     */
    public function createTransfer(string $accountId, int $amount, string $currency = 'cad', array $metadata = []): string
    {
        try {
            $transfer = $this->client->transfers->create([
                'amount'      => $amount,
                'currency'    => strtolower($currency),
                'destination' => $accountId,  // connected account ID
                'metadata'    => $metadata,
            ]);

            $this->logger->info('Stripe Transfer created', [
                'transfer_id' => $transfer->id,
                'account_id'  => $accountId,
                'amount'      => $amount,
            ]);

            return $transfer->id;
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to create Stripe transfer', [
                'account_id' => $accountId,
                'amount'     => $amount,
                'error'      => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Check if account can receive payouts
     */
    public function canReceivePayouts(string $accountId): bool
    {
        try {
            $status = $this->getAccountStatus($accountId);
            return $this->isOnboardingComplete($status);
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to check payout eligibility', [
                'account_id' => $accountId,
                'error'      => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Single definition of what "onboarding complete" means across all endpoints.
     * Both /setup and /status derive their onboarding_complete from this method,
     * so they can never disagree.
     */
    public function isOnboardingComplete(array $accountStatus): bool
    {
        return $accountStatus['details_submitted'] && $accountStatus['charges_enabled'];
    }

    public function retrievePayout(string $payoutId, string $accountId): array
    {
        try {
            $payout = $this->client->payouts->retrieve($payoutId, [
                'stripe_account' => $accountId
            ]);

            return [
                'id' => $payout->id,
                'amount' => $payout->amount,
                'currency' => $payout->currency,
                'status' => $payout->status,
                'arrival_date' => $payout->arrival_date,
                'metadata' => $payout->metadata,
                'failure_code' => $payout->failure_code,
                'failure_message' => $payout->failure_message
            ];
        } catch (ApiErrorException $e) {
            $this->logger->error('Failed to retrieve payout', [
                'payout_id' => $payoutId,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }
}
