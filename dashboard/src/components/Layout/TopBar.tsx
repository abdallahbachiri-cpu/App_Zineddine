import LanguageSwitcher from '../LanguageSwitcher';
import NotificationCenter from '../NotificationCenter';
import { Link } from "react-router-dom";
import { useState, useRef, useEffect } from "react";
import { Bars3Icon } from "@heroicons/react/16/solid";
import { Avatar } from "antd";
import { UserOutlined } from "@ant-design/icons";

import settings from '../../assets/settings.svg';
import profileIcon from '../../assets/profile.svg';
import { useSettings } from '../../contexts/SettingsContext';
import { useAuth } from '../../contexts/AuthContext';
import { useNotificationContext } from '../../contexts/NotificationContext';
import { useBackendStatus } from '../../hooks/useBackendStatus';
import { API_BASE_URL } from "../../config/apiConfig";
import { useTranslation } from 'react-i18next';

interface TopBarProps {
    toggleMobile?: () => void;
}

function TopBar({ toggleMobile }: TopBarProps) {
    const { user } = useAuth();
    const { toggleSettings } = useSettings();
    const { isConnected } = useNotificationContext();
    const { isOnline, isBackendReachable } = useBackendStatus();
    const backendUp = isOnline && isBackendReachable;
    const [isDropdownOpen, setIsDropdownOpen] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);
    const { t } = useTranslation();

    // Close dropdown when clicking outside
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setIsDropdownOpen(false);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, []);

    return (
        <div className="flex items-center justify-between bg-white border-b border-gray-100 px-4 py-3">
            <button
                className="md:hidden p-2 rounded-lg text-gray-500 hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-500 transition-all"
                onClick={toggleMobile}
            >
                <Bars3Icon className="h-6 w-6" />
            </button>
            <div className="flex items-center md:m-auto md:mr-1 space-x-2">
                {/* Backend status indicator */}
                <span className={`hidden sm:flex items-center gap-1 text-xs font-medium ${backendUp ? 'text-green-600' : 'text-red-500'}`}>
                    <span className={`w-2 h-2 rounded-full ${backendUp ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`} />
                    {backendUp ? 'Backend: En ligne' : 'Backend: Hors ligne'}
                </span>
                {/* Live Mercure indicator */}
                {isConnected && backendUp && (
                    <span className="hidden sm:flex items-center gap-1 text-xs text-blue-500 font-medium">
                        <span className="w-2 h-2 rounded-full bg-blue-400 animate-pulse" />
                        Live
                    </span>
                )}

                {/* Support button — visible for all roles */}
                <Link
                    to={user?.type === "buyer" ? "/client/support" : "/support"}
                    title="Contacter le support"
                    className="hidden sm:flex items-center gap-1 text-xs font-medium text-gray-500 hover:text-gray-800 px-2 py-1 rounded-lg hover:bg-gray-100 transition-colors"
                >
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                            d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Support
                </Link>

                {/* Notification bell */}
                <NotificationCenter />
                <div className="relative" ref={dropdownRef}>
                    <button
                        className="profile-content flex gap-2 sm:gap-3 lg:gap-[10px] items-center hover:bg-gray-50 rounded-lg p-1 sm:p-2 transition-colors cursor-pointer"
                        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    >
                        <Avatar
                            size={{ xs: 40, sm: 48, md: 56, lg: 64 }}
                            icon={<UserOutlined />}
                            src={`${API_BASE_URL}${user?.profileImageUrl || ''}`}
                            className="border-2 border-gray-200"
                        />
                        <div className="profile-type-name hidden sm:block">
                            <p className="text-xs sm:text-sm font-medium">{user?.type}</p>
                            <p className="text-xs text-gray-600 truncate max-w-[120px] lg:max-w-none">
                                {user?.email}
                            </p>
                        </div>
                    </button>

                    {/* Dropdown Menu */}
                    {isDropdownOpen && (
                        <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
                            <Link
                                to="/profile"
                                className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
                                onClick={() => setIsDropdownOpen(false)}
                            >
                                <img src={profileIcon} alt="Profile" className="w-4 h-4 mr-3" />
                                {t('topBar.profile')}
                            </Link>
                            {user?.type == "admin" &&
                                <Link
                                    to="/settings"
                                    onClick={() => {
                                        setIsDropdownOpen(false);
                                        toggleSettings();
                                    }}
                                    className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
                                >
                                    <img src={settings} alt="Settings" className="w-4 h-4 mr-3" />
                                    {t('topBar.settings')}
                                </Link>
                            }
                        </div>
                    )}
                </div>

                <div className="hidden sm:block">
                    <LanguageSwitcher />
                </div>
            </div>
        </div>
    )
}

export default TopBar;
