import React, { useEffect, useState } from "react";
import "ag-grid-community/styles/ag-grid.css";
import "ag-grid-community/styles/ag-theme-alpine.css";
import Users from "../Users/Users";
import { useAuth } from "../../contexts/AuthContext";
import { getAdminBasicStats } from "../../services/analyticsService";
import { SkeletonStatCard } from "../../components/SkeletonLoader";
import EmptyState from "../../components/EmptyState";
import { useBackendStatus } from "../../hooks/useBackendStatus";

interface AdminStats {
  totalUsers?: number;
  totalOrders?: number;
  totalFoodStores?: number;
  totalRevenue?: number | string;
  [key: string]: unknown;
}

function StatCard({
  label,
  value,
  icon,
  color,
}: {
  label: string;
  value: string | number;
  icon: React.ReactNode;
  color: string;
}) {
  return (
    <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100 flex items-center gap-4">
      <div className={`w-11 h-11 rounded-lg flex items-center justify-center ${color}`}>
        {icon}
      </div>
      <div>
        <p className="text-xs text-gray-400 font-medium">{label}</p>
        <p className="text-xl font-bold text-gray-800">{value}</p>
      </div>
    </div>
  );
}

const StatsEmptyIcon = (
  <svg viewBox="0 0 64 64" fill="none" className="w-full h-full" stroke="currentColor">
    <rect x="8" y="32" width="12" height="24" rx="2" strokeWidth="3"/>
    <rect x="26" y="20" width="12" height="36" rx="2" strokeWidth="3"/>
    <rect x="44" y="12" width="12" height="44" rx="2" strokeWidth="3"/>
  </svg>
);

const HomePage: React.FC = () => {
  const { user } = useAuth();
  const { isOnline, isBackendReachable } = useBackendStatus();
  const backendUp = isOnline && isBackendReachable;

  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const loadStats = async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await getAdminBasicStats();
      setStats(data);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStats();
  }, []);

  const displayName =
    (user as any)?.firstName ||
    (user as any)?.name ||
    user?.email?.split("@")[0] ||
    "Admin";

  return (
    <div className="p-6 space-y-6">
      {/* Welcome header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">
            Bonjour, {displayName} 👋
          </h1>
          <p className="text-sm text-gray-400 mt-1">
            Tableau de bord administrateur
          </p>
        </div>
        {/* Backend status badge */}
        <span
          className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold border ${
            backendUp
              ? "bg-green-50 border-green-200 text-green-700"
              : "bg-red-50 border-red-200 text-red-600"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              backendUp ? "bg-green-500 animate-pulse" : "bg-red-500"
            }`}
          />
          {backendUp ? "Backend: En ligne" : "Backend: Hors ligne"}
        </span>
      </div>

      {/* Stat cards */}
      {loading && <SkeletonStatCard />}
      {!loading && error && (
        <EmptyState
          icon={StatsEmptyIcon}
          title="Statistiques indisponibles"
          description="Impossible de charger les données. Le serveur ne répond pas."
          onRetry={loadStats}
        />
      )}
      {!loading && !error && stats && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard
            label="Utilisateurs"
            value={Number(stats.totalUsers ?? 0).toLocaleString()}
            color="bg-blue-50"
            icon={
              <svg className="w-5 h-5 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M17 20h5v-2a4 4 0 00-4-4h-1M9 20H4v-2a4 4 0 014-4h1m4-4a4 4 0 100-8 4 4 0 000 8z" />
              </svg>
            }
          />
          <StatCard
            label="Commandes"
            value={Number(stats.totalOrders ?? 0).toLocaleString()}
            color="bg-orange-50"
            icon={
              <svg className="w-5 h-5 text-orange-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            }
          />
          <StatCard
            label="Restaurants"
            value={Number(stats.totalFoodStores ?? 0).toLocaleString()}
            color="bg-purple-50"
            icon={
              <svg className="w-5 h-5 text-purple-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0H5m14 0h2M5 21H3" />
              </svg>
            }
          />
          <StatCard
            label="Revenus"
            value={`${Number(stats.totalRevenue ?? 0).toLocaleString()} €`}
            color="bg-green-50"
            icon={
              <svg className="w-5 h-5 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
              </svg>
            }
          />
        </div>
      )}

      {/* Users table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="px-5 py-4 border-b border-gray-100">
          <h2 className="text-base font-semibold text-gray-700">Utilisateurs</h2>
        </div>
        <div className="ag-theme-alpine" style={{ height: 400, width: "100%" }}>
          <Users />
        </div>
      </div>
    </div>
  );
};

export default HomePage;
