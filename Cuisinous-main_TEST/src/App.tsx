import { BrowserRouter as Router, Route, Routes } from "react-router-dom";

import Login from "./pages/Login/Login";
import NotFound from "./pages/NotFound/NotFound";
import { useAuth } from "./contexts/AuthContext";
import "./App.css";
import DashboardLayout from "./layouts/DashboardLayout";
import Dashboard from "./pages/Dashboard/Dashboard";
import Profile from "./pages/Profile/Profile";
import Settings from "./pages/Settings/Settings";
import ProtectedRoute from "./routes/ProtectedRoute";
import VendorDashboard from "./pages/VendorDashboard/VendorDashboard";
import Users from "./pages/Users/Users";
import Orders from "./pages/Orders/Orders";
import Dishes from "./pages/Dishes/Dishes";
import Wallet from "./pages/Wallet/Wallet";
import PrivacyLegal from "./pages/Privacy-legal/Privacy-legal";
import Security from "./pages/Security/Security";
import DishDetail from "./pages/Dishes/DishDetail";
import StoreVerificationPage from "./pages/StoreVerificationPage";
import VerificationRequestsPage from "./pages/Admin/VerificationRequestsPage";
import CreateStore from "./components/CreateStore";
import { GoogleOAuthProvider } from "@react-oauth/google";
import { GOOGLE_CLIENT_ID } from "./config/apiConfig";
import AdminOrdersPage from "./pages/Admin/OrdersPage";
import CategoryList from "./pages/Admin/CategoryList";
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
import AdminFoodStores from "./pages/Admin/AdminFoodStores";
import AdminFoodStoreDetail from "./pages/Admin/AdminFoodStoreDetail";
import FoodStoreDishes from "./pages/Admin/FoodStoreDishes";
import CreateAdmin from "./pages/Admin/CreateAdmin";

function App() {
  const { user, type } = useAuth(); // Get user from AuthContext
  const DashboardSelector = () => {
    if (type === "admin") {
      return <Dashboard />;
    } else {
      return <VendorDashboard />;
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
      element: <AdminFoodStores />,
      roles: ["admin"],
    },
    {
      path: "/admin-food-stores/:id",
      element: <AdminFoodStoreDetail />,
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
      element: <CategoryList />,
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
      element: <Dishes />,
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
      element: <Orders />,
      roles: ["admin", "seller"],
    },
    {
      path: "/profile",
      element: <Profile />,
      roles: ["admin", "seller"],
    },
    {
      path: "/settings",
      element: <Settings />,
      roles: ["admin", "seller"],
    },
    {
      path: "/statistiques",
      element: <SellerStatistics />,
      roles: ["admin", "seller"],
    },
    {
      path: "/wallet",
      element: <Wallet />,
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

  return (
    <>
      <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
        <Router>
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
                      <Route path="*" element={<NotFound />} />
                    </Routes>
                  </DashboardLayout>
                }
              />
            ) : (
              <>
                <Route path="/" element={<Login />} />
                <Route path="*" element={<NotFound />} />
              </>
            )}
          </Routes>
        </Router>
      </GoogleOAuthProvider>{" "}
    </>
  );
}

export default App;