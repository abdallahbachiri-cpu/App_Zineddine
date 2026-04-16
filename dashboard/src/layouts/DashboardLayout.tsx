import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import TopBar from "../components/Layout/TopBar";
import cuisinoLogo from "../assets/cuisinous-logo.svg";
import collapsedLogo from "../assets/collapsed-logo.svg";
import { useTranslation } from "react-i18next";

import {
    HomeIcon,
    WalletIcon,
    ArrowRightOnRectangleIcon,
    XMarkIcon,
    Squares2X2Icon,
    ShoppingBagIcon,
    StarIcon,
    UserCircleIcon,
    ChartBarIcon,
    PlusIcon
} from "@heroicons/react/24/outline";

const isNavigationActive = (currentPath: string, itemHref: string): boolean => {
    const startWithPaths = [
        "/admin",
        "/seller",
        "/create-store",
        "/dishes",
        "/wallet",
        "/statistiques"
    ];

    if (startWithPaths.includes(itemHref)) {
        return currentPath.startsWith(itemHref);
    }

    return currentPath === itemHref;
};



const DashboardLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [isLogoHovered, setIsLogoHovered] = useState(false);
    const { logout } = useAuth();
    const location = useLocation();
    const navigate = useNavigate();
    const { t } = useTranslation();
    const user = localStorage.getItem("user")
        ? JSON.parse(localStorage.getItem("user") || "{}")
        : null;

    const adminNavigation = [
        { name: t("sidebar.admin.dashboard"), href: "/", icon: HomeIcon },
        { name: t("sidebar.admin.foodStores"), href: "/admin-food-stores", icon: PlusIcon },
        { name: t("sidebar.admin.ratings"), href: "/admin-ratings", icon: StarIcon },
        { name: t("sidebar.admin.profile"), href: "/profile", icon: UserCircleIcon },
        { name: t("sidebar.admin.orders"), href: "/admin-orders", icon: ShoppingBagIcon },
        { name: t("sidebar.admin.category"), href: "/admin-category", icon: Squares2X2Icon },
        { name: t("sidebar.admin.wallet"), href: "/admin-wallet", icon: WalletIcon },
        { name: t("sidebar.admin.statistics"), href: "/admin-statistics", icon: ChartBarIcon },
        { name: t("sidebar.admin.createAdmin"), href: "/admin-create-admin", icon: UserCircleIcon },

    ];

    const sellerNavigation = [
        { name: t("sidebar.seller.dashboard"), href: "/", icon: HomeIcon },
        { name: t("sidebar.seller.ratings"), href: "/seller-ratings", icon: StarIcon },
        { name: t("sidebar.seller.stores"), href: "/create-store", icon: HomeIcon },
        { name: t("sidebar.seller.profile"), href: "/profile", icon: UserCircleIcon },
        { name: t("sidebar.seller.orders"), href: "/orders", icon: ShoppingBagIcon },
        { name: t("sidebar.seller.recipes"), href: "/dishes", icon: Squares2X2Icon },
        { name: t("sidebar.seller.wallet"), href: "/wallet", icon: WalletIcon },
        { name: t("sidebar.admin.statistics"), href: "/statistiques", icon: ChartBarIcon },
    ];

    const navigation = user?.type === "admin" ? adminNavigation : sellerNavigation;

    const handleLogout = () => {
        logout();
        navigate("/");
    };

    const toggleMobileSidebar = () => {
        setSidebarOpen(!sidebarOpen);
    };

    return (
        <div className="h-screen flex overflow-hidden bg-white">
            {/* Sidebar mobile */}
            <div
                className={`fixed inset-0 flex z-40 md:hidden ${sidebarOpen ? "" : "hidden"
                    }`}
            >
                <div
                    className="fixed inset-0 bg-black/50 backdrop-blur-sm"
                    onClick={() => setSidebarOpen(false)}
                />

                <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white border-r border-gray-100">
                    <div className="absolute top-0 right-0 -mr-12 pt-2">
                        <button
                            className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                            onClick={() => setSidebarOpen(false)}
                        >
                            <XMarkIcon className="h-6 w-6 text-white" />
                        </button>
                    </div>

                    <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
                        <div className="flex-shrink-0 flex items-center px-6 mb-8">
                            <div className="flex items-center space-x-3">
                                <img
                                    src={cuisinoLogo}
                                    alt="Logo"
                                    className=" transition-all duration-300"
                                />
                            </div>
                        </div>
                        <nav className="px-4 space-y-1">
                            {navigation.map((item) => {
                                const isActive = isNavigationActive(location.pathname, item.href);
                                return (
                                    <Link
                                        key={item.name}
                                        to={item.href}
                                        className={`${isActive
                                                ? "bg-gray-900 text-white"
                                                : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                                            } group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors`}
                                        onClick={() => setSidebarOpen(false)}
                                    >
                                        <item.icon className="mr-3 h-5 w-5" />
                                        {item.name}
                                    </Link>
                                );
                            })}
                        </nav>
                    </div>

                    <div className="flex-shrink-0 border-t border-gray-100 p-4">
                        <div className="flex items-center">
                            <div className="flex-shrink-0">
                                <div className="h-8 w-8 rounded-lg bg-gray-900 flex items-center justify-center">
                                    <span className="text-xs font-bold text-white">
                                        {user?.firstName?.[0]}
                                        {user?.lastName?.[0]}
                                    </span>
                                </div>
                            </div>
                            <div className="ml-3">
                                <p className="text-sm font-medium text-gray-700">
                                    {user?.firstName} {user?.lastName}
                                </p>
                                <button
                                    onClick={handleLogout}
                                    className="text-xs text-gray-500 hover:text-gray-700 transition-colors"
                                >
                                    {t("sidebar.actions.logout")}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Sidebar desktop */}
            <div className="hidden md:flex md:flex-shrink-0">
                <div
                    className="flex flex-col w-16 hover:w-64 transition-all duration-300 group"
                    onMouseEnter={() => setIsLogoHovered(true)}
                    onMouseLeave={() => setIsLogoHovered(false)}
                >
                    <div className="flex flex-col h-0 flex-1 bg-white border-r border-gray-100">
                        <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
                            <div className="flex items-center flex-shrink-0 px-4 mb-8">
                                <img
                                    src={isLogoHovered ? cuisinoLogo : collapsedLogo}
                                    alt="Logo"
                                    className="transition-all duration-300"
                                />
                            </div>
                            <nav className="flex-1 px-2 space-y-1">
                                {navigation.map((item) => {
                                    const isActive = isNavigationActive(location.pathname, item.href);
                                    return (
                                        <Link
                                            key={item.name}
                                            to={item.href}
                                            className={`${isActive
                                                    ? "bg-gray-900 text-white"
                                                    : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                                                } group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all relative`}
                                            title={item.name}
                                        >
                                            <item.icon className="h-5 w-5 flex-shrink-0" />
                                            <span className="ml-3 opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                                                {item.name}
                                            </span>

                                            {/* Tooltip for collapsed state */}
                                            <div className="absolute left-full ml-2 px-2 py-1 bg-gray-900 text-white text-xs rounded opacity-0 group-hover:opacity-0 pointer-events-none transition-opacity z-50 whitespace-nowrap">
                                                {item.name}
                                            </div>
                                        </Link>
                                    );
                                })}
                            </nav>
                        </div>

                        <div className="flex-shrink-0 border-t border-gray-100 p-4">
                            <div className="flex items-center">
                                <div className="flex-shrink-0">
                                    <div className="h-8 w-8 rounded-lg bg-gray-900 flex items-center justify-center">
                                        <span className="text-xs font-bold text-white">
                                            {user?.firstName?.[0]}
                                            {user?.lastName?.[0]}
                                        </span>
                                    </div>
                                </div>
                                <div className="ml-3 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                    <p className="text-sm font-medium text-gray-700 whitespace-nowrap">
                                        {user?.firstName} {user?.lastName}
                                    </p>
                                    <button
                                        onClick={handleLogout}
                                        className="flex items-center text-xs text-gray-500 hover:text-gray-700 transition-colors whitespace-nowrap"
                                    >
                                        <ArrowRightOnRectangleIcon className="h-3 w-3 mr-1" />
                                        {t("sidebar.actions.logout")}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Main content */}
            <div className="flex flex-col w-0 flex-1 overflow-hidden">
                <TopBar toggleMobile={toggleMobileSidebar} />
                <main className="flex-1 relative z-0 overflow-y-auto focus:outline-none">
                    {children}
                </main>
            </div>
        </div>
    );
};

export default DashboardLayout;
