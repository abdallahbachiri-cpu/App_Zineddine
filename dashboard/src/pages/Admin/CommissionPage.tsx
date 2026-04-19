import React, { useState, useEffect, useMemo } from "react";
import { Spin, message, Modal } from "antd";
import API from "../../services/httpClient";

const DEFAULT_RATE = 15;

interface StoreCommission {
  id: string;
  name: string;
  sellerName: string;
  ownerEmail: string;
  commissionRate: number;
  isActive: boolean;
}

const CommissionPage: React.FC = () => {
  const [loading, setLoading]         = useState(true);
  const [stores, setStores]           = useState<StoreCommission[]>([]);
  const [fetchError, setFetchError]   = useState<string | null>(null);
  const [search, setSearch]           = useState("");
  const [page, setPage]               = useState(1);
  const PAGE_SIZE = 10;

  // Modal state
  const [modalStore, setModalStore]   = useState<StoreCommission | null>(null);
  const [modalRate, setModalRate]     = useState(DEFAULT_RATE);
  const [savingStore, setSavingStore] = useState(false);

  const fetchData = async () => {
    setLoading(true);
    setFetchError(null);
    try {
      // Fetch stores and users in parallel
      const [storesRes, usersRes] = await Promise.all([
        API.get("/admin/food-stores"),
        API.get("/admin/users"),
      ]);

      const rawStores: any[] = storesRes.data?.data ?? storesRes.data ?? [];
      const rawUsers: any[]  = usersRes.data?.data  ?? usersRes.data  ?? [];

      // Build sellerId → user map
      const userMap = new Map<string, { name: string; email: string }>();
      rawUsers.forEach((u: any) => {
        if (u.id) {
          userMap.set(u.id, {
            name:  [u.firstName, u.lastName].filter(Boolean).join(" ") || u.email || "—",
            email: u.email ?? "",
          });
        }
      });

      const mapped: StoreCommission[] = rawStores.map((s: any) => {
        const owner = userMap.get(s.sellerId ?? "");
        return {
          id:             String(s.id ?? ""),
          name:           s.name ?? "—",
          sellerName:     owner?.name  ?? "—",
          ownerEmail:     owner?.email ?? "—",
          commissionRate: typeof s.commissionRate === "number" ? s.commissionRate : DEFAULT_RATE,
          isActive:       s.isActive ?? false,
        };
      });

      setStores(mapped);
    } catch (err: any) {
      const detail = err?.response?.data?.error || err?.message || "Erreur inconnue";
      setFetchError(`Impossible de charger les données : ${detail}`);
      setStores([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  // ── Stats ──────────────────────────────────────────────────────────────────
  const avgRate = stores.length
    ? (stores.reduce((s, x) => s + x.commissionRate, 0) / stores.length).toFixed(1)
    : DEFAULT_RATE.toFixed(1);
  const customCount = stores.filter(s => s.commissionRate !== DEFAULT_RATE).length;

  // ── Filtered + paginated ──────────────────────────────────────────────────
  const filtered = useMemo(
    () => stores.filter(s =>
      s.name.toLowerCase().includes(search.toLowerCase()) ||
      s.sellerName.toLowerCase().includes(search.toLowerCase())
    ),
    [stores, search]
  );

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const visible = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  // ── Modal helpers ─────────────────────────────────────────────────────────
  const openModal = (store: StoreCommission) => {
    setModalStore(store);
    setModalRate(store.commissionRate);
  };

  const saveCommission = async () => {
    if (!modalStore) return;
    setSavingStore(true);
    try {
      await API.put(`/admin/stores/${modalStore.id}/commission`, {
        commissionRate: modalRate,
        commissionOverride: modalRate !== DEFAULT_RATE,
      });
      message.success(`Commission mise à jour pour ${modalStore.name}`);
      setModalStore(null);
      fetchData();
    } catch (err: any) {
      if (err?.response?.status === 404) {
        // Route not yet deployed — update locally only
        setStores(prev =>
          prev.map(s => s.id === modalStore.id ? { ...s, commissionRate: modalRate } : s)
        );
        message.warning(`Commission mise à jour localement (route backend indisponible)`);
        setModalStore(null);
      } else {
        message.error("Erreur lors de la mise à jour.");
      }
    } finally {
      setSavingStore(false);
    }
  };

  const sliderColor = modalRate <= DEFAULT_RATE ? "#059669" : "#F97316";

  if (loading) {
    return (
      <div style={{ display: "flex", justifyContent: "center", paddingTop: 80 }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ padding: 28 }}>
      {/* ── Title ─────────────────────────────────────────────────────────── */}
      <h1 style={{ fontSize: "1.5rem", fontWeight: 800, color: "#111827", marginBottom: 4 }}>
        💰 Gestion des commissions
      </h1>
      <p style={{ color: "#6b7280", fontSize: 14, marginBottom: 20 }}>
        Configurez le taux de commission individuellement pour chaque vendeur.
      </p>

      {/* ── Error banner ─────────────────────────────────────────────────── */}
      {fetchError && (
        <div style={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          background: "#fef2f2", border: "1px solid #fecaca", borderRadius: 10,
          padding: "12px 20px", marginBottom: 24,
        }}>
          <div>
            <span style={{ fontWeight: 700, color: "#dc2626", fontSize: 14 }}>⚠️ Erreur de chargement</span>
            <p style={{ margin: "2px 0 0", color: "#b91c1c", fontSize: 13 }}>{fetchError}</p>
          </div>
          <button
            onClick={fetchData}
            style={{ marginLeft: 16, padding: "6px 14px", background: "#dc2626", color: "#fff", border: "none", borderRadius: 7, fontSize: 13, cursor: "pointer", fontWeight: 600, whiteSpace: "nowrap" }}
          >
            Réessayer
          </button>
        </div>
      )}

      {/* ── Stats row ─────────────────────────────────────────────────────── */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 16, marginBottom: 32 }}>
        {[
          { label: "Commission moyenne", value: `${avgRate}%`, icon: "📊", color: "#F97316" },
          { label: "Taux par défaut",    value: `${DEFAULT_RATE}%`,     icon: "⚙️",  color: "#6366f1" },
          { label: "Taux personnalisés", value: String(customCount),    icon: "✏️",  color: "#059669" },
        ].map(stat => (
          <div key={stat.label} style={{
            background: "#fff", borderRadius: 12, padding: "20px 24px",
            border: "1px solid #f3f4f6", boxShadow: "0 1px 4px rgba(0,0,0,0.05)",
          }}>
            <div style={{ fontSize: 28, marginBottom: 6 }}>{stat.icon}</div>
            <div style={{ fontSize: "1.8rem", fontWeight: 900, color: stat.color }}>{stat.value}</div>
            <div style={{ fontSize: 13, color: "#6b7280" }}>{stat.label}</div>
          </div>
        ))}
      </div>

      {/* ── Search ────────────────────────────────────────────────────────── */}
      <div style={{ marginBottom: 16 }}>
        <input
          type="text"
          placeholder="🔍 Rechercher par magasin ou vendeur…"
          value={search}
          onChange={e => { setSearch(e.target.value); setPage(1); }}
          style={{
            width: 360, padding: "9px 14px", border: "1px solid #d1d5db",
            borderRadius: 8, fontSize: 14, outline: "none",
          }}
        />
      </div>

      {/* ── Table ─────────────────────────────────────────────────────────── */}
      <div style={{ background: "#fff", borderRadius: 14, border: "1px solid #e5e7eb", overflow: "hidden", boxShadow: "0 1px 4px rgba(0,0,0,0.05)" }}>
        <div style={{ padding: "14px 24px", borderBottom: "1px solid #f3f4f6", fontWeight: 700, fontSize: 14, color: "#111827" }}>
          🏪 Vendeurs ({filtered.length})
        </div>
        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ background: "#f9fafb" }}>
                <th style={thStyle}>Magasin</th>
                <th style={thStyle}>Propriétaire</th>
                <th style={thStyle}>Email</th>
                <th style={thStyle}>Commission actuelle</th>
                <th style={thStyle}>Statut</th>
                <th style={thStyle}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {visible.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: "center", padding: 40, color: "#9ca3af" }}>
                    {stores.length === 0
                      ? <span>Aucun magasin trouvé.{" "}<button onClick={fetchData} style={{ color: "#F97316", background: "none", border: "none", cursor: "pointer", textDecoration: "underline", fontSize: 13 }}>Réessayer</button></span>
                      : "Aucun résultat pour cette recherche."}
                  </td>
                </tr>
              ) : visible.map(store => (
                <tr key={store.id} style={{ borderBottom: "1px solid #f3f4f6" }}>
                  <td style={tdStyle}>
                    <span style={{ fontWeight: 600, color: "#111827" }}>{store.name}</span>
                  </td>
                  <td style={tdStyle}>{store.sellerName}</td>
                  <td style={tdStyle}>
                    <span style={{ fontSize: 13, color: "#6b7280" }}>{store.ownerEmail}</span>
                  </td>
                  <td style={tdStyle}>
                    <span style={{
                      display: "inline-flex", alignItems: "center", gap: 6,
                      background: store.commissionRate === DEFAULT_RATE ? "#f0fdf4" : "#fff7f0",
                      color: store.commissionRate === DEFAULT_RATE ? "#059669" : "#F97316",
                      border: `1px solid ${store.commissionRate === DEFAULT_RATE ? "#bbf7d0" : "#fed7aa"}`,
                      borderRadius: 8, padding: "3px 12px", fontWeight: 700, fontSize: 15,
                    }}>
                      {store.commissionRate}%
                      {store.commissionRate !== DEFAULT_RATE && <span style={{ fontSize: 11 }}>personnalisé</span>}
                    </span>
                  </td>
                  <td style={tdStyle}>
                    {store.isActive
                      ? <span style={{ color: "#059669", fontWeight: 600, fontSize: 12 }}>● Actif</span>
                      : <span style={{ color: "#9ca3af", fontSize: 12 }}>● Inactif</span>}
                  </td>
                  <td style={tdStyle}>
                    <button
                      onClick={() => openModal(store)}
                      style={{
                        background: "none", border: "1px solid #e5e7eb", borderRadius: 7,
                        padding: "5px 12px", fontSize: 12, cursor: "pointer", color: "#374151",
                      }}
                    >
                      ✏️ Modifier
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div style={{ display: "flex", justifyContent: "center", alignItems: "center", gap: 8, padding: "14px 24px", borderTop: "1px solid #f3f4f6" }}>
            <button
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              style={{ padding: "5px 12px", borderRadius: 6, border: "1px solid #e5e7eb", background: "#fff", cursor: currentPage === 1 ? "not-allowed" : "pointer", color: "#374151", opacity: currentPage === 1 ? 0.4 : 1 }}
            >
              ‹ Préc.
            </button>
            {Array.from({ length: totalPages }, (_, i) => i + 1).map(p => (
              <button
                key={p}
                onClick={() => setPage(p)}
                style={{
                  padding: "5px 10px", borderRadius: 6, border: "1px solid",
                  borderColor: p === currentPage ? "#F97316" : "#e5e7eb",
                  background: p === currentPage ? "#fff7f0" : "#fff",
                  color: p === currentPage ? "#F97316" : "#374151",
                  fontWeight: p === currentPage ? 700 : 400, cursor: "pointer",
                }}
              >
                {p}
              </button>
            ))}
            <button
              onClick={() => setPage(p => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              style={{ padding: "5px 12px", borderRadius: 6, border: "1px solid #e5e7eb", background: "#fff", cursor: currentPage === totalPages ? "not-allowed" : "pointer", color: "#374151", opacity: currentPage === totalPages ? 0.4 : 1 }}
            >
              Suiv. ›
            </button>
          </div>
        )}
      </div>

      {/* ── Edit modal ────────────────────────────────────────────────────── */}
      <Modal
        open={!!modalStore}
        title={null}
        footer={null}
        onCancel={() => setModalStore(null)}
        width={480}
      >
        {modalStore && (
          <div style={{ padding: "8px 0" }}>
            <div style={{ marginBottom: 20 }}>
              <div style={{ fontSize: 18, fontWeight: 800, color: "#111827" }}>
                Commission de {modalStore.name}
              </div>
              <div style={{ fontSize: 13, color: "#6b7280", marginTop: 2 }}>
                Propriétaire : {modalStore.sellerName}
              </div>
            </div>

            <div style={{ background: "#f9fafb", borderRadius: 10, padding: "12px 16px", marginBottom: 20 }}>
              <span style={{ fontSize: 13, color: "#6b7280" }}>Taux actuel : </span>
              <span style={{ fontWeight: 700, color: "#111827" }}>{modalStore.commissionRate}%</span>
            </div>

            {/* Slider */}
            <div style={{ marginBottom: 20 }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
                <label style={{ fontWeight: 600, fontSize: 13, color: "#374151" }}>
                  Nouveau taux
                </label>
                <span style={{ fontSize: 18, fontWeight: 900, color: sliderColor }}>
                  {modalRate}%
                </span>
              </div>
              <input
                type="range"
                min={0}
                max={50}
                step={0.5}
                value={modalRate}
                onChange={e => setModalRate(parseFloat(e.target.value))}
                style={{ width: "100%", accentColor: sliderColor, cursor: "pointer" }}
              />
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 11, color: "#9ca3af", marginTop: 4 }}>
                <span>0%</span>
                <span>25%</span>
                <span>50%</span>
              </div>
            </div>

            {/* Numeric input */}
            <div style={{ marginBottom: 20 }}>
              <input
                type="number"
                min={0}
                max={50}
                step={0.5}
                value={modalRate}
                onChange={e => {
                  const v = parseFloat(e.target.value);
                  if (!isNaN(v)) setModalRate(Math.min(50, Math.max(0, v)));
                }}
                style={{
                  width: "100%", padding: "9px 14px", border: "1px solid #d1d5db",
                  borderRadius: 8, fontSize: 15, fontWeight: 700, color: sliderColor,
                  outline: "none", textAlign: "center",
                }}
              />
            </div>

            {/* Real-time preview */}
            <div style={{
              background: "#f0fdf4", border: "1px solid #bbf7d0", borderRadius: 10,
              padding: "12px 16px", marginBottom: 24, fontSize: 13, color: "#065f46",
            }}>
              📊 Sur une commande de <strong>100,00 $</strong>, la commission sera de{" "}
              <strong style={{ color: sliderColor }}>{modalRate.toFixed(2)} $</strong>{" "}
              et le vendeur recevra{" "}
              <strong>{(100 - modalRate).toFixed(2)} $</strong>.
            </div>

            {/* Buttons */}
            <div style={{ display: "flex", gap: 10 }}>
              <button
                onClick={() => setModalRate(DEFAULT_RATE)}
                style={{
                  flex: 1, padding: "9px", background: "#f3f4f6", border: "1px solid #e5e7eb",
                  borderRadius: 8, fontSize: 13, cursor: "pointer", color: "#374151", fontWeight: 600,
                }}
              >
                Réinitialiser à {DEFAULT_RATE}%
              </button>
              <button
                onClick={() => setModalStore(null)}
                style={{
                  padding: "9px 16px", background: "none", border: "1px solid #e5e7eb",
                  borderRadius: 8, fontSize: 13, cursor: "pointer", color: "#6b7280",
                }}
              >
                Annuler
              </button>
              <button
                onClick={saveCommission}
                disabled={savingStore}
                style={{
                  flex: 1, padding: "9px", background: "#F97316", border: "none",
                  borderRadius: 8, fontSize: 13, fontWeight: 700, color: "#fff",
                  cursor: savingStore ? "not-allowed" : "pointer", opacity: savingStore ? 0.7 : 1,
                }}
              >
                {savingStore ? "Enregistrement…" : "✅ Enregistrer"}
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

const thStyle: React.CSSProperties = {
  textAlign: "left", padding: "10px 16px", fontSize: 11,
  fontWeight: 700, color: "#6b7280", textTransform: "uppercase", letterSpacing: "0.05em",
};

const tdStyle: React.CSSProperties = {
  padding: "13px 16px", fontSize: 14, color: "#374151",
};

export default CommissionPage;
