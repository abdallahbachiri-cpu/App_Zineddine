# Deployment Checklist for Render

Quick checklist for deploying to Render. Print or bookmark this!

---

## Pre-Deployment (Before pushing code)

### Code Readiness

- [ ] All code committed and pushed to GitHub (`git push origin main`)
- [ ] No uncommitted changes (`git status` shows clean)
- [ ] Tests passing locally
- [ ] No `.env` or secrets in git history
- [ ] `.env.example` updated with required variables

### Configuration

- [ ] `.dockerignore` is correct (not excluding necessary files)
- [ ] `Dockerfile.render` exists in root directory
- [ ] `docker/nginx.render.conf` exists
- [ ] `docker/supervisord.conf` exists
- [ ] `docker/entrypoint` script is executable in git

### Local Testing

- [ ] App works locally with `docker-compose up`
- [ ] Can access http://localhost:8080
- [ ] Database migrations run successfully
- [ ] Default admin user created
- [ ] JWT keys generate without errors

---

## Setup Phase (First time only)

### Render Account

- [ ] Render account created (https://render.com)
- [ ] Connected to GitHub account
- [ ] Render can access your repository

### Database

- [ ] PostgreSQL database created on Render
- [ ] Database name: `cuiz_prod`
- [ ] Username and password configured
- [ ] Internal database URL copied
- [ ] Database is healthy and ready

### Web Service

- [ ] Web Service created on Render
- [ ] Dockerfile set to: `Dockerfile.render`
- [ ] Branch set to: `main` (or your branch)
- [ ] Region matches database region

---

## Environment Variables Phase (Every deployment)

### Database Variables

```
✓ DATABASE_URL=postgresql://user:pass@host:port/db
✓ DB_HOST=dpg-xxx.render.internal
✓ DB_PORT=5432
✓ DB_NAME=cuiz_prod
✓ DB_USER=cuiz_user
✓ DB_PASSWORD=(from Render dashboard)
```

- [ ] All database vars set in Render dashboard
- [ ] DATABASE_URL contains correct internal host (not external)

### App Variables

```
✓ APP_ENV=prod
✓ APP_SECRET=(32 char random string)
✓ APP_DEBUG=0
```

- [ ] APP_ENV is `prod` (not `dev`)
- [ ] APP_DEBUG is `0` (not `1`)
- [ ] APP_SECRET is different from local dev

### JWT Variables

```
✓ JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
✓ JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
✓ JWT_PASSPHRASE=your-passphrase
```

- [ ] JWT variables set
- [ ] Passphrase is strong (12+ characters)
- [ ] Same passphrase used as in local dev

### Stripe Variables (Live Keys)

```
✓ STRIPE_SECRET_KEY=sk_live_... (NOT sk_test_)
✓ STRIPE_PUBLIC_KEY=pk_live_... (NOT pk_test_)
✓ STRIPE_WEBHOOK_SECRET=whsec_live_...
```

- [ ] Using LIVE keys (not TEST keys)
- [ ] Keys are valid and active
- [ ] Webhook secret will be updated after deployment

### Stripe URLs

```
✓ STRIPE_ONBOARDING_RETURN_URL=https://dashboard.cuisinous.ca/seller/stripe/return
✓ STRIPE_ONBOARDING_REFRESH_URL=https://dashboard.cuisinous.ca/seller/stripe/refresh
```

- [ ] URLs use correct domain
- [ ] URLs use HTTPS (not HTTP)

### Email Configuration

```
✓ MAILER_FROM=noreply@cuisinous.ca
✓ MAILER_DSN=smtp+sendgrid://... (or your email service)
```

- [ ] MAILER_FROM is correct sender address
- [ ] MAILER_DSN is configured with email service

### Frontend URLs

```
✓ FRONTEND_PASSWORD_RESET_URL=https://app.cuisinous.ca/reset-password
✓ FRONTEND_EMAIL_CONFIRMATION_URL=https://app.cuisinous.ca/confirm-email
```

- [ ] URLs use correct domain
- [ ] URLs use HTTPS

### Admin User

```
✓ DEFAULT_ADMIN_EMAIL=admin@cuisinous.ca
✓ DEFAULT_ADMIN_PASSWORD=SecurePassword123!
✓ DEFAULT_ADMIN_LOCALE=en
```

- [ ] Admin email is valid
- [ ] Admin password is strong (12+ chars, mixed case, numbers, symbols)
- [ ] Locale is `en` or `fr`

---

## Deployment Phase

### Deploy Code

- [ ] Code is ready and pushed to GitHub: `git push origin main`
- [ ] No errors in `git log`

### Trigger Deployment (Choose one)

**Option A: Automatic** (happens automatically when you push)

- [ ] Wait 1-2 minutes for Render to detect push
- [ ] Deployment starts automatically

**Option B: Manual**

- [ ] Go to Render Dashboard
- [ ] Select your service
- [ ] Click "Manual Deploy" → "Deploy latest commit"
- [ ] Click "Deploy"

### Monitor Deployment

- [ ] Render Dashboard → Your Service → "Logs" tab
- [ ] Watch logs appear in real-time
- [ ] Look for:
    - [ ] "Building Docker image..."
    - [ ] "Running migrations..."
    - [ ] "Creating default admin..."
    - [ ] "Service started successfully"
    - [ ] NO "Error" or "Failed" messages

### Deployment Success Indicators

- [ ] Logs show no errors
- [ ] "Service started successfully" message appears
- [ ] Status changes to "Running" (green indicator)
- [ ] Service URL is accessible

---

## Post-Deployment Verification

### Basic Access

- [ ] Visit your Render URL in browser
- [ ] API responds (not 502/503 error)
- [ ] HTTPS works (lock icon in browser)
- [ ] Expected response (not error page)

### Database Verification

- [ ] Logs show: "Migrations executed successfully"
- [ ] No database connection errors in logs
- [ ] Default admin user created successfully

### JWT Keys

- [ ] Check logs for JWT key generation
- [ ] No "Failed to generate JWT keys" errors
- [ ] Keys should be created at `config/jwt/{private,public}.pem`

### Admin User

- [ ] Can log in with DEFAULT_ADMIN_EMAIL and password
- [ ] Admin dashboard works
- [ ] Profile shows correct locale

### Health Check

- [ ] Render shows "Status: Running" (green)
- [ ] Service hasn't restarted multiple times (indicates crash loop)

---

## Stripe Webhook Setup (After deployment)

After your app is deployed, update Stripe:

### Get Your App URL

- [ ] Render Dashboard → Your Service
- [ ] Copy the public URL (like `https://your-app-xyz.onrender.com`)

### Update Stripe Webhook

- [ ] Go to https://dashboard.stripe.com
- [ ] Developers → Webhooks
- [ ] Find your endpoint for this environment
- [ ] Update endpoint URL to:
    ```
    https://your-app-xyz.onrender.com/api/webhook/stripe
    ```
- [ ] Click "Update Endpoint"

### Update Environment Variable

- [ ] Go to webhook settings in Stripe
- [ ] Copy the "Signing Secret" (starts with `whsec_live_`)
- [ ] Render Dashboard → Your Service → Environment
- [ ] Update `STRIPE_WEBHOOK_SECRET` with new value
- [ ] Click "Save"
- [ ] Render will automatically redeploy with new variable

### Test Webhook

- [ ] Stripe Dashboard → Webhooks → Click your endpoint
- [ ] Look at "Recent Events"
- [ ] Should see 2xx status codes (success)
- [ ] If not, check app logs for webhook errors

---

## Verify All Features Work

### Payment Flow

- [ ] Create a test order
- [ ] Submit payment with test card: `4242 4242 4242 4242`
- [ ] Order status changes to "Paid"
- [ ] Confirmation email sent

### Seller Onboarding

- [ ] Seller clicks "Connect to Stripe"
- [ ] Redirected to Stripe Connect form
- [ ] Can complete onboarding
- [ ] Status shows "Ready for payouts" after completion

### Refunds

- [ ] Test refund on paid order
- [ ] Refund processes successfully
- [ ] Order status changes to "Refunded"

### Logs

- [ ] View recent logs in Render dashboard
- [ ] Look for any ERROR or WARNING messages
- [ ] Check for Stripe API errors

---

## Troubleshooting Quick Fix

### If 502 Error

```
1. Check recent logs
2. Look for: PHP-FPM crash or Nginx error
3. Try: Render Dashboard → Restart
4. Still failing?
   - Check DATABASE_URL is correct
   - Verify all env vars are set
   - Check composer.lock for conflicts
```

### If Deployment Fails

```
1. Check build logs
2. Look for: "Docker build failed"
3. Common causes:
   - Missing PHP extension
   - Composer dependency conflict
   - Out of memory
4. Fix in code, commit, redeploy
```

### If Webhook Not Working

```
1. Check Stripe dashboard → Event deliveries
2. Look for: HTTP status code
3. If 404: Wrong endpoint URL
4. If 500: Application error (check logs)
5. Update STRIPE_WEBHOOK_SECRET and redeploy
```

### If Database Won't Connect

```
1. Check DATABASE_URL in env vars
2. Verify: postgresql://user:pass@host:5432/db
3. Check: Host is .render.internal (not external)
4. Verify: Password has no special chars needing escape
5. Try: Manual restart of service
```

---

## Rollback Plan

If deployment goes wrong:

### Option 1: Restart Current Version

```
Render Dashboard → Your Service → Restart
(Restarts the currently deployed version)
```

### Option 2: Deploy Previous Commit

```
1. Render Dashboard → Deployments
2. Find previous successful deployment
3. Click "Redeploy"
(Deploys the previous version)
```

### Option 3: Emergency Disable

```
1. Render Dashboard → Your Service → Suspend
2. Fix the issue
3. Resume service
(Service unavailable temporarily but data is safe)
```

---

## Monitoring (Regular Checks)

### Daily

- [ ] Check Render dashboard for errors
- [ ] Scan logs for ERROR messages
- [ ] Verify service is "Running" (green status)

### Weekly

- [ ] Review Logs for patterns
- [ ] Check Metrics (CPU, Memory, Response Time)
- [ ] Test payment flow to ensure working
- [ ] Monitor Stripe webhook deliveries

### Monthly

- [ ] Review deployment history
- [ ] Check database size and backups
- [ ] Review error patterns and fix if needed
- [ ] Update packages if security updates available

---

## Common Commands

### View Real-Time Logs

```
Render Dashboard → Service → Logs Tab
(or use Render CLI)
```

### Restart Service

```
Render Dashboard → Service → Restart
(Wait ~30 seconds for restart)
```

### Check Deployment History

```
Render Dashboard → Service → Deployments
(Shows all past deployments and their status)
```

### Update Environment Variable

```
Render Dashboard → Service → Environment
(Edit, then click Save - triggers redeploy)
```

### Manual Redeploy

```
Render Dashboard → Service → Manual Deploy
→ Deploy latest commit
```

---

## Success Indicators Checklist

After deployment, you should see:

- [ ] ✅ Service status is "Running" (green)
- [ ] ✅ All logs show green checkmarks (no errors)
- [ ] ✅ App URL is accessible and returns 200 status
- [ ] ✅ Database shows successful migrations
- [ ] ✅ Default admin user exists
- [ ] ✅ Test payment succeeds
- [ ] ✅ Stripe webhooks show 2xx status
- [ ] ✅ Emails are being sent
- [ ] ✅ Seller onboarding works
- [ ] ✅ No errors in recent logs

---

## Quick Reference: Environment Variables by Section

**Copy-paste template** (update values):

```bash
# Database
DATABASE_URL=postgresql://cuiz_user:PASSWORD@dpg-xxx.render.internal:5432/cuiz_prod
DB_HOST=dpg-xxx.render.internal
DB_PORT=5432
DB_NAME=cuiz_prod
DB_USER=cuiz_user
DB_PASSWORD=PASSWORD

# App
APP_ENV=prod
APP_SECRET=generated-random-32-chars-here
APP_DEBUG=0

# JWT
JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
JWT_PASSPHRASE=your-strong-passphrase

# Stripe
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_PUBLIC_KEY=pk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_live_xxx
STRIPE_ONBOARDING_RETURN_URL=https://dashboard.cuisinous.ca/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=https://dashboard.cuisinous.ca/seller/stripe/refresh

# Email
MAILER_FROM=noreply@cuisinous.ca
MAILER_DSN=smtp+sendgrid://...

# Frontend
FRONTEND_PASSWORD_RESET_URL=https://app.cuisinous.ca/reset-password
FRONTEND_EMAIL_CONFIRMATION_URL=https://app.cuisinous.ca/confirm-email

# Admin
DEFAULT_ADMIN_EMAIL=admin@cuisinous.ca
DEFAULT_ADMIN_PASSWORD=SecurePassword123!
DEFAULT_ADMIN_LOCALE=en
```

---

**Deployment Date**: ******\_\_\_******  
**Deployed By**: ******\_\_\_******  
**Notes**: **********************\_\_\_**********************

---

**Last Updated:** 2026-02-24  
**For Issues**: Check DEPLOYMENT_RENDER.md for full troubleshooting
