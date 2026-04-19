import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import API from "../../services/httpClient";

interface FoodStore {
  id: string;
  name: string;
  description?: string;
  imageUrl?: string;
  cuisine?: string;
  categoryType?: string;
  averageRating?: number;
  isOpen?: boolean;
}

const MOCK_STORES: FoodStore[] = [
  { id: "1", name: "boutique A",           description: "Restaurant algérien", categoryType: "FOOD", averageRating: 4.5, isOpen: true },
  { id: "2", name: "doc's",                description: "Cuisine maison",       categoryType: "FOOD", averageRating: 4.2, isOpen: true },
  { id: "3", name: "La Morina",            description: "Plats variés",         categoryType: "FOOD", averageRating: 4.8, isOpen: true },
  { id: "4", name: "Venny's food",         description: "Fast food",            categoryType: "FOOD", averageRating: 4.0, isOpen: true },
  { id: "5", name: "café restaurant zein", description: "Café et repas",        categoryType: "FOOD", averageRating: 4.6, isOpen: true },
];

const ClientHomePage: React.FC = () => {
  const [stores, setStores]       = useState<FoodStore[]>([]);
  const [loading, setLoading]     = useState(true);
  const [isDemo, setIsDemo]       = useState(false);
  const [demoReason, setDemoReason] = useState<string>("");
  const navigate = useNavigate();

  useEffect(() => {
    // Route buyer confirmée dans BuyerController.php#L797
    // httpClient baseURL = .../api donc pas de préfixe /api ici
    API.get("/buyer/food-stores")
      .then((res) => {
        const data = res.data?.data ?? res.data ?? [];
        if (Array.isArray(data) && data.length > 0) {
          setStores(data);
        } else {
          setStores(MOCK_STORES);
          setIsDemo(true);
          setDemoReason("Aucun restaurant retourné par l'API.");
        }
      })
      .catch((err) => {
        const status = err?.response?.status;
        setDemoReason(status === 500
          ? "500 — Migration BDD manquante (commission_rate / vendor_contract)."
          : `Erreur ${status ?? "réseau"}.`
        );
        setStores(MOCK_STORES);
        setIsDemo(true);
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <div style={{ display: "flex", justifyContent: "center", padding: 60 }}>
      <div style={{ width: 36, height: 36, border: "3px solid #f3f4f6", borderTop: "3px solid #F97316", borderRadius: "50%", animation: "spin 0.8s linear infinite" }} />
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  return (
    <div>
      {isDemo && (
        <div style={{ background: "#fef2f2", border: "1px solid #fca5a5", borderRadius: 10, padding: "12px 16px", marginBottom: 20, fontSize: 13, color: "#991b1b" }}>
          <div style={{ fontWeight: 700, marginBottom: 4 }}>⚠️ Erreur serveur — Mode démo activé ({demoReason})</div>
          <div>Pour activer les vraies données, lancez sur Render Shell :</div>
          <code style={{ display: "block", marginTop: 6, background: "#fee2e2", padding: "6px 10px", borderRadius: 6, fontFamily: "monospace", fontSize: 12 }}>
            php bin/console doctrine:migrations:migrate --no-interaction
          </code>
        </div>
      )}

      <h1 style={{ fontSize: "1.5rem", fontWeight: 700, color: "#1f2937", marginBottom: 8 }}>Restaurants</h1>
      <p style={{ color: "#6b7280", marginBottom: 24 }}>Choisissez un restaurant pour commander</p>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 20 }}>
        {stores.map((store) => (
          <div
            key={store.id}
            onClick={() => navigate(`/client/store/${store.id}`)}
            style={{ background: "#fff", borderRadius: 14, border: "1px solid #f3f4f6", overflow: "hidden", cursor: "pointer", boxShadow: "0 1px 4px rgba(0,0,0,0.06)", transition: "box-shadow 0.15s, transform 0.15s" }}
            onMouseEnter={(e) => { (e.currentTarget as HTMLDivElement).style.boxShadow = "0 4px 16px rgba(0,0,0,0.12)"; (e.currentTarget as HTMLDivElement).style.transform = "translateY(-2px)"; }}
            onMouseLeave={(e) => { (e.currentTarget as HTMLDivElement).style.boxShadow = "0 1px 4px rgba(0,0,0,0.06)"; (e.currentTarget as HTMLDivElement).style.transform = "none"; }}
          >
            <div style={{ height: 140, background: store.imageUrl ? `url(${store.imageUrl}) center/cover` : "#fff7f0", display: "flex", alignItems: "center", justifyContent: "center" }}>
              {!store.imageUrl && <span style={{ fontSize: 48 }}>🍽️</span>}
            </div>
            <div style={{ padding: 16 }}>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
                <div style={{ fontWeight: 600, fontSize: 15, color: "#1f2937" }}>{store.name}</div>
                {store.isOpen !== undefined && (
                  <span style={{ fontSize: 11, fontWeight: 600, padding: "2px 8px", borderRadius: 20, background: store.isOpen ? "#dcfce7" : "#fee2e2", color: store.isOpen ? "#16a34a" : "#dc2626" }}>
                    {store.isOpen ? "Ouvert" : "Fermé"}
                  </span>
                )}
              </div>
              {store.averageRating !== undefined && (
                <div style={{ fontSize: 12, color: "#f59e0b", marginBottom: 4 }}>
                  {"★".repeat(Math.round(store.averageRating))}{"☆".repeat(5 - Math.round(store.averageRating))} <span style={{ color: "#6b7280" }}>{store.averageRating.toFixed(1)}</span>
                </div>
              )}
              {store.description && (
                <div style={{ fontSize: 13, color: "#6b7280", lineHeight: 1.4, display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }}>{store.description}</div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ClientHomePage;
