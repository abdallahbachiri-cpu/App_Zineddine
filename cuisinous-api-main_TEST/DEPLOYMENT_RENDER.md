# Deployment Guide - Render Platform

Simple guide for deploying Cuisinous to Render.

---

## What is Render?

**Render** is a cloud platform that automatically deploys your Docker container when you push code to GitHub. It handles:

- Building your Docker image
- Running and scaling containers
- SSL/TLS certificates (HTTPS)
- PostgreSQL database hosting
- Log streaming
- Health checks

---

## Architecture Overview

### Local Development

```
Your Machine
├── docker-compose.yaml (defines all services)
├── Dockerfile (dev build for local testing)
├── nginx.conf (connects to app service)
└── Services:
    ├── app (PHP-FPM) - port 9000
    ├── nginx - port 8080
    ├── db (PostgreSQL) - port 5432
    └── mailhog (test emails)
```

### Render Production

```
Render Cloud
├── Single Container (all-in-one)
├── Dockerfile.render (production optimized)
├── nginx.render.conf (127.0.0.1:9000 for FPM)
├── Port 10000 (exposed to internet)
└── Services:
    ├── PHP-FPM (inside container)
    ├── Nginx (inside container)
    └── PostgreSQL (separate managed service)
```

---

## Before You Start

### Prerequisites

You need:

1. **Render Account** - https://render.com (free tier available)
2. **GitHub Repository** - Code pushed to GitHub
3. **Stripe Keys** - Live keys ready (staging or production)
4. **Database Ready** - PostgreSQL database configured in Render

### Files Used for Deployment

These are specific to Render:

- `Dockerfile.render` - Multi-stage production image
- `docker/nginx.render.conf` - Nginx config using port 10000
- `docker/supervisord.conf` - Manages PHP-FPM + Nginx processes
- `docker/entrypoint` - Runs migrations, creates admin, generates JWT keys

---

## Step 1: Prepare Your GitHub Repository

### Ensure .gitignore is correct

```bash
# These should NOT be committed:
.env
.env.local
.env.*.local
node_modules/
var/cache/
var/log/
vendor/

# These SHOULD be committed:
.env.example
docker/
Dockerfile.render
docker-compose.yaml
composer.json
composer.lock
```

### Push code to GitHub

```bash
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

---

## Step 2: Create PostgreSQL Database on Render

### Via Render Dashboard

1. Go to https://dashboard.render.com/
2. Click **New +** → **PostgreSQL**
3. Configure:
    - **Name**: `cuisinous-db` (or desired name)
    - **Database**: `cuiz_prod`
    - **User**: `cuiz_user`
    - **Region**: Pick closest region (e.g., `us-east`)
    - **Plan**: Initially use free tier for testing
4. Click **Create Database**
5. Wait for database to be ready (~1 min)
6. Copy the **Internal Database URL** (looks like):
    ```
    postgresql://cuiz_user:password@dpg-xxx.render.internal:5432/cuiz_prod
    ```

---

## Step 3: Create Web Service on Render

### Via Render Dashboard

1. Click **New +** → **Web Service**
2. Connect your GitHub repository:
    - Click **Connect Your Repository**
    - Authorize Render to access GitHub
    - Select your `cuisinous` repository
3. Configure deployment:

    | Setting            | Value                        |
    | ------------------ | ---------------------------- |
    | **Name**           | `cuisinous-api`              |
    | **Root Directory** | Leave blank (or `/`)         |
    | **Environment**    | `Docker`                     |
    | **Region**         | Same as database             |
    | **Branch**         | `main` (or your main branch) |
    | **Dockerfile**     | `Dockerfile.render`          |
    | **Plan**           | Free/Paid (depends on needs) |

4. Click **Advanced** to set environment variables (see Step 4)

---

## Step 4: Set Environment Variables

In Render dashboard, scroll to **Environment** section and add:

### Database

```
DATABASE_URL=postgresql://cuiz_user:PASSWORD@dpg-xxx.render.internal:5432/cuiz_prod
DB_HOST=dpg-xxx.render.internal
DB_PORT=5432
DB_NAME=cuiz_prod
DB_USER=cuiz_user
DB_PASSWORD=password
```

### App

```
APP_ENV=prod
APP_SECRET=your-secret-key-here (32 character random string)
APP_DEBUG=0
```

### JWT

```
JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
JWT_PASSPHRASE=your-passphrase
```

### Stripe (Live Keys)

```
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLIC_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_live_...
```

### Stripe URLs

```
STRIPE_ONBOARDING_RETURN_URL=https://dashboard.cuisinous.ca/seller/stripe/return
STRIPE_ONBOARDING_REFRESH_URL=https://dashboard.cuisinous.ca/seller/stripe/refresh
```

### Email

```
MAILER_FROM=noreply@cuisinous.ca
MAILER_DSN=smtp+sendgrid://...  (or your email service)
```

### Other

```
FRONTEND_PASSWORD_RESET_URL=https://app.cuisinous.ca/reset-password
FRONTEND_EMAIL_CONFIRMATION_URL=https://app.cuisinous.ca/confirm-email

DEFAULT_ADMIN_EMAIL=admin@cuisinous.ca
DEFAULT_ADMIN_PASSWORD=SecurePassword123!
DEFAULT_ADMIN_LOCALE=en
```

---

## Step 5: Configure Stripe Webhook for Production

After your Render service is deployed:

1. Get your Render app's public URL:
    - Render Dashboard → Your Service → Copy URL
    - Example: `https://cuisinous-api-xyz.onrender.com`

2. In Stripe Dashboard:
    - Go to **Developers** → **Webhooks**
    - Add/Update endpoint:
        ```
        https://cuisinous-api-xyz.onrender.com/api/webhook/stripe
        ```
    - Select production webhook events (same as dev)
    - Copy the **Signing Secret** → Update `STRIPE_WEBHOOK_SECRET`

---

## Step 6: Deploy

### Option A: Automatic Deployment

Once configured, Render auto-deploys on each push:

```bash
git push origin main
# → Render automatically builds and deploys
```

### Option B: Manual Deployment

In Render Dashboard:

1. Go to Your Service
2. Click **Manual Deploy** → **Deploy latest commit**

### Deployment Progress

Watch the logs in real-time:

1. Render Dashboard → Your Service → **Logs**
2. You'll see:
    ```
    Building Docker image...
    Installing dependencies...
    Running migrations...
    Creating default admin...
    Starting PHP-FPM...
    Starting Nginx...
    Service started successfully
    ```

---

## Dockerfile.render Explained

### Why Different Dockerfile for Render?

| Aspect             | Local                          | Render                       |
| ------------------ | ------------------------------ | ---------------------------- |
| **Architecture**   | Multi-service (docker-compose) | Single container             |
| **Port**           | 80                             | 10000                        |
| **PHP Connection** | `app:9000` (service name)      | `127.0.0.1:9000` (localhost) |
| **Services**       | Separate (nginx, php-fpm, db)  | Combined (nginx + php-fpm)   |

### Multi-Stage Build

The `Dockerfile.render` uses two stages:

```dockerfile
# Stage 1: Build dependencies
FROM php:8.2-fpm-alpine AS php
  ↓
  - Installs PHP extensions
  - Installs Composer
  - Runs: composer install

# Stage 2: Runtime (smaller image)
FROM php:8.2-fpm-alpine
  ↓
  - Copies only what's needed from Stage 1
  - Installs minimal runtime deps
  - Sets up Nginx + Supervisor
  - Exposes port 10000
```

**Why?** Smaller final image = faster deploys

### Key Differences in Dockerfile.render

```dockerfile
# 1. Port is 10000 (Render requirement)
EXPOSE 10000

# 2. Uses nginx.render.conf (not nginx.conf)
COPY docker/nginx.render.conf /etc/nginx/http.d/default.conf

# 3. Supervisor runs both PHP-FPM and Nginx in one container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
```

---

## nginx.render.conf Explained

### Why Different Nginx Config?

**Local Development (nginx.conf):**

```nginx
fastcgi_pass app:9000;
# Uses Docker service name because docker-compose provides DNS
```

**Render Production (nginx.render.conf):**

```nginx
fastcgi_pass 127.0.0.1:9000;
# Uses localhost because both Nginx + PHP-FPM run in same container
```

### Port Configuration

```nginx
listen 10000;  # Render exposes port 10000 (cannot change)
```

---

## Post-Deployment Checklist

After deployment completes:

### ✅ Basic Connectivity

```bash
# Visit your app URL
https://your-app.onrender.com

# Should see:
- API base endpoint responds
- No 502/503 errors
```

### ✅ Database Connection

```bash
# Check logs for migration success
Render Dashboard → Logs → Search "migrations"
# Should see: "Migrations executed successfully"
```

### ✅ Admin User

```bash
# Verify default admin was created
# Check logs for: "Creating default admin user..."
```

### ✅ Stripe Webhook

```bash
# Test webhook delivery
Stripe Dashboard → Developers → Webhooks → Your endpoint
# Should show recent successful deliveries (2xx status)
```

### ✅ Logs Are Flowing

```bash
Render Dashboard → Your Service → Logs
# Should see real-time application logs
```

---

## Common Issues & Solutions

### Issue: Deployment Fails During Build

```
Error: Docker build failed

Solution:
1. Check Render logs for specific error
2. Common causes:
   - Missing environment variables
   - Composer install failed (check composer.lock)
   - PHP extension not installed
3. Fix locally, commit, and deploy again
```

### Issue: 502 Bad Gateway

```
App starts but shows 502 error

Solutions to try:
1. Check if PHP-FPM crashed:
   - Render Logs → Search "php-fpm"
   - Look for errors like "out of memory"

2. Check if Nginx crashed:
   - Logs → Search "nginx"

3. Check database connection:
   - Verify DATABASE_URL is correct
   - Test connection manually if possible

4. Restart service:
   - Render Dashboard → Service → Restart
```

### Issue: Migrations Failed

```
Error: doctrine:migrations:migrate failed

Solutions:
1. Check migration file syntax
2. Verify database permissions
3. Try manual migration in SSH terminal
4. Review entrypoint script in docker/entrypoint
```

### Issue: Webhook Not Received

```
Stripe webhooks not triggering order updates

Check:
1. Stripe Dashboard → Webhooks → Event deliveries
   - Are requests being sent? (check HTTP status)
   - If 404: wrong endpoint URL
   - If 500: application error (check logs)

2. Render Logs → Search "webhook"
   - Look for signature verification errors
   - Check if handler is running

3. Fix:
   - Update STRIPE_WEBHOOK_SECRET if wrong
   - Verify endpoint URL is exactly: https://your-app/api/webhook/stripe
   - Resend failed events from Stripe dashboard
```

### Issue: Logs Show Memory Error

```
Error: Allowed memory exceeded

Solutions:
1. Increase plan on Render
2. Optimize queries (add database indexes)
3. Clear old cache/logs
4. Consider moving async jobs to background
```

---

## Monitoring & Health Checks

### Render Health Checks

Render pings your app every 30 seconds:

- **Healthy**: Response is 2xx
- **Unhealthy**: Response is 5xx → Service will restart

Your app should respond quickly, so ensure:

- Database is connected
- Cache is working
- No slow queries on health endpoint

### View Logs

```
Render Dashboard → Your Service → Logs Tab

Types of logs:
- Build logs (Docker build process)
- Deploy logs (Entrypoint script execution)
- Runtime logs (Application running)
```

### Monitor Metrics

```
Render Dashboard → Your Service → Metrics Tab

Key metrics:
- CPU usage
- Memory usage
- Request count
- Error rate
- Response time
```

---

## Scaling

### As Traffic Grows

**Free tier limitations:**

- Spins down after 15 minutes of inactivity
- Limited CPU/Memory

**Upgrade when:**

- Response times are slow
- Frequent 502 errors
- CPU/Memory consistently high

**Steps to upgrade:**

1. Render Dashboard → Your Service → Plan
2. Choose paid plan (Standard, Pro, etc.)
3. Incremental scaling (no downtime)

---

## Database Management

### Backup

Render automatically backs up PostgreSQL:

- Daily backups (kept 21 days)
- Access via Render Dashboard → Database → Backups

### Access Database Remotely

Use a database client (DBeaver, pgAdmin):

```
Connection Details (from Render):
Host: dpg-xxx.render.internal (or external connection string)
Port: 5432
Database: cuiz_prod
User: cuiz_user
Password: (from dashboard)
```

### Run Database Commands

```bash
# Via Render CLI (if installed)
render connection --database your-db-id

# Or via psql:
psql postgresql://user:pass@host:5432/database
```

---

## Redeployment

### When to Redeploy

- New code pushed to GitHub (automatic)
- Environment variables changed (manual or auto)
- Dependencies updated in composer.json (automatic)

### Manual Redeploy

```
Render Dashboard → Your Service
→ Manual Deploy → Deploy latest commit
```

### Zero-Downtime Redeployment

1. Render keeps old container running
2. New container builds in parallel
3. Health checks pass on new container
4. Traffic switches to new container
5. Old container shuts down

---

## Troubleshooting Checklist

Before contacting support:

- [ ] Check Render service logs
- [ ] Verify all environment variables are set
- [ ] Confirm DATABASE_URL is accessible
- [ ] Test Stripe webhook endpoint
- [ ] Check app locally with `docker-compose`
- [ ] Review recent code changes
- [ ] Try manual restart of service
- [ ] Clear cache (if accessible via SSH)

---

## Useful Render Commands

### Via Render Dashboard

| Task            | Steps                 |
| --------------- | --------------------- |
| View Logs       | Service → Logs        |
| Restart         | Service → Restart     |
| Check Status    | Service → Status page |
| Update Env Vars | Service → Environment |
| View Metrics    | Service → Metrics     |

---

## SSL/HTTPS

Render automatically:

- ✅ Generates SSL certificate
- ✅ Handles HTTPS traffic
- ✅ Redirects HTTP → HTTPS
- ✅ Certificate auto-renews

**Custom Domain:**

1. Render Dashboard → Custom Domain
2. Point your DNS to Render's CNAME
3. Render generates certificate for custom domain

---

## Useful Resources

- **Render Documentation**: https://render.com/docs
- **Render CLI**: https://render.com/docs/render-cli
- **Docker Documentation**: https://docs.docker.com
- **Symfony Deployment**: https://symfony.com/doc/current/deployment.html

---

## Support

### Render Support

- https://support.render.com
- Dashboard → Help

### Company Issues

- Check logs in Render Dashboard first
- Then contact development team

---

## Deployment Workflow Summary

```
1. Code is ready in GitHub
         ↓
2. Push to main branch
         ↓
3. Render detects push
         ↓
4. Builds Docker image using Dockerfile.render
         ↓
5. Runs entrypoint script:
   - Installs dependencies
   - Generates JWT keys
   - Runs migrations
   - Creates default admin
         ↓
6. Starts PHP-FPM + Nginx (via Supervisor)
         ↓
7. Configures Nginx using nginx.render.conf
         ↓
8. Health checks pass
         ↓
9. Service goes live at your-app.onrender.com
         ↓
Done! 🎉
```

---

**Last Updated:** 2026-02-24  
**Environment:** Render (render.com)  
**Platform:** Docker + PostgreSQL
