import React, { useEffect, useState, useCallback } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../../contexts/AuthContext";
import { getBasicStats } from "../../services/analyticsService";
import { SkeletonStatCard } from "../../components/SkeletonLoader";
import { useBackendStatus } from "../../hooks/useBackendStatus";
import API from "../../services/httpClient";

interface SellerStats {
  totalOrders?: number | string;
  totalRevenue?: number | string;
  totalPendingOrders?: number | string;
  averageRating?: number | string;
  [key: string]: unknown;
}

const MOCK_STATS: SellerStats = {
  totalOrders: 0,
  totalRevenue: 0,
  totalPendingOrders: 0,
  averageRating: 0,
};

function QuickLink({ to, icon, label, color }: { to: string; icon: React.ReactNode; label: string; color: string }) {
  return (
    <Link
      to={to}
      className={`flex flex-col items-center justify-center gap-2 p-5 rounded-xl border border-gray-100 bg-white hover:shadow-md transition-shadow ${color} group`}
    >
      <div className="w-10 h-10">{icon}</div>
      <span className="text-sm font-medium text-gray-700 group-hover:text-gray-900">{label}</span>
    </Link>
  );
}

const VendorHomePage: React.FC = () => {
  const { user } = useAuth();
  const { isOnline, isBackendReachable } = useBackendStatus();
  const backendUp = isOnline && isBackendReachable;

  const [stats, setStats] = useState<SellerStats>(MOCK_STATS);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [commissionRate, setCommissionRate] = useState<number | null>(null);

  const loadStats = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await getBasicStats();
      setStats({ ...MOCK_STATS, ...(data ?? {}) });
    } catch {
      setError(true);
      setStats(MOCK_STATS);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    API.get("/seller/food-store").then(res => {
      const store = res.data;
      setCommissionRate(store?.commissionRate ?? 15);
    }).catch(() => setCommissionRate(null));
  }, []);

  useEffect(() => {
    loadStats();
  }, [loadStats]);

  const displayName =
    (user as any)?.firstName ||
    (user as any)?.name ||
    user?.email?.split("@")[0] ||
    "Vendeur";

  return (
    <div className="p-6 space-y-6">

      {/* Welcome */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Bonjour, {displayName} 👋</h1>
          <p className="text-sm text-gray-400 mt-1">Tableau de bord vendeur</p>
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          {commissionRate !== null && (
            <span
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
              style={{
                background: commissionRate === 15 ? "#f0fdf4" : "#fff7f0",
                borderColor: commissionRate === 15 ? "#bbf7d0" : "#fed7aa",
                color: commissionRate === 15 ? "#059669" : "#F97316",
              }}
              title="Pourcentage prélevé sur vos ventes"
            >
              💰 Ma commission : {commissionRate}%
            </span>
          )}
          <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold border ${
            backendUp ? "bg-green-50 border-green-200 text-green-700" : "bg-red-50 border-red-200 text-red-600"
          }`}>
            <span className={`w-2 h-2 rounded-full ${backendUp ? "bg-green-500 animate-pulse" : "bg-red-500"}`} />
            {backendUp ? "Backend: En ligne" : "Backend: Hors ligne"}
          </span>
        </div>
      </div>

      {/* Offline / error banner */}
      {!loading && error && (
        <div className="flex items-center justify-between bg-orange-50 border border-orange-200 rounded-lg px-4 py-3">
          <p className="text-sm text-orange-700">⚠️ Statistiques indisponibles — valeurs affichées à 0.</p>
          <button onClick={loadStats} className="text-xs font-semibold text-orange-700 underline ml-4 whitespace-nowrap">
            Réessayer
          </button>
        </div>
      )}

      {/* Stats */}
      {loading ? (
        <SkeletonStatCard />
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: "Total Orders", value: Number(stats.totalOrders ?? 0).toLocaleString(), bg: "bg-orange-50", color: "text-orange-500",
              icon: <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-6 h-6 text-orange-500"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg> },
            { label: "Total Revenue", value: `$${Number(stats.totalRevenue ?? 0).toFixed(2)}`, bg: "bg-green-50", color: "text-green-500",
              icon: <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-6 h-6 text-green-500"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/></svg> },
            { label: "En attente", value: Number(stats.totalPendingOrders ?? 0).toLocaleString(), bg: "bg-yellow-50", color: "text-yellow-600",
              icon: <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-6 h-6 text-yellow-500"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg> },
            { label: "New Users", value: "0", bg: "bg-blue-50", color: "text-blue-500",
              icon: <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-6 h-6 text-blue-500"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg> },
          ].map((s) => (
            <div key={s.label} className={`bg-white rounded-xl p-5 shadow-sm border border-gray-100 flex items-center gap-4 ${error ? "opacity-60" : ""}`}>
              <div className={`w-11 h-11 rounded-lg flex items-center justify-center ${s.bg}`}>{s.icon}</div>
              <div>
                <p className="text-xs text-gray-400 font-medium">{s.label}</p>
                <p className="text-xl font-bold text-gray-800">{s.value}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Quick links */}
      <div>
        <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">Accès rapide</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          <QuickLink to="/orders" label="Commandes" color=""
            icon={<svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-full h-full text-orange-400"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>} />
          <QuickLink to="/dishes" label="Menu" color=""
            icon={<svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-full h-full text-purple-400"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>} />
          <QuickLink to="/wallet" label="Portefeuille" color=""
            icon={<svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-full h-full text-green-400"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>} />
          <QuickLink to="/statistiques" label="Analytics" color=""
            icon={<svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-full h-full text-blue-400"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>} />
        </div>
      </div>
    </div>
  );
};

export default VendorHomePage;
