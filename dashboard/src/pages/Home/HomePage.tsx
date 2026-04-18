import React, { useEffect, useState, useCallback } from "react";
import "ag-grid-community/styles/ag-grid.css";
import "ag-grid-community/styles/ag-theme-alpine.css";
import Users from "../Users/Users";
import { useAuth } from "../../contexts/AuthContext";
import { getAdminBasicStats } from "../../services/analyticsService";
import { SkeletonStatCard } from "../../components/SkeletonLoader";
import { useBackendStatus } from "../../hooks/useBackendStatus";

interface AdminStats {
  totalUsers?: number | string;
  totalOrders?: number | string;
  totalFoodStores?: number | string;
  totalRevenue?: number | string;
  activeUsers?: number | string;
  [key: string]: unknown;
}

const MOCK_STATS: AdminStats = {
  totalUsers: 0,
  totalOrders: 0,
  totalFoodStores: 0,
  totalRevenue: 0,
};

function StatCard({
  label,
  value,
  icon,
  color,
  offline,
}: {
  label: string;
  value: string | number;
  icon: React.ReactNode;
  color: string;
  offline?: boolean;
}) {
  return (
    <div className={`bg-white rounded-xl p-5 shadow-sm border flex items-center gap-4 ${offline ? "border-gray-100 opacity-60" : "border-gray-100"}`}>
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

const HomePage: React.FC = () => {
  const { user } = useAuth();
  const { isOnline, isBackendReachable } = useBackendStatus();
  const backendUp = isOnline && isBackendReachable;

  const [stats, setStats] = useState<AdminStats>(MOCK_STATS);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const loadStats = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await getAdminBasicStats();
      setStats({ ...MOCK_STATS, ...(data ?? {}) });
    } catch {
      setError(true);
      setStats(MOCK_STATS);
    } finally {
      setLoading(false);
    }
  }, []);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadStats();
    setRefreshing(false);
  }, [loadStats]);

  useEffect(() => {
    loadStats();
  }, [loadStats]);

  const displayName =
    (user as any)?.firstName ||
    (user as any)?.name ||
    user?.email?.split("@")[0] ||
    "Admin";

  const safeNum = (v: unknown) =>
    Number(v ?? 0).toLocaleString();

  return (
    <div className="p-6 space-y-6">
      <style>{`
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .spin-active { animation: spin 0.8s linear infinite; }
      `}</style>

      {/* ── Welcome header ── */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">
            Bonjour, {displayName} 👋
          </h1>
          <p className="text-sm text-gray-400 mt-1">
            Tableau de bord administrateur
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Refresh button */}
          <button
            onClick={handleRefresh}
            disabled={refreshing || loading}
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg border border-gray-200 bg-white text-xs font-medium text-gray-600 hover:bg-gray-50 hover:border-gray-300 transition-all disabled:opacity-50"
            title="Actualiser les statistiques"
          >
            <svg
              className={`w-3.5 h-3.5 ${refreshing ? 'spin-active' : ''}`}
              fill="none" viewBox="0 0 24 24" stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Actualiser
          </button>

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
      </div>

      {/* ── Error / offline banner under the header ── */}
      {!loading && error && (
        <div className="flex items-center justify-between bg-orange-50 border border-orange-200 rounded-lg px-4 py-3">
          <p className="text-sm text-orange-700">
            ⚠️ Statistiques indisponibles — les valeurs affichées sont à 0.
          </p>
          <button
            onClick={loadStats}
            className="text-xs font-semibold text-orange-700 underline ml-4 whitespace-nowrap"
          >
            Réessayer
          </button>
        </div>
      )}

      {/* ── Stat cards — always visible, 0 when offline ── */}
      {loading ? (
        <SkeletonStatCard />
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard
            label="Utilisateurs"
            value={safeNum(stats.totalUsers)}
            color="bg-blue-50"
            offline={error}
            icon={
              <svg className="w-5 h-5 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M17 20h5v-2a4 4 0 00-4-4h-1M9 20H4v-2a4 4 0 014-4h1m4-4a4 4 0 100-8 4 4 0 000 8z" />
              </svg>
            }
          />
          <StatCard
            label="Total Orders"
            value={safeNum(stats.totalOrders)}
            color="bg-orange-50"
            offline={error}
            icon={
              <svg className="w-5 h-5 text-orange-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            }
          />
          <StatCard
            label="Active Stores"
            value={safeNum(stats.totalFoodStores)}
            color="bg-purple-50"
            offline={error}
            icon={
              <svg className="w-5 h-5 text-purple-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0H5m14 0h2M5 21H3" />
              </svg>
            }
          />
          <StatCard
            label="Total Revenue"
            value={`$${Number(stats.totalRevenue ?? 0).toFixed(2)}`}
            color="bg-green-50"
            offline={error}
            icon={
              <svg className="w-5 h-5 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
              </svg>
            }
          />
        </div>
      )}

      {/* ── Users table ── */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-visible">
        <div className="px-5 py-4 border-b border-gray-100">
          <h2 className="text-base font-semibold text-gray-700">Utilisateurs</h2>
        </div>
        <Users />
      </div>
    </div>
  );
};

export default HomePage;
