import { BrowserRouter as Router, Route, Routes, Navigate } from "react-router-dom";
import { useState, useEffect } from "react";
import OfflineBanner from "./components/OfflineBanner";
import { useAuth } from "./contexts/AuthContext";
import "./App.css";

import LoginPage from "./pages/Login/LoginPage";
import NotFoundPage from "./pages/NotFound/NotFoundPage";
import ResetPassword from "./pages/ResetPassword/ResetPassword";
import RegisterPage from "./pages/Register/RegisterPage";

import DashboardLayout from "./layouts/DashboardLayout";
import ProtectedRoute from "./routes/ProtectedRoute";
import VendorContractGuard from "./components/VendorContractGuard";

import HomePage from "./pages/Home/HomePage";
import ProfilePage from "./pages/Profile/ProfilePage";
import SettingsPage from "./pages/Settings/SettingsPage";
import VendorHomePage from "./pages/VendorHome/VendorHomePage";
import Users from "./pages/Users/Users";
import UserDetails from "./pages/Users/UserDetails";
import OrdersPage from "./pages/Orders/OrdersPage";
import MenuPage from "./pages/Menu/MenuPage";
import WalletPage from "./pages/Wallet/WalletPage";
import PrivacyLegal from "./pages/Privacy-legal/Privacy-legal";
import Security from "./pages/Security/Security";
import DishDetail from "./pages/Menu/DishDetail";
import StoreVerificationPage from "./pages/StoreVerificationPage";
import VerificationRequestsPage from "./pages/Admin/VerificationRequestsPage";
import CreateStore from "./components/CreateStore";
import AdminOrdersPage from "./pages/Admin/OrdersPage";
import CategoriesPage from "./pages/Admin/CategoriesPage";
import AdminWallet from "./pages/Admin/AdminWallet/AdminWallet";
import SellerStatistics from "./pages/Statistiques/Statistiques";
import AdminStatistics from "./pages/Statistiques/AdminStatistics";
import SellerRating from "./pages/Ratings/SellerRating";
import SellerPayout from "./pages/SellerPayout";
import AdminRatings from "./pages/Ratings/AdminRating";
import StripeReturnUrl from "./pages/StripeReturnUrl";
import StripeRefreshUrl from "./pages/StripeRefreshUrl";
import AdminStoresPage from "./pages/Admin/AdminStoresPage";
import AdminStoreDetailPage from "./pages/Admin/AdminStoreDetailPage";
import FoodStoreDishes from "./pages/Admin/FoodStoreDishes";
import CreateAdmin from "./pages/Admin/CreateAdmin";
import AdminBroadcastNotification from "./pages/Admin/AdminBroadcastNotification";

import { GoogleOAuthProvider } from "@react-oauth/google";
import { GOOGLE_CLIENT_ID } from "./config/apiConfig";

import SupportDashboard from "./pages/Support/SupportDashboard";
import ClientLayout from "./pages/Client/ClientLayout";
import ClientHomePage from "./pages/Client/ClientHomePage";
import ClientStorePage from "./pages/Client/ClientStorePage";
import ClientOrdersPage from "./pages/Client/ClientOrdersPage";
import ClientProfilePage from "./pages/Client/ClientProfilePage";
import ContactSupportPage from "./pages/Client/ContactSupportPage";
import VendorContractPage from "./pages/Vendor/VendorContractPage";
import CommissionPage from "./pages/Admin/CommissionPage";
import SupportPage from "./pages/Support/SupportPage";

// ── Inline DashboardLayout wrapper ────────────────────────────────────────────
const DL = ({ children }: { children: React.ReactNode }) => (
  <DashboardLayout>{children}</DashboardLayout>
);

// ── Route guards (type-based, no /unauthorized) ───────────────────────────────
const AdminRoute  = ({ el }: { el: JSX.Element }) => <ProtectedRoute allowedRoles={["admin"]}>{el}</ProtectedRoute>;
const SellerRoute = ({ el }: { el: JSX.Element }) => <ProtectedRoute allowedRoles={["seller"]}>{el}</ProtectedRoute>;
// CommonRoute kept for reference but replaced by FlexRoute for contract-guarded access
// const CommonRoute = ({ el }: { el: JSX.Element }) => <ProtectedRoute allowedRoles={["admin", "seller"]}>{el}</ProtectedRoute>;

// Seller + VendorContractGuard (requires signed contract)
const GuardedSellerRoute = ({ el }: { el: JSX.Element }) => (
  <ProtectedRoute allowedRoles={["seller"]}>
    <VendorContractGuard>{el}</VendorContractGuard>
  </ProtectedRoute>
);

// Admin or guarded seller — used for routes shared by both roles
const FlexRoute = ({ el, type }: { el: JSX.Element; type: string | null }) =>
  type === "admin"
    ? <AdminRoute el={el} />
    : <GuardedSellerRoute el={el} />;

function App() {
  const { user, type } = useAuth();

  const [serverError, setServerError] = useState<string | null>(null);
  useEffect(() => {
    const h = (e: Event) => {
      const status = (e as CustomEvent).detail?.status ?? 500;
      setServerError(`Erreur serveur (${status}) — Veuillez réessayer.`);
      setTimeout(() => setServerError(null), 4000);
    };
    window.addEventListener("api:server-error", h);
    return () => window.removeEventListener("api:server-error", h);
  }, []);

  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <OfflineBanner />
        {serverError && (
          <div className="fixed bottom-4 right-4 z-50 bg-red-600 text-white text-sm font-medium px-4 py-3 rounded-lg shadow-lg max-w-xs">
            {serverError}
          </div>
        )}

        <Routes>
          {/* ── Always public ──────────────────────────────────────────────── */}
          <Route path="/reset-password" element={<ResetPassword />} />
          <Route path="/register"       element={<RegisterPage />} />

          {!user ? (
            /* ── Unauthenticated ───────────────────────────────────────────── */
            <>
              <Route path="/"      element={<LoginPage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="*"      element={<LoginPage />} />
            </>
          ) : type === "buyer" ? (
            /* ── BUYER portal ──────────────────────────────────────────────── */
            <>
              <Route path="/client" element={<ClientLayout />}>
                <Route index              element={<ClientHomePage />} />
                <Route path="home"        element={<ClientHomePage />} />
                <Route path="store/:id"   element={<ClientStorePage />} />
                <Route path="orders"      element={<ClientOrdersPage />} />
                <Route path="profile"     element={<ClientProfilePage />} />
                <Route path="support"     element={<ContactSupportPage />} />
                <Route path="*"           element={<ClientHomePage />} />
              </Route>
              <Route path="*" element={<Navigate to="/client/home" replace />} />
            </>
          ) : type === "support" ? (
            /* ── SUPPORT ───────────────────────────────────────────────────── */
            <>
              <Route path="/support-dashboard" element={<SupportDashboard />} />
              <Route path="*" element={<Navigate to="/support-dashboard" replace />} />
            </>
          ) : (type === "admin" || type === "seller") ? (
            /* ── ADMIN / SELLER (DashboardLayout) ─────────────────────────── */
            <Route path="/*" element={
              <DL>
                <Routes>
                  {/* ── Dashboard home ─────────────────────────────────── */}
                  <Route path="/"    element={type === "admin"
                    ? <AdminRoute el={<HomePage />} />
                    : <GuardedSellerRoute el={<VendorHomePage />} />
                  } />

                  {/* ── Vendor contract (seller, NO guard — page itself) ─ */}
                  <Route path="/vendor/contract" element={<SellerRoute el={<VendorContractPage />} />} />

                  {/* ── Seller routes (require signed contract) ─────────── */}
                  <Route path="/dishes"         element={<GuardedSellerRoute el={<MenuPage />} />} />
                  <Route path="/dishes/:id"     element={<GuardedSellerRoute el={<DishDetail />} />} />
                  <Route path="/wallet"         element={<GuardedSellerRoute el={<WalletPage />} />} />
                  <Route path="/seller-ratings" element={<GuardedSellerRoute el={<SellerRating />} />} />
                  <Route path="/seller-payout"  element={<GuardedSellerRoute el={<SellerPayout />} />} />
                  <Route path="/stripe-return"  element={<GuardedSellerRoute el={<StripeReturnUrl />} />} />
                  <Route path="/stripe-refresh" element={<GuardedSellerRoute el={<StripeRefreshUrl />} />} />
                  <Route path="/requests"       element={<GuardedSellerRoute el={<StoreVerificationPage />} />} />
                  <Route path="/create-store"   element={<SellerRoute el={<CreateStore />} />} />

                  {/* ── Admin-only routes ────────────────────────────────── */}
                  <Route path="/admin-wallet"                 element={<AdminRoute el={<AdminWallet />} />} />
                  <Route path="/admin-food-stores"            element={<AdminRoute el={<AdminStoresPage />} />} />
                  <Route path="/admin-food-stores/:id"        element={<AdminRoute el={<AdminStoreDetailPage />} />} />
                  <Route path="/admin-food-stores/:id/dishes" element={<AdminRoute el={<FoodStoreDishes />} />} />
                  <Route path="/admin-ratings"                element={<AdminRoute el={<AdminRatings />} />} />
                  <Route path="/admin-statistics"             element={<AdminRoute el={<AdminStatistics />} />} />
                  <Route path="/admin-orders"                 element={<AdminRoute el={<AdminOrdersPage />} />} />
                  <Route path="/admin-category"               element={<AdminRoute el={<CategoriesPage />} />} />
                  <Route path="/admin-commissions"            element={<AdminRoute el={<CommissionPage />} />} />
                  <Route path="/admin/create-admin"           element={<AdminRoute el={<CreateAdmin />} />} />
                  <Route path="/verification-requests"        element={<AdminRoute el={<VerificationRequestsPage />} />} />
                  <Route path="/support-dashboard"            element={<AdminRoute el={<SupportDashboard />} />} />
                  <Route path="/users/:id"                    element={<AdminRoute el={<UserDetails />} />} />

                  {/* ── Common admin+seller (seller routes go through VendorContractGuard) ── */}
                  <Route path="/users"         element={<FlexRoute el={<Users />}           type={type} />} />
                  <Route path="/orders"        element={<FlexRoute el={<OrdersPage />}      type={type} />} />
                  <Route path="/profile"       element={<FlexRoute el={<ProfilePage />}     type={type} />} />
                  <Route path="/settings"      element={<FlexRoute el={<SettingsPage />}    type={type} />} />
                  <Route path="/statistiques"  element={<FlexRoute el={<SellerStatistics />} type={type} />} />
                  <Route path="/privacy-legal" element={<FlexRoute el={<PrivacyLegal />}    type={type} />} />
                  <Route path="/security"      element={<FlexRoute el={<Security />}        type={type} />} />
                  <Route path="/support"       element={<FlexRoute el={<SupportPage />}     type={type} />} />

                  <Route path="/login" element={<Navigate to="/" replace />} />
                  <Route path="*"      element={<NotFoundPage />} />
                </Routes>
              </DL>
            } />
          ) : (
            /* ── Unknown type ──────────────────────────────────────────────── */
            <Route path="*" element={<Navigate to="/login" replace />} />
          )}
        </Routes>
      </Router>
    </GoogleOAuthProvider>
  );
}

export default App;
