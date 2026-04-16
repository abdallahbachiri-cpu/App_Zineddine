# Stripe Integration Setup Guide

## Overview

Cuisinous uses **Stripe** as its payment processor with **Stripe Connect** to enable marketplace functionality. This guide explains the setup requirements, configuration, and webhook management.

### Key Features Implemented

- **Stripe Connect Express Accounts** - Sellers create connected accounts for receiving payouts
- **Payment Processing** - Buyers make payments via PaymentIntent
- **Refunds** - Process full and partial refunds for orders
- **Transfers & Payouts** - Platform distributes funds to seller connected accounts
- **Webhook Events** - Asynchronous event handling for payment status changes

---

## Prerequisites

Before setting up Stripe, ensure you have:

1. **Stripe Account** - Create at https://dashboard.stripe.com/register
2. **Stripe API Keys** - Available in Dashboard → Developers → API Keys
3. **Connected Account Support** - Enable Stripe Connect in your Stripe account settings
4. **Webhook Endpoint** - Public URL accessible from the internet (production) or localhost tunnel for local testing

---

## Environment Variables

Add the following to your `.env` file:

```bash
###> stripe ###
# Platform API Keys (from https://dashboard.stripe.com/apikeys)
STRIPE_SECRET_KEY=sk_live_***  # Secret key (backend only)
STRIPE_PUBLIC_KEY=pk_live_***   # Publishable key (frontend)

# Webhook Signing Secret
# From Dashboard → Developers → Webhooks → Select Endpoint → Signing Secret
STRIPE_WEBHOOK_SECRET=whsec_***

# Frontend URLs for Stripe Connect Onboarding
STRIPE_ONBOARDING_RETURN_URL=https://dashboard.cuisinous.ca/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=https://dashboard.cuisinous.ca/seller/stripe/refresh
###< stripe ###
```

### Getting Your API Keys

1. Go to https://dashboard.stripe.com/
2. Navigate to **Developers** → **API Keys**
3. Copy the **Secret Key** (`sk_...`) and **Publishable Key** (`pk_...`)
4. For testing, use **Test Mode** keys
5. For production, switch to **Live Mode** keys

### Getting Your Webhook Secret

1. Go to **Developers** → **Webhooks**
2. Click **Add Endpoint**
3. Configure the endpoint URL (see below)
4. Select events to receive (see Webhook Events section)
5. Copy the **Signing Secret** (`whsec_...`)

---

## Webhook Configuration

### Webhook Endpoint URL

Production URL:

```
https://api.cuisinous.ca/api/webhook/stripe
```

Development URL (using a tunnel):

```
https://<your-ngrok-domain>.ngrok.io/api/webhook/stripe
```

### Required Webhook Events

Configure these events in your Stripe webhook settings:

#### Payment Events (Required)

- `payment_intent.succeeded` - Payment completed successfully
- `payment_intent.payment_failed` - Payment failed

#### Refund Events (Required)

- `refund.created` - Refund initiated
- `refund.updated` - Refund status changed
- `refund.succeeded` - Refund completed

#### Account Events (Currently Disabled - Optional for Future)

- `account.updated` - Seller account status changed (e.g., onboarding completed)

#### Transfer Events (Currently Disabled - Optional for Future)

- `transfer.updated` - Payout transfer status changed
- `transfer.failed` - Payout transfer failed

### Steps to Configure Webhooks

1. **Log in to Stripe Dashboard**
2. Go to **Developers** → **Webhooks**
3. Click **Add Endpoint**
4. Enter your endpoint URL (e.g., `https://api.cuisinous.ca/api/webhook/stripe`)
5. Select **Events to send**:
    - Check: `payment_intent.succeeded`
    - Check: `payment_intent.payment_failed`
    - Check: `refund.created`, `refund.updated`, `refund.succeeded`
6. Click **Add Endpoint**
7. Copy the **Signing Secret** and add to `.env` as `STRIPE_WEBHOOK_SECRET`

### Testing Webhooks Locally

Use Stripe CLI to forward webhook events to your local development environment:

```bash
# Install Stripe CLI: https://stripe.com/docs/stripe-cli

# Login to your account
stripe login

# Forward webhook events to your local endpoint
stripe listen --forward-to localhost:8000/api/webhook/stripe

# In another terminal, trigger a test event
stripe trigger payment_intent.succeeded
```

---

## Configuration Files

### services.yaml

```yaml
App\Service\Stripe\StripeService:
    arguments:
        $platformSecretKey: "%env(STRIPE_SECRET_KEY)%"
        $publishableKey: "%env(STRIPE_PUBLIC_KEY)%"

App\Controller\StripeController:
    arguments:
        $onboardingFrontendReturnUrl: "%env(STRIPE_ONBOARDING_RETURN_URL)%"
        $onboardingFrontendRefreshUrl: "%env(STRIPE_ONBOARDING_REFRESH_URL)%"

App\Controller\Webhook\StripeWebhookController:
    arguments:
        $stripeWebhookSecret: "%stripe_webhook_secret%"
```

### security.yaml

The Stripe webhook endpoint is configured to accept public (unauthenticated) requests:

```yaml
access_control:
    - { path: ^/api/webhook/stripe, roles: PUBLIC_ACCESS }
    - { path: ^/api/stripe, roles: PUBLIC_ACCESS }
```

---

## Core Components

### 1. StripeService (`src/Service/Stripe/StripeService.php`)

Main service for all Stripe API interactions.

**Key Methods:**

#### Payment Processing

```php
createAndConfirmPaymentIntent()     // Create & confirm payment immediately
createPaymentIntent()               // Create payment intent for later confirmation
retrievePaymentIntent()             // Fetch payment intent status
```

#### Refunds

```php
createRefund()                      // Process a refund
getLatestRefund()                   // Retrieve latest refund for a payment
```

#### Stripe Connect (Seller Accounts)

```php
createExpressAccount()              // Create seller Express account
createAccountLink()                 // Generate onboarding link for seller
getAccountStatus()                  // Check account onboarding status
canReceivePayouts()                 // Verify payout eligibility
isOnboardingComplete()              // Single source of truth for onboarding status
```

#### Transfers & Payouts

```php
createTransfer()                    // Transfer funds to connected account
retrievePayout()                    // Check payout status
```

#### Utilities

```php
getPublishableKey()                 // Get frontend-safe key
createEphemeralKey()                // Create ephemeral key for mobile
```

### 2. StripeWebhookController (`src/Controller/Webhook/StripeWebhookController.php`)

Processes incoming Stripe webhook events.

**Handled Events:**

- `payment_intent.succeeded` - Marks order as paid, sends confirmation email
- `payment_intent.payment_failed` - Updates order payment status to failed
- `refund.created|updated|succeeded` - Processes refund status changes

**Webhook Flow:**

```
1. Stripe sends POST request to /api/webhook/stripe
2. Signature verified using STRIPE_WEBHOOK_SECRET
3. Event type determined
4. Appropriate handler method called
5. Database transaction managed (commit on success, rollback on error)
6. Response returned to Stripe
```

### 3. StripeController (`src/Controller/StripeController.php`)

Handles Stripe Connect onboarding redirects.

**Endpoints:**

- `GET /api/stripe/onboarding/return` - Called after seller completes onboarding
- `GET /api/stripe/onboarding/refresh` - Called if seller needs to refresh onboarding

---

## Key Workflows

### Workflow 1: Buyer Makes Payment

```
1. Frontend gets Stripe Publishable Key
2. Buyer enters card details
3. Frontend creates PaymentMethod
4. Frontend calls backend to create PaymentIntent
5. Backend calls StripeService::createAndConfirmPaymentIntent()
6. Stripe returns payment status (succeeded/requires_action/failed)
7. Frontend handles 3D Secure if needed
8. Webhook: payment_intent.succeeded → Order marked as paid
```

### Workflow 2: Seller Onboarding

```
1. Seller initiates account creation
2. Backend calls StripeService::createExpressAccount()
3. Backend calls StripeService::createAccountLink()
4. Seller redirected to Stripe-hosted onboarding form
5. Seller completes identity verification, banking info
6. Stripe redirects to STRIPE_ONBOARDING_RETURN_URL
7. Frontend updates seller account with Stripe Connect status
```

### Workflow 3: Platform Payouts

```
1. Order is paid and settled
2. Platform calculates seller's portion (after commission)
3. Backend creates WalletTransaction
4. Backend calls StripeService::createTransfer() to connected account
5. Transfer sent to seller's Stripe account
6. Webhook: transfer.updated → Update transaction status
7. Funds appear in seller's bank account (based on payout schedule)
```

### Workflow 4: Refund Processing

```
1. Buyer requests refund
2. Admin/seller approves refund
3. Backend calls StripeService::createRefund()
4. Stripe processes refund request
5. Webhook: refund.succeeded → Order marked as refunded
6. Funds returned to buyer's payment method
```

---

## Metadata Usage

Stripe metadata is used to track orders and transactions:

### PaymentIntent Metadata

```php
'order_id'      => $order->getId()              // Track which order
'payment_type'  => 'order' | 'tip'              // Payment type
'buyer_id'      => $buyer->getId()              // Customer reference
```

### Transfer Metadata

```php
'wallet_transaction_id' => $transaction->getId() // Link to internal transaction
```

---

## Error Handling

### API Errors

All API calls handle `Stripe\Exception\ApiErrorException`:

```php
try {
    $paymentIntent = $this->client->paymentIntents->create($options);
} catch (ApiErrorException $e) {
    $this->logger->error('Stripe API error', [
        'error_code' => $e->getStripeCode(),
        'error' => $e->getMessage()
    ]);
    throw $e;
}
```

### Webhook Signature Verification

```php
try {
    $event = Webhook::constructEvent($payload, $sigHeader, $this->stripeWebhookSecret);
} catch (SignatureVerificationException $e) {
    // Reject webhook if signature is invalid
    return new JsonResponse(['error' => 'Invalid signature'], 400);
}
```

### Transaction Management

Database transactions prevent partial updates:

```php
$this->entityManager->beginTransaction();
try {
    // Process payment, update order status, etc.
    $this->entityManager->commit();
} catch (Throwable $e) {
    $this->entityManager->rollback();
    throw $e;
}
```

---

## Testing Guide

### 1. Local Testing with Stripe CLI

```bash
# Terminal 1: Start Stripe webhook listener
stripe listen --forward-to localhost:8000/api/webhook/stripe

# Terminal 2: In another terminal, trigger test events
stripe trigger payment_intent.succeeded
stripe trigger payment_intent.payment_failed
stripe trigger refund.succeeded
```

### 2. Test Payment Cards

Use these cards in test mode (https://stripe.com/docs/testing):

```
Success:        4242 4242 4242 4242
Requires Auth:  4000 0025 0000 3155
Declined:       4000 0000 0000 0002
Insufficient:   4000 0000 0000 9995
```

### 3. Manual Webhook Testing

```bash
# Using curl to test signature verification
curl -X POST http://localhost:8000/api/webhook/stripe \
  -H "Content-Type: application/json" \
  -H "stripe-signature: t=123456,v1=invalid" \
  -d '{"type":"payment_intent.succeeded","data":{"object":{}}}'
```

### 4. Check Logs

```bash
# Tail Stripe-related logs
tail -f var/log/dev.log | grep -i stripe
```

---

## Production Checklist

Before going live:

- [ ] Switch API keys from Test to Live in `.env`
- [ ] Update webhook endpoint URL to production domain
- [ ] Create production webhook in Stripe dashboard
- [ ] Update `STRIPE_WEBHOOK_SECRET` with production signing secret
- [ ] Update `STRIPE_ONBOARDING_RETURN_URL` to production domain
- [ ] Update `STRIPE_ONBOARDING_REFRESH_URL` to production domain
- [ ] Test full payment flow with real cards
- [ ] Verify SSL/TLS certificate is valid
- [ ] Ensure webhook endpoint is publicly accessible
- [ ] Monitor logs for webhook failures
- [ ] Set up alerts for failed payments
- [ ] Establish seller payout cadence (daily/weekly/monthly)
- [ ] Test refund process in production
- [ ] Verify ACH transfer times for sellers

---

## Security Considerations

### API Key Protection

- **Never** commit API keys to version control
- Use `.env.local` for local development
- Use environment variables or secrets manager in production
- Rotate keys annually
- Use separate keys per environment (dev, staging, production)

### Webhook Security

- Always verify webhook signature using `STRIPE_WEBHOOK_SECRET`
- Reject requests with invalid signatures
- Webhook endpoint must accept POST only
- Implement idempotency - same webhook may be delivered multiple times
- Log all webhook events for audit trail

### Connected Accounts

- Verify seller identity before enabling payouts
- Monitor for suspicious transfer patterns
- Implement velocity limits on transfers
- Store seller Stripe account ID securely

### PCI Compliance

- Never handle raw card data (use PaymentMethod API)
- Never log card numbers or CVV
- Use HTTPS for all Stripe communication
- Regular security audits recommended

---

## Troubleshooting

### Webhook Not Being Received

1. Check webhook endpoint is publicly accessible
2. Verify `STRIPE_WEBHOOK_SECRET` matches Stripe dashboard
3. Check server logs for 400/500 errors
4. Verify webhook is enabled in Stripe dashboard
5. Use Stripe CLI to test locally

### Payment Intent Fails

1. Check card is valid test mode card
2. Verify amount is in cents (multiply by 100)
3. Check currency matches account settings
4. Verify metadata doesn't exceed size limits
5. Check Stripe account has payments enabled

### Signature Verification Fails

1. Confirm webhook secret is correct
2. Check webhook is using latest API version
3. Verify request body hasn't been modified
4. Ensure timestamp is recent (< 5 minutes)

### Transfer Not Processing

1. Verify seller account has onboarding complete
2. Check seller's Stripe capabilities are active
3. Verify transfer amount is positive and <= account balance
4. Check seller's country supports transfers Out
5. Review Stripe dashboard for account restrictions

### Email Confirmation Not Sending

1. Check MAILER_DSN is configured
2. Verify OrderService is injected correctly
3. Check email logs in `var/log/`
4. Verify seller locale is set correctly

---

## Useful Resources

- **Stripe Documentation**: https://stripe.com/docs
- **Stripe Connect**: https://stripe.com/docs/connect
- **PaymentIntent API**: https://stripe.com/docs/payments/payment-intents
- **Webhooks**: https://stripe.com/docs/webhooks
- **Testing**: https://stripe.com/docs/testing
- **Stripe CLI**: https://stripe.com/docs/stripe-cli
- **PHP Library**: https://github.com/stripe/stripe-php

---

## Support

For Stripe API issues:

- Check Stripe dashboard under Developers → Events
- Review API documentation at https://stripe.com/docs/api
- Contact Stripe support: https://support.stripe.com

For integration issues:

- Review logs in `var/log/dev.log` or `var/log/prod.log`
- Check database transaction integrity
- Verify webhook handlers in `StripeWebhookController`
- Ensure all environment variables are set
