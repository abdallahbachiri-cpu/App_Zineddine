# Stripe - Quick Reference & Common Tasks

Quick reference guide for developers and administrators managing Stripe integration.

---

## 🚀 Quick Start for Developers

### Setting Up Local Development

```bash
# 1. Install Stripe CLI
# macOS: brew install stripe/stripe-cli/stripe
# Windows: https://github.com/stripe/stripe-cli/releases
# Linux: https://stripe.com/docs/stripe-cli

# 2. Login to your Stripe account
stripe login

# 3. Forward webhooks to your local endpoint
stripe listen --forward-to localhost:8000/api/webhook/stripe
# → Returns a webhook signing secret

# 4. Copy the signing secret to .env
STRIPE_WEBHOOK_SECRET=whsec_test_...(from output above)

# 5. In another terminal, trigger test events
stripe trigger payment_intent.succeeded
stripe trigger payment_intent.payment_failed
stripe trigger refund.succeeded
```

### Testing Payment Create

```bash
# Method 1: Using Postman or cURL
curl -X POST http://localhost:8000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "food_items": [...],
    "delivery_address": {...}
  }'

# Method 2: Using Stripe test cards (frontend)
Card Number: 4242 4242 4242 4242
Expiry: Any future date
CVC: Any 3 digits
```

### Checking Logs

```bash
# Real-time logs
tail -f var/log/dev.log

# Filter for Stripe errors
tail -f var/log/dev.log | grep -i stripe

# Filter for specific event
grep "payment_intent.succeeded" var/log/dev.log

# Clear logs
rm var/log/dev.log
```

---

## 📋 Environment Variables Checklist

### Development (.env.local)

```bash
# ✅ Required for local development
STRIPE_SECRET_KEY=sk_test_...         # From https://dashboard.stripe.com/apikeys
STRIPE_PUBLIC_KEY=pk_test_...         # Public key for frontend
STRIPE_WEBHOOK_SECRET=whsec_test_...  # From stripe listen output

# ✅ Onboarding URLs (use local URLs in dev)
STRIPE_ONBOARDING_RETURN_URL=http://localhost:3000/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=http://localhost:3000/seller/stripe/refresh
```

### Staging (.env.staging)

```bash
# ⚠️ Use TEST keys for staging!
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_test_...  # From staging webhook endpoint

# ✅ Staging domain
STRIPE_ONBOARDING_RETURN_URL=https://staging-dashboard.cuisinous.ca/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=https://staging-dashboard.cuisinous.ca/seller/stripe/refresh
```

### Production (.env.production)

```bash
# 🔒 Use LIVE keys only in production!
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLIC_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_live_...  # From production webhook endpoint

# ✅ Production domain
STRIPE_ONBOARDING_RETURN_URL=https://dashboard.cuisinous.ca/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=https://dashboard.cuisinous.ca/seller/stripe/refresh
```

---

## 🔧 Common Tasks

### Task 1: Generate API Keys for New Environment

1. Go to https://dashboard.stripe.com/
2. Click **Developers** (top right)
3. Click **API Keys**
4. Copy:
    - **Secret Key** (starts with `sk_`)
    - **Publishable Key** (starts with `pk_`)
5. To switch between Test/Live, toggle in top left corner
6. Add to appropriate `.env` file

### Task 2: Set Up Webhook Endpoint

**For Staging/Production:**

1. Go to https://dashboard.stripe.com/
2. Click **Developers** → **Webhooks**
3. Click **Add Endpoint**
4. Enter Endpoint URL: `https://your-domain.com/api/webhook/stripe`
5. Under **Select events to send:**
    - Search for `payment_intent`
        - Select: `payment_intent.succeeded`
        - Select: `payment_intent.payment_failed`
    - Search for `refund`
        - Select: `refund.created`
        - Select: `refund.updated`
        - Select: `refund.succeeded`
6. Click **Add Endpoint**
7. Click on the endpoint you just created
8. Copy the **Signing Secret** (starts with `whsec_`)
9. Add to `.env` as `STRIPE_WEBHOOK_SECRET`

### Task 3: Verify Webhook Delivery

```bash
# In Stripe Dashboard:
# Developers → Webhooks → Click your endpoint → Event deliveries

# Look for:
# ✅ 2xx status = Successful delivery
# ❌ 4xx/5xx status = Failed delivery
# ⏱️ Attempted time

# Test webhook locally:
stripe listen --forward-to localhost:8000/api/webhook/stripe
stripe trigger payment_intent.succeeded
# Should see: "✓ Event received" in CLI
```

### Task 4: Test Payment Flow End-to-End

```
1. Frontend: Create order form
   └─> Fill in order details

2. Backend: Create PaymentIntent
   └─> POST /api/orders
   └─> Returns client_secret

3. Frontend: Display payment form
   └─> Use Stripe test card: 4242 4242 4242 4242
   └─> Confirm payment

4. Frontend: Payment result
   └─> Check payment status

5. Webhook: payment_intent.succeeded
   └─> Order marked as paid
   └─> Confirmation email sent

6. Check database:
   └─> Order.paymentStatus = "succeeded"
   └─> Order.stripePaymentIntentId = "pi_..."
```

### Task 5: Manual Refund Process (Admin)

```php
// In admin panel
POST /api/orders/{id}/refund

// Backend:
// 1. Validate order is paid
// 2. Call StripeService::createRefund($paymentIntentId)
// 3. Stripe processes refund

// Webhook:
// refund.succeeded → Order.paymentStatus = "refunded"
// Buyer sees refund in payment method
```

### Task 6: Seller Onboarding

```
1. Seller clicks "Connect to Stripe"
   └─> Backend: StripeService::createExpressAccount()
   └─> Returns: stripeAccountId

2. Backend: Store account ID
   └─> FoodStore.stripeAccountId = "acct_..."

3. Backend: StripeService::createAccountLink()
   └─> Returns: URL to Stripe-hosted form

4. Frontend: Redirect to URL
   └─> User completes identity verification
   └─> User enters business/personal info
   └─> User connects bank account

5. Stripe redirects to STRIPE_ONBOARDING_RETURN_URL

6. Frontend: Fetch seller status
   └─> Backend: StripeService::getAccountStatus()
   └─> Returns: charges_enabled, payouts_enabled, etc.

7. Display status to seller
   └─> "Ready to receive payouts" (if complete)
   └─> "Pending verification" (if incomplete)
```

### Task 7: Check Seller Payout Eligibility

```php
// In code or admin panel
$status = $this->stripeService->getAccountStatus($seller->getStripeAccountId());

// If missing:
$status['requirements']['currently_due']  // Must complete
$status['requirements']['eventually_due']  // Eventually needed

// Then call:
$isReady = $this->stripeService->canReceivePayouts($accountId);
// Returns: true if charges_enabled && payouts_enabled
```

### Task 8: Make Payout to Seller

```php
// In scheduled/manual payout job
$transferId = $this->stripeService->createTransfer(
    accountId: $seller->getStripeAccountId(),
    amount: $sellerAmount * 100,  // cents
    currency: 'CAD',
    metadata: [
        'wallet_transaction_id' => $transaction->getId()
    ]
);

// Store transfer ID for webhook correlation
$transaction->setStripeTransferId($transferId);
$em->flush();

// Status updates via webhook: transfer.updated
```

### Task 9: Troubleshoot Failed Webhook

```
Issue: Webhook not being delivered

Solution:
1. Check endpoint status in Stripe Dashboard
   └─ Developers → Webhooks → Click endpoint
   └─ Look at "Attempts" tab
   └─ ✅ 2xx = Success
   └─ ❌ 4xx = Client error (e.g., timeout)
   └─ ❌ 5xx = Server error

2. Check 5xx error details
   └─ Click on failed attempt
   └─ See response body for error

3. Fix the issue
   └─ If timeout: optimize code
   └─ If not found: check database query
   └─ If exception: check logs

4. Manually retry
   └─ In Stripe dashboard
   └─ Click "Resend"

5. Monitor logs for retry
   └─ tail -f var/log/dev.log | grep webhook
```

### Task 10: Debug Signature Verification Failure

```bash
# Error: Invalid signature

Check:
1. ✅ STRIPE_WEBHOOK_SECRET matches Stripe dashboard
   └─ Go to Developers → Webhooks → Click endpoint
   └─ Copy "Signing Secret"

2. ✅ Using local vs production secret
   └─ Local dev: use stripe listen output
   └─ Production: use Stripe dashboard endpoint

3. ✅ Endpoint URL matches Stripe config
   └─ Stripe: https://api.example.com/api/webhook/stripe
   └─ Code must handle POST to exact URL

4. ✅ Payload not modified
   └─ Raw request body sent to Webhook::constructEvent()
   └─ If parsed, signature breaks

5. ⏱️ Timestamp validation
   └─ Signature expires 5 minutes after event
   └─ Consider server clock skew
```

---

## 📊 Monitoring Checklist

### Daily

- [ ] Check dashboard for failed payments

    ```bash
    SELECT * FROM orders WHERE paymentStatus = 'failed'
    AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY);
    ```

- [ ] Review Stripe logs for API errors

    ```bash
    grep -i "error" var/log/prod.log | tail -20
    ```

- [ ] Verify webhooks are being delivered
    ```
    Stripe Dashboard → Developers → Webhooks → Click endpoint
    → Check recent event deliveries
    ```

### Weekly

- [ ] Review failed refunds

    ```bash
    SELECT * FROM orders WHERE paymentStatus LIKE '%refund%failed%'
    AND updated_at > DATE_SUB(NOW(), INTERVAL 7 DAY);
    ```

- [ ] Check transfer success rates

    ```bash
    SELECT COUNT(*) as total,
           SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed
    FROM wallet_transactions
    WHERE created_at > DATE_SUB(NOW(), INTERVAL 7 DAY);
    ```

- [ ] Verify seller onboarding completions
    ```bash
    SELECT COUNT(*) FROM food_stores
    WHERE stripeOnboardingCompletedAt IS NOT NULL
    AND stripeOnboardingCompletedAt > DATE_SUB(NOW(), INTERVAL 7 DAY);
    ```

### Monthly

- [ ] Audit all payment-related transactions
- [ ] Review Stripe settlement report
- [ ] Verify all fee calculations
- [ ] Check for suspicious patterns
- [ ] Review webhook event logs
- [ ] Validate database consistency vs Stripe

---

## 🚨 Common Errors & Solutions

### Error: "Invalid Signature"

```
Cause: STRIPE_WEBHOOK_SECRET mismatch or request modified

Solution:
1. Verify .env has correct secret
2. Compare with Stripe Dashboard
3. Check raw request body not parsed
4. Restart webhook listener if local
```

### Error: "PaymentIntent not found"

```
Cause: Payment ID doesn't exist or in wrong account

Solution:
1. Verify payment ID from metadata
2. Check if using connected account ID
3. Confirm order exists in database
4. Check Stripe dashboard for intent
```

### Error: "Account not onboarded"

```
Cause: Seller hasn't completed Stripe Connect

Solution:
1. Check FoodStore.stripeOnboardingCompletedAt
2. Get account status: getAccountStatus()
3. If incomplete, redirect to createAccountLink()
4. Seller completes onboarding
5. Webhook will update status OR check manually
```

### Error: "Transfer declined"

```
Cause: Seller account not eligible for payouts

Solution:
1. Call getAccountStatus() for seller
2. Check payouts_enabled = true
3. Check charges_enabled = true
4. Check no requirements pending
5. Verify bank account connected in Seller's Stripe dashboard
```

### Error: "Webhook timeout (504)"

```
Cause: Handler takes too long (> 30s)

Solution:
1. Optimize queries with JOINs
2. Add database indexes
3. Move long operations to background job
4. Use queue for email sending
5. Cache frequently accessed data
```

---

## 🔐 Security Hotspots

### Before Going to Production

- [ ] Have you reviewed all API keys in `.env`?
- [ ] Are keys in `.gitignore` / not committed?
- [ ] Is webhook secret verified?
- [ ] Is SSL/TLS enabled?
- [ ] Are we using LIVE keys, not TEST?
- [ ] Have you tested with real cards?
- [ ] Is customer data encrypted?
- [ ] Are logs not storing sensitive data?
- [ ] Is endpoint rate-limited?
- [ ] Are sensitive args logged?

### Key Security Practices

1. **Never Log Card Data**

    ```php
    // ❌ DON'T DO THIS
    $this->logger->info('Payment', ['card' => $cardData]);

    // ✅ DO THIS
    $this->logger->info('Payment', ['payment_method_id' => $pmId]);
    ```

2. **Always Verify Webhook Signature**

    ```php
    // ✅ Always verify
    $event = Webhook::constructEvent($payload, $sigHeader, $secret);
    // Throws exception if invalid
    ```

3. **Use Transaction Boundaries**

    ```php
    $em->beginTransaction();
    try {
       // Update order, send email, etc.
       $em->commit();
    } catch (Throwable $e) {
       $em->rollback();
    }
    ```

4. **Rotate API Keys Regularly**
    - Annually in production
    - After team member leaves
    - If accidentally exposed

---

## 📞 Support Resources

### For Development Issues

Check code first:

- [StripeService.php](./src/Service/Stripe/StripeService.php)
- [StripeWebhookController.php](./src/Controller/Webhook/StripeWebhookController.php)
- [STRIPE_SETUP_GUIDE.md](./STRIPE_SETUP_GUIDE.md)
- [STRIPE_TECHNICAL_ARCHITECTURE.md](./STRIPE_TECHNICAL_ARCHITECTURE.md)

Check Stripe docs:

- API Reference: https://stripe.com/docs/api
- Webhooks: https://stripe.com/docs/webhooks
- Testing: https://stripe.com/docs/testing

### For Stripe API Issues

1. Go to https://dashboardstripe.com/logs
2. Find request ID `req_...`
3. Review request/response details
4. Contact Stripe support: https://support.stripe.com

### For Database Issues

```bash
# Verify order consistency
SELECT o.id, o.stripePaymentIntentId, o.paymentStatus
FROM orders o
WHERE o.stripePaymentIntentId IS NOT NULL
ORDER BY o.created_at DESC LIMIT 10;

# Check for orphaned transactions
SELECT wt.id, wt.stripeTransferId, wt.status
FROM wallet_transactions wt
WHERE wt.stripeTransferId IS NOT NULL
AND wt.status != 'completed'
AND wt.created_at < DATE_SUB(NOW(), INTERVAL 7 DAY);
```

---

## 📈 Scaling Considerations

### As Transaction Volume Grows

- **Webhook latency** → Use async message queue (RabbitMQ/Redis)
- **Database load** → Add indexes, archive old transactions
- **API rate limits** → Batch operations, implement caching
- **Payout timing** → Move to daily automated transfers

### Recommended Improvements

1. **Async Webhook Processing**

    ```php
    // Instead of processing in webhook directly
    // Dispatch to message queue
    $bus->dispatch(new ProcessPaymentIntentSucceededMessage($eventId));
    ```

2. **Transfer Queue & Scheduler**

    ```bash
    # Daily cron: Process pending transfers
    0 2 * * * php bin/console app:process-wallet-transfers
    ```

3. **Metrics & Monitoring**
    ```
    - Track payment success rate
    - Monitor webhook latency
    - Alert on failed transfers
    - Dashboard for transaction volume
    ```

---

## Version History

| Date       | Change              | Impact                    |
| ---------- | ------------------- | ------------------------- |
| 2026-01-22 | Initial integration | All Stripe features added |
| TBD        | Async webhooks      | Improved latency          |
| TBD        | Payout automation   | Seller experience         |

---

**Last Updated:** 2026-02-24  
**Maintainer:** Development Team  
**Status:** ✅ Complete
