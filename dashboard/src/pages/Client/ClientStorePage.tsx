import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import API from "../../services/httpClient";

interface Dish {
  id: string;
  name: string;
  description?: string;
  price: number;
  imageUrl?: string;
}

const MOCK_DISHES: Dish[] = [
  { id: "d1", name: "Couscous traditionnel", description: "Semoule, légumes, viande",    price: 12.5 },
  { id: "d2", name: "Tajine poulet",         description: "Citron confit, olives",        price: 11.0 },
  { id: "d3", name: "Brick à l'œuf",         description: "Entrée croustillante",         price: 5.5  },
  { id: "d4", name: "Chorba",                description: "Soupe traditionnelle",         price: 6.0  },
  { id: "d5", name: "Baklava",               description: "Pâtisserie orientale",         price: 4.0  },
];

const ClientStorePage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [dishes, setDishes]   = useState<Dish[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDemo, setIsDemo]   = useState(false);

  useEffect(() => {
    // Route buyer confirmée dans BuyerController.php#L1002
    API.get(`/buyer/food-stores/${id}/dishes`)
      .then((res) => {
        const data = res.data?.data ?? res.data ?? [];
        if (Array.isArray(data) && data.length > 0) {
          setDishes(data);
        } else {
          setDishes(MOCK_DISHES);
          setIsDemo(true);
        }
      })
      .catch(() => {
        setDishes(MOCK_DISHES);
        setIsDemo(true);
      })
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) return (
    <div style={{ display: "flex", justifyContent: "center", padding: 60 }}>
      <div style={{ width: 36, height: 36, border: "3px solid #f3f4f6", borderTop: "3px solid #F97316", borderRadius: "50%", animation: "spin 0.8s linear infinite" }} />
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  return (
    <div>
      <button
        onClick={() => navigate("/client/home")}
        style={{ display: "flex", alignItems: "center", gap: 6, background: "none", border: "none", cursor: "pointer", color: "#F97316", fontWeight: 600, fontSize: 14, marginBottom: 20, padding: 0 }}
      >
        ← Retour aux restaurants
      </button>

      {isDemo && (
        <div style={{ background: "#fef9c3", border: "1px solid #fde047", borderRadius: 10, padding: "10px 16px", marginBottom: 20, fontSize: 13, color: "#854d0e", display: "flex", alignItems: "center", gap: 8 }}>
          <span>⚠️</span>
          <span><strong>Mode démo</strong> — 500 : migration BDD manquante. Lancez sur Render Shell : <code style={{ background: "#fef08a", padding: "1px 6px", borderRadius: 4 }}>php bin/console doctrine:migrations:migrate --no-interaction</code></span>
        </div>
      )}

      <h1 style={{ fontSize: "1.5rem", fontWeight: 700, color: "#1f2937", marginBottom: 24 }}>Menu</h1>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 16 }}>
        {dishes.map((dish) => (
          <div key={dish.id} style={{ background: "#fff", borderRadius: 14, border: "1px solid #f3f4f6", overflow: "hidden", boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
            <div style={{ height: 120, background: dish.imageUrl ? `url(${dish.imageUrl}) center/cover` : "#fff7f0", display: "flex", alignItems: "center", justifyContent: "center" }}>
              {!dish.imageUrl && <span style={{ fontSize: 40 }}>🍴</span>}
            </div>
            <div style={{ padding: 14 }}>
              <div style={{ fontWeight: 600, fontSize: 14, color: "#1f2937", marginBottom: 4 }}>{dish.name}</div>
              {dish.description && <div style={{ fontSize: 12, color: "#6b7280", marginBottom: 10 }}>{dish.description}</div>}
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                <span style={{ fontWeight: 700, color: "#F97316", fontSize: 15 }}>{dish.price.toFixed(2)} €</span>
                <button style={{ background: "#F97316", color: "#fff", border: "none", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 600 }}>
                  Ajouter
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ClientStorePage;
