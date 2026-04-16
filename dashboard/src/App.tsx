import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import { useState, useEffect } from "react";
import OfflineBanner from "./components/OfflineBanner";

import LoginPage from "./pages/Login/LoginPage";
import NotFoundPage from "./pages/NotFound/NotFoundPage";
import { useAuth } from "./contexts/AuthContext";
import "./App.css";
import DashboardLayout from "./layouts/DashboardLayout";
import HomePage from "./pages/Home/HomePage";
import ProfilePage from "./pages/Profile/ProfilePage";
import SettingsPage from "./pages/Settings/SettingsPage";
import ProtectedRoute from "./routes/ProtectedRoute";
import VendorHomePage from "./pages/VendorHome/VendorHomePage";
import Users from "./pages/Users/Users";
import OrdersPage from "./pages/Orders/OrdersPage";
import MenuPage from "./pages/Menu/MenuPage";
import WalletPage from "./pages/Wallet/WalletPage";
import PrivacyLegal from "./pages/Privacy-legal/Privacy-legal";
import Security from "./pages/Security/Security";
import DishDetail from "./pages/Menu/DishDetail";
import StoreVerificationPage from "./pages/StoreVerificationPage";
import VerificationRequestsPage from "./pages/Admin/VerificationRequestsPage";
import CreateStore from "./components/CreateStore";
import { GoogleOAuthProvider } from "@react-oauth/google";
import { GOOGLE_CLIENT_ID } from "./config/apiConfig";
import AdminOrdersPage from "./pages/Admin/OrdersPage";
import CategoriesPage from "./pages/Admin/CategoriesPage";
import AdminWallet from "./pages/Admin/AdminWallet/AdminWallet";
import ResetPassword from "./pages/ResetPassword/ResetPassword";
import SellerStatistics from "./pages/Statistiques/Statistiques";
import AdminStatistics from "./pages/Statistiques/AdminStatistics";
import SellerRating from "./pages/Ratings/SellerRating";
import SellerPayout from "./pages/SellerPayout";
import AdminRatings from "./pages/Ratings/AdminRating";
import UserDetails from "./pages/Users/UserDetails";

import StripeReturnUrl from "./pages/StripeReturnUrl";
import StripeRefreshUrl from "./pages/StripeRefreshUrl";
import AdminStoresPage from "./pages/Admin/AdminStoresPage";
import AdminStoreDetailPage from "./pages/Admin/AdminStoreDetailPage";
import FoodStoreDishes from "./pages/Admin/FoodStoreDishes";
import CreateAdmin from "./pages/Admin/CreateAdmin";

function App() {
  const { user, type } = useAuth(); // Get user from AuthContext
  const DashboardSelector = () => {
    if (type === "admin") {
      return <HomePage />;
    } else {
      return <VendorHomePage />;
    }
  };

  const routeConfigs = [
    {
      path: "/",
      element: <DashboardSelector />,
      roles: ["admin", "seller"],
    },
    {
      path: "/admin-wallet",
      element: <AdminWallet />,
      roles: ["admin"],
    },
    {
      path: "/admin-food-stores",
      element: <AdminStoresPage />,
      roles: ["admin"],
    },
    {
      path: "/admin-food-stores/:id",
      element: <AdminStoreDetailPage />,
      roles: ["admin"],
    },
    {
      path: "/admin-food-stores/:id/dishes",
      element: <FoodStoreDishes />,
      roles: ["admin"],
    },
    {
      path: "/admin-ratings",
      element: <AdminRatings />,
      roles: ["admin"],
    },
    {
      path: "/admin-statistics",
      element: <AdminStatistics />,
      roles: ["admin"],
    },
    {
      path: "/admin-orders",
      element: <AdminOrdersPage />,
      roles: ["admin"],
    },
    {
      path: "/admin-category",
      element: <CategoriesPage />,
      roles: ["admin"],
    },
    {
      path: "/admin/create-admin",
      element: <CreateAdmin />,
      roles: ["admin"],
    },
    {
      path: "/users",
      element: <Users />,
      roles: ["admin", "seller"],
    },

    {
      path: "/users/:id",
      element: <UserDetails />,
      roles: ["admin"],
    },
    {
      path: "/verification-requests",
      element: <VerificationRequestsPage />,
      roles: ["admin"],
    },

    // SELLER ROUTES
    {
      path: "/seller-payout",
      element: <SellerPayout />,
      roles: ["seller"],
    },
    {
      path: "/stripe-return",
      element: <StripeReturnUrl />,
      roles: ["seller"],
    },
    {
      path: "/stripe-refresh",
      element: <StripeRefreshUrl />,
      roles: ["seller"],
    },
    {
      path: "/seller-ratings",
      element: <SellerRating />,
      roles: ["seller"],
    },
    {
      path: "/requests",
      element: <StoreVerificationPage />,
      roles: ["seller"],
    },
    {
      path: "/dishes/:id",
      element: <DishDetail />,
      roles: ["seller"],
    },

    {
      path: "/dishes",
      element: <MenuPage />,
      roles: ["seller"],
    },

    {
      path: "/create-store",
      element: <CreateStore />,
      roles: ["seller"],
    },

    // COMMON ROUTES
    {
      path: "/orders",
      element: <OrdersPage />,
      roles: ["admin", "seller"],
    },
    {
      path: "/profile",
      element: <ProfilePage />,
      roles: ["admin", "seller"],
    },
    {
      path: "/settings",
      element: <SettingsPage />,
      roles: ["admin", "seller"],
    },
    {
      path: "/statistiques",
      element: <SellerStatistics />,
      roles: ["admin", "seller"],
    },
    {
      path: "/wallet",
      element: <WalletPage />,
      roles: ["seller"],
    },
    {
      path: "/privacy-legal",
      element: <PrivacyLegal />,
      roles: ["admin", "seller"],
    },
    {
      path: "/security",
      element: <Security />,
      roles: ["admin", "seller"],
    },
  ];

  const [serverError, setServerError] = useState<string | null>(null);

  useEffect(() => {
    const handleServerError = (e: Event) => {
      const status = (e as CustomEvent).detail?.status ?? 500;
      setServerError(`Erreur serveur (${status}) — Veuillez réessayer.`);
      setTimeout(() => setServerError(null), 4000);
    };
    window.addEventListener('api:server-error', handleServerError);
    return () => window.removeEventListener('api:server-error', handleServerError);
  }, []);

  return (
    <>
      <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
        <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
          <OfflineBanner />
          {/* Server-error toast */}
          {serverError && (
            <div className="fixed bottom-4 right-4 z-50 bg-red-600 text-white text-sm font-medium px-4 py-3 rounded-lg shadow-lg max-w-xs">
              {serverError}
            </div>
          )}
          <Routes>
            {/* Routes available regardless of auth status */}
            <Route path="/reset-password" element={<ResetPassword />} />


            {user ? (
              <Route
                path="/*"
                element={
                  <DashboardLayout>
                    <Routes>
                      {routeConfigs.map((route, index) => (
                        <Route
                          key={index}
                          path={route.path}
                          element={
                            <ProtectedRoute allowedRoles={route.roles || []}>
                              {route.element}
                            </ProtectedRoute>
                          }
                        />
                      ))}
                      <Route path="*" element={<NotFoundPage />} />
                    </Routes>
                  </DashboardLayout>
                }
              />
            ) : (
              <>
                <Route path="/" element={<LoginPage />} />
                <Route path="*" element={<NotFoundPage />} />
              </>
            )}
          </Routes>
        </Router>
      </GoogleOAuthProvider>{" "}
    </>
  );
}

export default App;