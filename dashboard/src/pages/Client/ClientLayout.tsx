import React from "react";
import { Link, Outlet, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../../contexts/AuthContext";
import logo from "../../assets/logo.svg";

const navItems = [
  { label: "Mes Commandes", href: "/client/orders", icon: "🛒" },
  { label: "Profil",        href: "/client/profile", icon: "👤" },
  { label: "Support",       href: "/client/support", icon: "📧" },
];

const ClientLayout: React.FC = () => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate("/login");
  };

  return (
    <div style={{ minHeight: "100vh", background: "#f9fafb", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <header style={{ background: "#fff", borderBottom: "1px solid #f3f4f6", padding: "0 24px", height: 64, display: "flex", alignItems: "center", justifyContent: "space-between", position: "sticky", top: 0, zIndex: 50, boxShadow: "0 1px 3px rgba(0,0,0,0.06)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <img src={logo} alt="Cuisinous" style={{ width: 36, height: 36 }} />
          <span style={{ fontWeight: 700, fontSize: "1.1rem", color: "#1f2937" }}>Cuisinous</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <span style={{ fontSize: 14, color: "#6b7280" }}>
            {(user as any)?.firstName} {(user as any)?.lastName}
          </span>
          <button onClick={handleLogout} style={{ background: "none", border: "1px solid #e5e7eb", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontSize: 13, color: "#374151" }}>
            Déconnexion
          </button>
        </div>
      </header>

      <div style={{ display: "flex", flex: 1 }}>
        {/* Sidebar nav */}
        <nav style={{ width: 220, background: "#fff", borderRight: "1px solid #f3f4f6", padding: "24px 12px", display: "flex", flexDirection: "column", gap: 4 }}>
          {navItems.map((item) => {
            const active = location.pathname.startsWith(item.href);
            return (
              <Link key={item.href} to={item.href} style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 14px", borderRadius: 10, textDecoration: "none", fontWeight: active ? 600 : 400, fontSize: 14, color: active ? "#F97316" : "#374151", background: active ? "#fff7f0" : "transparent", border: active ? "1px solid #fed7aa" : "1px solid transparent", transition: "all 0.15s" }}>
                <span>{item.icon}</span>
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Page content via Outlet */}
        <main style={{ flex: 1, padding: 24, overflowY: "auto" }}>
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default ClientLayout;
