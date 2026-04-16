# Cuisinous — Quick Start

Short setup and deployment notes for developers and clients.

**Requirements**

- PHP, Composer, a database (Postgres), and a web server or Symfony CLI.

**Quick setup**

1. Install dependencies:

    composer install

2. Configure environment variables (use `.env.local` or your platform's secret manager):
    - `DATABASE_URL` (or `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`)
    - `MAILER_DSN` — mailer DSN used by Symfony (required for email flows)
    - `MAILER_FROM` — default sender email
    - `STRIPE_SECRET_KEY` — Stripe secret key
    - `STRIPE_PUBLIC_KEY` — Stripe publishable key
    - `STRIPE_WEBHOOK_SECRET` — webhook signing secret (set after creating webhook)
    - `STRIPE_ONBOARDING_RETURN_URL`, `STRIPE_ONBOARDING_REFRESH_URL`
    - `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PROXY_SERVICE_SID`
    - `DEFAULT_ADMIN_EMAIL`, `DEFAULT_ADMIN_PASSWORD`, `DEFAULT_ADMIN_LOCALE`

    See `.env.example` and `.env` for sample values. Keep secrets out of version control.

3. Run database migrations:

    php bin/console doctrine:migrations:migrate

4. Run locally (dev):

    symfony server:start

**Payments & SMS**

- Stripe is used for payments and onboarding. Provide `STRIPE_SECRET_KEY`, `STRIPE_PUBLIC_KEY`, and `STRIPE_WEBHOOK_SECRET`.
- Twilio Proxy is used for phone proxying — set the Twilio variables above.

**Media storage**

- Upload directory: configured as `upload_directory: "%kernel.project_dir%/mnt/data/uploads"`. Under that root there are `public/` and `secure/` directories (for example `%kernel.project_dir%/mnt/data/uploads/public` and `%kernel.project_dir%/mnt/data/uploads/secure`).
- Public media route: served via the Media controller at [src/Controller/MediaController.php](src/Controller/MediaController.php) on `/api/media/{id}`.

**Deployment & persistence**

- Render (PaaS): Render's default filesystem is ephemeral across deploys. Use a Render Persistent Disk to persist uploads between deploys (current setup expects persistent disk on Render).
- Alternative: update the media service to store files in external object storage (Amazon S3, DigitalOcean Spaces, Google Cloud Storage) for multi-instance deployments.
- If using a VPS/dedicated server with persistent disk, local files will persist between deploys and no external storage is required.

**Checklist (critical)**

- Set `DEFAULT_ADMIN_EMAIL` and `DEFAULT_ADMIN_PASSWORD` before the first deploy so the initial admin account can be created.
- Configure `MAILER_DSN` and `MAILER_FROM` for verification, password reset and transactional emails.
- After deploying, create the Stripe webhook endpoint and update `STRIPE_WEBHOOK_SECRET` in your environment.
