# CUISINOUS — Architecture

## Repository Structure

```
CUISINOUS/
├── README.md
├── ARCHITECTURE.md
│
├── dashboard/                          # React admin & vendor dashboard
│   └── src/
│       ├── pages/
│       │   ├── Home/HomePage.tsx           # Seller/vendor home
│       │   ├── Login/LoginPage.tsx
│       │   ├── Orders/OrdersPage.tsx
│       │   ├── Menu/
│       │   │   ├── MenuPage.tsx            # Dish list
│       │   │   └── DishDetail.tsx
│       │   ├── Wallet/WalletPage.tsx
│       │   ├── Profile/ProfilePage.tsx
│       │   ├── Settings/SettingsPage.tsx
│       │   ├── VendorHome/VendorHomePage.tsx
│       │   ├── Admin/
│       │   │   ├── AdminStoresPage.tsx
│       │   │   ├── AdminStoreDetailPage.tsx
│       │   │   └── CategoriesPage.tsx
│       │   ├── NotFound/NotFoundPage.tsx
│       │   └── UnauthorizedPage.tsx
│       ├── services/
│       │   ├── httpClient.ts           # Axios wrapper with JWT refresh
│       │   ├── authService.ts          # Login, logout, token management
│       │   ├── menuService.ts          # Dish CRUD
│       │   ├── orderService.ts         # Order management
│       │   ├── adminStoreService.ts    # Admin food store operations
│       │   └── analyticsService.ts     # Seller & admin statistics
│       └── types/
│           ├── menu.ts                 # Dish, Ingredient, Allergen
│           ├── order.ts                # Order, AdminOrder
│           └── wallet.ts               # WalletDTO, FoodStoreOption
│
├── mobile/                             # Flutter app (buyer + vendor)
│   └── lib/
│       ├── main.dart
│       ├── app_router.dart             # All named routes
│       ├── screens/
│       │   ├── home_screen.dart            # Buyer home
│       │   ├── store_detail_screen.dart    # Food store detail
│       │   ├── store_map_screen.dart
│       │   ├── menu_item_detail_screen.dart
│       │   ├── menu_item_form_screen.dart
│       │   ├── menu_management_screen.dart
│       │   ├── menu_item_reviews_screen.dart
│       │   ├── manage_menu_ingredients_screen.dart
│       │   ├── vendor_home_screen.dart
│       │   ├── vendor_orders_screen.dart
│       │   ├── vendor_analytics_screen.dart
│       │   ├── vendor_wallet_screen.dart
│       │   ├── vendor_store_form_screen.dart
│       │   └── vendor_notifications_screen.dart
│       ├── providers/
│       │   ├── vendor_order_provider.dart
│       │   ├── vendor_rating_provider.dart
│       │   └── vendor_allergen_provider.dart
│       ├── services/
│       └── widgets/
│
└── backend/                            # Symfony REST API
    └── src/
        └── Controller/
            ├── Abstract/BaseController.php
            ├── Auth/
            │   └── AuthController.php          # /api/auth/*
            ├── User/
            │   └── UserController.php          # /api/user/*
            ├── Admin/
            │   ├── AdminController.php         # /api/admin/*
            │   └── MercureController.php       # Mercure SSE
            ├── Store/
            │   ├── FoodStoreController.php     # /api/seller/food-store (CRUD + verification)
            │   ├── DishController.php          # /api/seller/food-store/dishes
            │   ├── IngredientController.php    # /api/seller/food-store/ingredients
            │   ├── CategoryController.php      # /api/seller/category-types & allergens
            │   └── AnalyticsController.php     # /api/seller/stats
            ├── Order/
            │   ├── OrderController.php         # /api/seller/food-store/orders
            │   ├── BuyerOrderController.php    # /api/buyer/orders
            │   └── CartController.php          # /api/buyer/cart
            ├── Payment/
            │   ├── StripeController.php        # Stripe setup
            │   ├── WalletController.php        # /api/seller/food-store/wallet
            │   └── Webhook/
            │       └── StripeWebhookController.php
            ├── Api/
            │   └── V2/
            │       ├── AuthController.php
            │       ├── SellerController.php
            │       ├── SellerFoodStoreOrderController.php
            │       └── UserController.php
            │
            │   # Legacy monolithic controllers (kept for reference/backward compat):
            ├── SellerController.php    # ~6800 lines — source for Store/, Order/, Payment/
            └── BuyerController.php     # ~3600 lines — source for Order/Cart*, BuyerOrder*
```

## Namespace Map

| Directory | PHP Namespace |
|-----------|--------------|
| `Controller/Auth/` | `App\Controller\Auth` |
| `Controller/User/` | `App\Controller\User` |
| `Controller/Admin/` | `App\Controller\Admin` |
| `Controller/Store/` | `App\Controller\Store` |
| `Controller/Order/` | `App\Controller\Order` |
| `Controller/Payment/` | `App\Controller\Payment` |
| `Controller/Payment/Webhook/` | `App\Controller\Payment\Webhook` |
| `Controller/Api/V2/` | `App\Controller\Api\V2` |

## Data Flow

```
Mobile App / Dashboard
       │
       ▼ HTTPS + JWT
  Symfony API (/api/*)
       │
       ├── Doctrine ORM ──► PostgreSQL
       ├── Stripe SDK ─────► Stripe API
       ├── Mercure Hub ────► SSE (real-time)
       └── Twilio SDK ─────► Proxy numbers
```

## Authentication Flow

1. `POST /api/auth/login` — returns `accessToken` (JWT, 1h) + `refreshToken` (7 or 30 days)
2. All protected routes require `Authorization: Bearer <accessToken>`
3. `POST /api/auth/refresh` — exchanges refreshToken for new accessToken
4. Google OAuth and Apple Sign-In also supported via `/api/auth/login` with `googleToken`/`appleToken`
