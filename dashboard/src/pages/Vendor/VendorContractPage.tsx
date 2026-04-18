import React, { useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import API from "../../services/httpClient";
import { message } from "antd";
import logo from "../../assets/logo.svg";

const CONTRACT_TEXT = `
ACCORD DE VENDEUR — CUISINOUS

Dernière mise à jour : 18 avril 2026

En acceptant cet accord, vous (ci-après "le Vendeur") acceptez les termes et conditions suivants avec Cuisinous Inc. (ci-après "la Plateforme").

1. OBJET
La Plateforme met à disposition du Vendeur un espace de vente en ligne permettant la commercialisation de plats cuisinés maison. Le Vendeur s'engage à utiliser cet espace conformément aux présentes conditions.

2. OBLIGATIONS DU VENDEUR
2.1. Le Vendeur garantit que tous les aliments proposés respectent les normes sanitaires et alimentaires en vigueur au Canada.
2.2. Le Vendeur s'engage à décrire fidèlement ses produits (ingrédients, allergènes, photos).
2.3. Le Vendeur est responsable du respect des délais de préparation indiqués.
2.4. Le Vendeur s'engage à maintenir un niveau de qualité constant et à traiter les clients avec respect.
2.5. Le Vendeur ne peut pas vendre de produits illicites, dangereux ou non conformes aux réglementations alimentaires.

3. COMMISSIONS ET PAIEMENTS
3.1. La Plateforme perçoit une commission sur chaque vente réalisée via la Plateforme. Le taux de commission par défaut est de 15 % du montant HT de la commande, sauf accord particulier avec l'administration.
3.2. Les paiements sont traités via Stripe. Le Vendeur doit compléter son profil Stripe Connect pour recevoir les paiements.
3.3. Les virements sont effectués selon le calendrier défini dans les paramètres de payout.

4. PROPRIÉTÉ INTELLECTUELLE
4.1. Le Vendeur conserve la propriété de ses recettes et photos.
4.2. En publiant du contenu sur la Plateforme, le Vendeur accorde à Cuisinous une licence non exclusive d'utilisation à des fins promotionnelles.

5. CONFIDENTIALITÉ
Les données personnelles des clients sont traitées conformément à la Politique de confidentialité de Cuisinous, accessible depuis l'application.

6. RÉSILIATION
6.1. Cuisinous se réserve le droit de suspendre ou résilier un compte vendeur en cas de violation des présentes conditions.
6.2. Le Vendeur peut clôturer son compte à tout moment depuis les paramètres.

7. LIMITATION DE RESPONSABILITÉ
La Plateforme ne peut être tenue responsable des litiges entre Vendeurs et Acheteurs résultant de la qualité des produits ou des délais de livraison. Ces responsabilités incombent exclusivement au Vendeur.

8. DROIT APPLICABLE
Le présent accord est régi par le droit canadien (province de Québec). Tout litige sera soumis aux tribunaux compétents de Montréal.

En cochant la case et en apposant votre nom ci-dessous, vous confirmez avoir lu, compris et accepté l'intégralité du présent accord de vendeur Cuisinous.
`;

const VendorContractPage: React.FC = () => {
  const navigate = useNavigate();
  const scrollRef = useRef<HTMLDivElement>(null);
  const [scrolledToBottom, setScrolledToBottom] = useState(false);
  const [accepted, setAccepted] = useState(false);
  const [signature, setSignature] = useState("");
  const [loading, setLoading] = useState(false);

  const handleScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    if (el.scrollHeight - el.scrollTop <= el.clientHeight + 10) {
      setScrolledToBottom(true);
    }
  };

  const canSubmit = scrolledToBottom && accepted && signature.trim().length >= 2 && !loading;

  const handleSubmit = async () => {
    if (!canSubmit) return;
    setLoading(true);
    try {
      await API.post("/vendor/sign-contract");
      // Update localStorage so VendorContractGuard passes immediately
      const stored = localStorage.getItem("user");
      if (stored) {
        const parsed = JSON.parse(stored);
        localStorage.setItem("user", JSON.stringify({ ...parsed, hasSignedVendorContract: true }));
      }
      message.success("Accord signé avec succès !");
      navigate("/dishes");
    } catch (err: any) {
      if (err?.response?.status === 200 || err?.response?.status === 409) {
        // Already accepted — just navigate
        navigate("/dishes");
      } else {
        message.error("Erreur lors de la signature. Veuillez réessayer.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: "100vh", background: "#f9fafb", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <header style={{ background: "#fff", borderBottom: "1px solid #f3f4f6", padding: "0 24px", height: 64, display: "flex", alignItems: "center", gap: 12, boxShadow: "0 1px 3px rgba(0,0,0,0.06)", position: "sticky", top: 0, zIndex: 50 }}>
        <img src={logo} alt="Cuisinous" style={{ width: 36, height: 36 }} />
        <div>
          <div style={{ fontWeight: 700, fontSize: "1rem", color: "#111827" }}>Cuisinous</div>
          <div style={{ fontSize: 11, color: "#9ca3af" }}>Accord de vendeur</div>
        </div>
      </header>

      <div style={{ maxWidth: 720, margin: "40px auto", padding: "0 24px", width: "100%" }}>

        {/* Progress steps */}
        <div style={{ display: "flex", alignItems: "center", gap: 0, marginBottom: 32 }}>
          {[
            { n: 1, label: "Contrat", active: true },
            { n: 2, label: "Tableau de bord", active: false },
          ].map((step, i) => (
            <React.Fragment key={step.n}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <div style={{
                  width: 32, height: 32, borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center",
                  background: step.active ? "#F97316" : "#e5e7eb",
                  color: step.active ? "#fff" : "#9ca3af",
                  fontWeight: 700, fontSize: 14,
                }}>
                  {step.n}
                </div>
                <span style={{ fontSize: 13, fontWeight: step.active ? 700 : 400, color: step.active ? "#111827" : "#9ca3af" }}>
                  Étape {step.n}/{2} — {step.label}
                </span>
              </div>
              {i < 1 && (
                <div style={{ flex: 1, height: 2, background: "#e5e7eb", margin: "0 12px" }} />
              )}
            </React.Fragment>
          ))}
        </div>

        {/* Warning banner */}
        <div style={{ background: "#fff7f0", border: "1px solid #fed7aa", borderRadius: 12, padding: "14px 20px", marginBottom: 24 }}>
          <div style={{ fontWeight: 700, color: "#92400e", fontSize: 14 }}>⚠️ Signature obligatoire</div>
          <div style={{ color: "#92400e", fontSize: 13, marginTop: 4 }}>
            Lisez l'intégralité de l'accord (faites défiler jusqu'en bas) avant de pouvoir signer.
          </div>
        </div>

        {/* Contract scroll area */}
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          style={{
            background: "#fff", border: "1px solid #e5e7eb", borderRadius: 12,
            padding: "24px 28px", maxHeight: 400, overflowY: "auto",
            fontFamily: "monospace", fontSize: 13, lineHeight: 1.75,
            color: "#374151", whiteSpace: "pre-wrap", marginBottom: 20,
            boxShadow: "inset 0 -8px 12px -8px rgba(0,0,0,0.08)",
          }}
        >
          {CONTRACT_TEXT}
        </div>

        {!scrolledToBottom && (
          <div style={{ textAlign: "center", color: "#9ca3af", fontSize: 13, marginBottom: 16 }}>
            ↓ Faites défiler jusqu'en bas pour débloquer la signature
          </div>
        )}

        {scrolledToBottom && (
          <div style={{ textAlign: "center", color: "#059669", fontSize: 13, fontWeight: 600, marginBottom: 16 }}>
            ✅ Vous avez lu l'intégralité de l'accord
          </div>
        )}

        {/* Checkbox */}
        <div style={{ background: "#fff", border: "1px solid #e5e7eb", borderRadius: 12, padding: "18px 22px", marginBottom: 16 }}>
          <label style={{
            display: "flex", alignItems: "flex-start", gap: 12,
            cursor: scrolledToBottom ? "pointer" : "not-allowed",
            opacity: scrolledToBottom ? 1 : 0.45,
          }}>
            <input
              type="checkbox"
              checked={accepted}
              disabled={!scrolledToBottom}
              onChange={e => setAccepted(e.target.checked)}
              style={{ marginTop: 3, width: 18, height: 18, accentColor: "#F97316" }}
            />
            <span style={{ fontSize: 14, color: "#374151" }}>
              J'ai lu et j'accepte l'intégralité de l'accord de vendeur Cuisinous, y compris les conditions de commission (15 % par défaut) et les obligations de qualité.
            </span>
          </label>
        </div>

        {/* Signature */}
        <div style={{ background: "#fff", border: "1px solid #e5e7eb", borderRadius: 12, padding: "18px 22px", marginBottom: 24 }}>
          <label style={{ display: "block", fontWeight: 600, fontSize: 13, color: "#374151", marginBottom: 8 }}>
            Signature électronique — votre nom complet *
          </label>
          <input
            type="text"
            placeholder="Ex : Jean Dupont"
            value={signature}
            disabled={!accepted}
            onChange={e => setSignature(e.target.value)}
            style={{
              width: "100%", padding: "10px 14px",
              border: `1px solid ${accepted ? "#d1d5db" : "#e5e7eb"}`,
              borderRadius: 8, fontSize: 16, fontFamily: "cursive",
              color: "#111827", background: accepted ? "#fff" : "#f9fafb",
              cursor: accepted ? "text" : "not-allowed", boxSizing: "border-box",
              outline: "none",
            }}
          />
          <div style={{ fontSize: 12, color: "#9ca3af", marginTop: 6 }}>
            Date : {new Date().toLocaleDateString("fr-CA")} · Signature électronique légalement contraignante
          </div>
        </div>

        {/* Submit */}
        <button
          onClick={handleSubmit}
          disabled={!canSubmit}
          style={{
            width: "100%", padding: "15px",
            background: canSubmit ? "#F97316" : "#d1d5db",
            color: "#fff", border: "none", borderRadius: 10,
            fontSize: 16, fontWeight: 700,
            cursor: canSubmit ? "pointer" : "not-allowed",
            transition: "background 0.2s",
          }}
        >
          {loading ? "Signature en cours…" : "✅ Signer et accéder à mon tableau de bord"}
        </button>
      </div>
    </div>
  );
};

export default VendorContractPage;
