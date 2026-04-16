# CUISINOUS

A food delivery platform connecting buyers, sellers (vendors), and administrators.

## Architecture

The project is split into three sub-projects:

| Folder | Role | Tech Stack |
|--------|------|-----------|
| `dashboard/` | Web admin & vendor dashboard | React 18, TypeScript, Vite |
| `mobile/` | Buyer & vendor mobile app | Flutter / Dart |
| `backend/` | REST API | Symfony 7, PHP 8.2, PostgreSQL |

> **Note:** The folders are currently named `Cuisinous-main_TEST` (dashboard), `cuisinous-app-main_TEST` (mobile), and `cuisinous-api-main_TEST` (backend). Rename them to `dashboard/`, `mobile/`, and `backend/` after cloning.

## Quick Start

### Backend (Symfony)
```bash
cd backend
composer install
cp .env .env.local   # fill in DATABASE_URL, JWT_SECRET, STRIPE_SECRET_KEY, etc.
php bin/console doctrine:migrations:migrate
symfony server:start
```

### Dashboard (React)
```bash
cd dashboard
npm install
npm run dev
```

### Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

## Tech Stack

### Backend
- **Symfony 7** — REST API framework
- **Doctrine ORM** — PostgreSQL database access
- **Lexik JWT** — Authentication (access + refresh tokens)
- **Stripe** — Payment processing
- **Mercure** — Real-time notifications (SSE)
- **Twilio** — Proxy phone numbers for order communication
- **NelmioApiDoc** — Swagger/OpenAPI documentation at `/api/doc`

### Dashboard
- **React 18** + **TypeScript**
- **Vite** — Build tool
- **Axios** — HTTP client (`services/httpClient.ts`)
- **React Router v6** — Client-side routing

### Mobile
- **Flutter** — Cross-platform iOS & Android
- **Provider** — State management
- **Google Maps** — Store location picker
- **Firebase** — Push notifications

## Roles

| Role | Access |
|------|--------|
| `ROLE_BUYER` | Browse stores, manage cart, place orders, rate dishes |
| `ROLE_SELLER` | Manage food store, menu, orders, wallet |
| `ROLE_ADMIN` | Manage all stores, users, categories, analytics |

## API

Base URL: `/api`

- Auth: `/api/auth/*`
- Buyer: `/api/buyer/*`
- Seller: `/api/seller/*`
- Admin: `/api/admin/*`
- V2: `/api/v2/*`

Full Swagger docs available at `/api/doc` when running locally.
