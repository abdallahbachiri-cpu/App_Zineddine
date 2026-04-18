import React, { useState } from "react";
import { useNavigate, Link, useSearchParams } from "react-router-dom";
import { message as antdMessage, Spin, Modal } from "antd";
import axios from "axios";
import { API_BASE_URL } from "../../config/apiConfig";
import logo from "../../assets/logo.svg";

type AccountType = "seller" | "buyer";

// ─── Legal texts ─────────────────────────────────────────────────────────────

const TERMS_TEXT = `CUISINOUS – CONDITIONS D'UTILISATION (VERSION APPLICATION MOBILE)
Dernière mise à jour : 01-01-2026

Les présentes conditions d'utilisation (« Conditions ») régissent votre accès et votre utilisation de l'application mobile Cuisinous et des services connexes (l'« Application »), exploitée par 9534-9072 Québec Inc., faisant affaire sous le nom Cuisinous (« Cuisinous », « nous », « notre »).
En créant un compte ou en utilisant l'Application, vous confirmez avoir lu, compris et accepté les présentes Conditions.

1. CE QU'EST CUISINOUS
Cuisinous est une place de marché technologique qui met en relation des Vendeurs indépendants de nourriture avec des Clients. Cuisinous ne prépare, cuisine, entrepose, inspecte, emballe, transporte ni livre de nourriture ; n'est pas un restaurant, un service de traiteur ou une entreprise alimentaire ; ne supervise ni ne contrôle les Vendeurs ou leurs cuisines ; ne garantit pas la qualité, la sécurité, la légalité ou la conformité des aliments ; n'est pas l'employeur, l'agent ou le partenaire d'un Vendeur. Toutes les transactions alimentaires ont lieu exclusivement entre le Vendeur et le Client.

2. ADMISSIBILITÉ ET COMPTES
Pour utiliser l'Application, vous devez : avoir 18 ans ou plus ; avoir la capacité légale de conclure un contrat ; fournir des informations exactes et à jour. Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toute activité effectuée à partir de votre compte.

3. VENDEURS
Les Vendeurs sont assujettis à une Convention de vendeur distincte. En cas de conflit entre les présentes Conditions et la Convention de vendeur, la Convention de vendeur prévaut.

4. ALIMENTATION ET CONFORMITÉ LÉGALE
Les Vendeurs sont seuls responsables de : respecter toutes les lois et réglementations applicables ; détenir des permis et certifications valides (y compris ceux du MAPAQ) ; la salubrité des aliments, l'hygiène, l'étiquetage, les allergènes et l'exactitude des ingrédients ; leurs produits alimentaires et méthodes de préparation. Cuisinous ne vérifie ni n'inspecte la conformité des Vendeurs.

5. COMMANDES, PAIEMENTS ET FRAIS
Les paiements sont traités par des fournisseurs tiers. Des frais de plateforme ou des commissions peuvent s'appliquer. Les frais de plateforme sont non remboursables, sauf lorsque la loi l'exige.

6. ANNULATIONS ET REMBOURSEMENTS
Les politiques d'annulation et de remboursement sont établies par les Vendeurs et la loi applicable.

7. CONTENU DES UTILISATEURS
Vous conservez la propriété de votre contenu. En publiant du contenu, vous accordez à Cuisinous une licence mondiale, non exclusive et libre de redevances.

8. UTILISATION INTERDITE
Il est interdit de : contourner l'Application pour des transactions hors plateforme ; fournir des informations fausses ; enfreindre les lois ; publier du contenu nuisible ou illégal.

9. SUSPENSION OU RÉSILIATION DU COMPTE
Cuisinous peut suspendre ou résilier des comptes, retirer des annonces, ou restreindre l'accès.

10. PROPRIÉTÉ INTELLECTUELLE
Tout le contenu de l'Application appartient à Cuisinous ou à ses concédants de licence.

11. LIMITATION DE RESPONSABILITÉ
Dans la mesure maximale permise par la loi, Cuisinous n'est pas responsable des maladies d'origine alimentaire, des actes des Vendeurs, ou de tout dommage indirect.

12. INDEMNISATION
Vous acceptez d'indemniser Cuisinous de toute réclamation découlant de votre utilisation de l'Application.

13. FORCE MAJEURE
Cuisinous n'est pas responsable des retards causés par des événements indépendants de sa volonté.

14. MODIFICATIONS DES CONDITIONS
Nous pouvons modifier ces Conditions à tout moment. La poursuite de l'utilisation constitue votre acceptation.

15. DROIT APPLICABLE
Les présentes Conditions sont régies par les lois de la province de Québec (Canada).

16. CONTACT
Courriel : info@cuisinous.ca`;

const VENDOR_AGREEMENT_TEXT = `ACCORD VENDEUR – SERVICE AGREEMENT v.1

Le présent accord entre en vigueur à la date de son acceptation électronique par le Vendeur sur la plateforme Cuisinous.

ENTRE : 9534-9072 QUÉBEC INC., société dûment constituée, dont le siège social est au 401-5131, Place Leblanc, Sainte-Catherine, Québec, J5C 1G6 (ci-après « Cuisinous »)

ET : Toute personne physique ou morale ayant créé un compte vendeur sur la plateforme Cuisinous (ci-après « le Vendeur »)

PRÉAMBULE
En acceptant électroniquement le présent accord, le Vendeur reconnaît l'avoir lu, compris et accepté inconditionnellement. Le Vendeur reconnaît que Cuisinous agit uniquement en tant que plateforme technologique de mise en relation et n'assume aucune responsabilité à l'égard des produits alimentaires offerts par le Vendeur.

1. OBJET
Cuisinous exploite une plateforme technologique facilitant les mises en relation entre Vendeurs de produits alimentaires et Clients. Cuisinous ne s'engage dans aucune activité de préparation, fabrication, traitement, stockage, inspection ou livraison d'aliments.

2. STATUT DE VENDEUR INDÉPENDANT
Le Vendeur agit en tant qu'entrepreneur indépendant. Rien dans le présent accord ne crée une relation d'emploi, d'agence, de partenariat ou de représentation entre le Vendeur et Cuisinous.

3. OBLIGATIONS DU VENDEUR
Le Vendeur est seul et entièrement responsable de : la sécurité, l'hygiène et la salubrité des aliments ; la qualité, l'étiquetage, la composition et la déclaration des allergènes des produits ; les méthodes de préparation, de stockage et de distribution ; l'obtention et le maintien de tous les permis et certifications requis, y compris ceux du MAPAQ ; la conformité à toutes les lois et réglementations applicables.

4. DÉCLARATIONS ET GARANTIES DU VENDEUR
Le Vendeur déclare et garantit : détenir tous les permis et certifications requis ; respecter toutes les lois applicables ; maintenir une assurance responsabilité civile adéquate à ses propres frais.

5. FRAIS ET INTERDICTION DE CONTOURNEMENT
Le Vendeur s'engage à payer tous les frais applicables liés à l'utilisation de la plateforme. Il est strictement interdit de contourner la plateforme.

6. CONDITIONS DE PAIEMENT
Tous les paiements sont traités par un prestataire de services de paiement tiers indépendant. Cuisinous n'est pas un établissement financier.

7. LIMITATION DE RESPONSABILITÉ
Dans toute la mesure permise par la loi, Cuisinous et ses dirigeants, administrateurs, employés et partenaires ne seront pas responsables des maladies, empoisonnements alimentaires, pertes de revenus ou réclamations découlant des produits ou activités du Vendeur.

8. INDEMNISATION
Le Vendeur s'engage à indemniser, défendre et dégager de toute responsabilité Cuisinous et ses dirigeants à l'égard de toute réclamation découlant directement ou indirectement des produits, activités ou manquements du Vendeur.

9. SUSPENSION ET RÉSILIATION
Cuisinous se réserve le droit, à sa seule discrétion, de suspendre ou résilier le compte du Vendeur à tout moment.

10. CONFIDENTIALITÉ ET PROTECTION DES DONNÉES
Le Vendeur s'engage à maintenir la confidentialité de toutes les données et à se conformer aux lois applicables sur la protection de la vie privée.

11. DISPOSITIONS GÉNÉRALES
Le présent accord est régi par les lois du Québec. Cuisinous peut modifier le présent accord à tout moment. L'utilisation continue de la plateforme constitue une acceptation.

12. ACCEPTATION ÉLECTRONIQUE
L'acceptation via « Accepter et continuer » constitue une signature électronique valide en vertu des lois québécoises.`;

// ─── Legal modal component ────────────────────────────────────────────────────
function LegalModal({
  open,
  title,
  content,
  onClose,
  onAccept,
}: {
  open: boolean;
  title: string;
  content: string;
  onClose: () => void;
  onAccept: () => void;
}) {
  return (
    <Modal
      open={open}
      title={title}
      onCancel={onClose}
      width={720}
      footer={
        <div style={{ display: "flex", gap: 10, justifyContent: "flex-end" }}>
          <button onClick={onClose} style={{ border: "1px solid #e5e7eb", background: "#fff", padding: "8px 18px", borderRadius: 8, cursor: "pointer", fontSize: 14 }}>
            Fermer
          </button>
          <button
            onClick={() => { onAccept(); onClose(); }}
            style={{ background: "#F97316", color: "#fff", border: "none", padding: "8px 18px", borderRadius: 8, cursor: "pointer", fontWeight: 600, fontSize: 14 }}
          >
            J'accepte
          </button>
        </div>
      }
    >
      <div style={{ maxHeight: 420, overflowY: "auto", padding: "4px 0", whiteSpace: "pre-wrap", fontSize: 13, lineHeight: 1.6, color: "#374151" }}>
        {content}
      </div>
    </Modal>
  );
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function PasswordStrength({ password }: { password: string }) {
  const hasLength = password.length >= 8;
  const hasUpper = /[A-Z]/.test(password);
  const hasDigit = /[0-9]/.test(password);
  const hasSpecial = /[\W]/.test(password);
  const score = [hasLength, hasUpper, hasDigit, hasSpecial].filter(Boolean).length;

  if (!password) return null;

  const label = score <= 1 ? "Faible" : score <= 3 ? "Moyen" : "Fort";
  const color = score <= 1 ? "#ef4444" : score <= 3 ? "#f97316" : "#22c55e";
  const widths = ["25%", "50%", "75%", "100%"];

  return (
    <div className="mt-1">
      <div style={{ height: 4, background: "#e5e7eb", borderRadius: 2, overflow: "hidden" }}>
        <div style={{ height: "100%", width: widths[score - 1] ?? "0%", background: color, transition: "width 0.3s" }} />
      </div>
      <p style={{ fontSize: 12, color, marginTop: 2 }}>{label}</p>
    </div>
  );
}

function EyeIcon({ visible }: { visible: boolean }) {
  return visible ? (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
    </svg>
  ) : (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
    </svg>
  );
}

const fieldStyle: React.CSSProperties = {
  width: "100%",
  padding: "0.5rem",
  fontSize: "1rem",
  border: "1px solid #ccc",
  borderRadius: "4px",
  outline: "none",
  boxSizing: "border-box",
};

// ─── Type selection step ──────────────────────────────────────────────────────

function TypeSelectionStep({ onSelect }: { onSelect: (t: AccountType) => void }) {
  const [hovered, setHovered] = useState<AccountType | null>(null);

  const cards: { type: AccountType; icon: string; title: string; description: string }[] = [
    {
      type: "seller",
      icon: "🏪",
      title: "Vendeur",
      description: "Créez votre restaurant ou boutique et proposez vos plats à la livraison.",
    },
    {
      type: "buyer",
      icon: "🛒",
      title: "Client",
      description: "Commandez des repas depuis les meilleurs restaurants près de chez vous.",
    },
  ];

  return (
    <div className="relative login-wrapper flex flex-col lg:flex-row justify-center min-h-screen bg-[#FFEFE0]">
      {/* Left branding */}
      <div className="login-left flex flex-col items-center justify-center w-full lg:w-1/2 z-40 py-8 lg:py-0 px-4">
        <img src={logo} alt="Logo" className="w-[120px] h-[120px] lg:w-[200px] lg:h-[200px] mb-4" />
        <span className="text-xl lg:text-2xl font-light italic text-center">Cuisinous — Livraison de repas</span>
      </div>

      {/* Right content */}
      <div className="login-right bg-[rgba(0,_0,_0,_0.1)] bg-opacity-90 w-full lg:w-1/2 flex flex-col justify-center p-4 sm:p-6 lg:p-12 z-40 shadow-lg">
        <div className="w-full lg:w-4/5 mx-auto max-w-md">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 mb-2 text-center">
            Quel type de compte ?
          </h1>
          <p className="text-center text-gray-500 mb-8 text-sm">
            Choisissez votre profil pour commencer
          </p>

          <div className="space-y-4">
            {cards.map(({ type, icon, title, description }) => (
              <div
                key={type}
                onMouseEnter={() => setHovered(type)}
                onMouseLeave={() => setHovered(null)}
                onClick={() => onSelect(type)}
                style={{
                  border: hovered === type ? "2px solid #F97316" : "2px solid #e5e7eb",
                  background: hovered === type ? "#fff7f0" : "#ffffff",
                  borderRadius: "12px",
                  padding: "20px 24px",
                  cursor: "pointer",
                  transition: "border-color 0.2s, background 0.2s, box-shadow 0.2s",
                  boxShadow: hovered === type ? "0 4px 16px rgba(249,115,22,0.15)" : "0 1px 4px rgba(0,0,0,0.06)",
                  display: "flex",
                  alignItems: "center",
                  gap: "16px",
                }}
              >
                <span style={{ fontSize: 48, lineHeight: 1 }}>{icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 700, fontSize: "1.1rem", color: "#1f2937", marginBottom: 4 }}>
                    {title}
                  </div>
                  <div style={{ fontSize: "0.875rem", color: "#6b7280" }}>{description}</div>
                </div>
                <div
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: "50%",
                    background: hovered === type ? "#F97316" : "#f3f4f6",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    transition: "background 0.2s",
                    flexShrink: 0,
                  }}
                >
                  <svg
                    width="16"
                    height="16"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke={hovered === type ? "#fff" : "#9ca3af"}
                    strokeWidth={2.5}
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              </div>
            ))}
          </div>

          <p className="text-center mt-8 text-sm">
            Déjà un compte ?{" "}
            <Link to="/login" className="font-semibold" style={{ color: "#F97316" }}>
              Se connecter
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

// ─── Registration form step ───────────────────────────────────────────────────

function FormStep({
  accountType,
  onBack,
}: {
  accountType: AccountType;
  onBack: () => void;
}) {
  const navigate = useNavigate();

  const isSeller = accountType === "seller";
  const badgeLabel = isSeller ? "🏪 Compte Vendeur" : "🛒 Compte Client";

  const [form, setForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
    password: "",
    confirmPassword: "",
    storeName: "",
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [acceptedTerms, setAcceptedTerms] = useState(false);
  const [acceptedVendorAgreement, setAcceptedVendorAgreement] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [termsModalOpen, setTermsModalOpen] = useState(false);
  const [vendorModalOpen, setVendorModalOpen] = useState(false);

  const validate = () => {
    const e: Record<string, string> = {};
    if (!form.firstName.trim()) e.firstName = "Le prénom est requis";
    if (!form.lastName.trim()) e.lastName = "Le nom est requis";
    if (!form.email.trim()) e.email = "L'email est requis";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) e.email = "Veuillez entrer un email valide";
    if (isSeller && !form.storeName.trim()) e.storeName = "Le nom de votre établissement est requis";
    if (!form.password) e.password = "Le mot de passe est requis";
    else if (form.password.length < 8) e.password = "Min. 8 caractères";
    else if (!/[A-Z]/.test(form.password)) e.password = "Doit contenir une majuscule";
    else if (!/[0-9]/.test(form.password)) e.password = "Doit contenir un chiffre";
    else if (!/[\W]/.test(form.password)) e.password = "Doit contenir un caractère spécial";
    if (!form.confirmPassword) e.confirmPassword = "Confirmez le mot de passe";
    else if (form.password !== form.confirmPassword) e.confirmPassword = "Les mots de passe ne correspondent pas";
    if (!acceptedTerms) e.terms = "Vous devez accepter les conditions d'utilisation";
    if (isSeller && !acceptedVendorAgreement) e.vendorAgreement = "Vous devez accepter l'accord vendeur";
    return e;
  };

  const handleChange =
    (key: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) => {
      setForm((prev) => ({ ...prev, [key]: e.target.value }));
      if (errors[key]) setErrors((prev) => { const next = { ...prev }; delete next[key]; return next; });
    };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }

    setIsLoading(true);
    try {
      await axios.post(`${API_BASE_URL}/api/auth/register`, {
        email: form.email,
        password: form.password,
        firstName: form.firstName,
        lastName: form.lastName,
        phoneNumber: form.phoneNumber || undefined,
        type: accountType,
        ...(isSeller && form.storeName ? { storeName: form.storeName } : {}),
        locale: "fr",
      });
      antdMessage.success("Compte créé ! Vérifiez votre email pour le code OTP.", 5);
      navigate("/login");
    } catch (err: any) {
      const apiErrors = err?.response?.data?.errors as string[] | undefined;
      if (apiErrors?.length) {
        antdMessage.error(apiErrors[0]);
      } else {
        antdMessage.error("Erreur lors de l'inscription. Veuillez réessayer.");
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="relative login-wrapper flex flex-col lg:flex-row justify-center min-h-screen bg-[#FFEFE0]">
      {/* Left branding */}
      <div className="login-left flex flex-col items-center justify-center w-full lg:w-1/2 z-40 py-8 lg:py-0 px-4">
        <img src={logo} alt="Logo" className="w-[120px] h-[120px] lg:w-[200px] lg:h-[200px] mb-4" />
        <span className="text-xl lg:text-2xl font-light italic text-center">Cuisinous — Livraison de repas</span>
      </div>

      {/* Right form */}
      <div className="login-right bg-[rgba(0,_0,_0,_0.1)] bg-opacity-90 w-full lg:w-1/2 flex flex-col justify-center p-4 sm:p-6 lg:p-12 z-40 shadow-lg overflow-y-auto">
        <div className="w-full lg:w-4/5 mx-auto max-w-md">
          {/* Back arrow + badge */}
          <div className="flex items-center gap-3 mb-6">
            <button
              type="button"
              onClick={onBack}
              style={{
                background: "none",
                border: "none",
                cursor: "pointer",
                padding: "4px",
                display: "flex",
                alignItems: "center",
                color: "#6b7280",
              }}
              aria-label="Retour"
            >
              <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <span
              style={{
                background: "#fff7f0",
                border: "1px solid #fed7aa",
                color: "#c2410c",
                borderRadius: "999px",
                padding: "4px 12px",
                fontSize: "0.85rem",
                fontWeight: 600,
              }}
            >
              {badgeLabel}
            </span>
          </div>

          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 mb-6 text-center">
            Créer un compte
          </h1>

          <form onSubmit={handleSubmit} noValidate>
            <div className="space-y-4">
              {/* First + Last name */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block mb-1 font-bold text-sm">Prénom *</label>
                  <input
                    style={fieldStyle}
                    type="text"
                    value={form.firstName}
                    onChange={handleChange("firstName")}
                    placeholder="Jean"
                  />
                  {errors.firstName && <p className="text-red-600 text-xs mt-1">{errors.firstName}</p>}
                </div>
                <div>
                  <label className="block mb-1 font-bold text-sm">Nom *</label>
                  <input
                    style={fieldStyle}
                    type="text"
                    value={form.lastName}
                    onChange={handleChange("lastName")}
                    placeholder="Dupont"
                  />
                  {errors.lastName && <p className="text-red-600 text-xs mt-1">{errors.lastName}</p>}
                </div>
              </div>

              {/* Email */}
              <div>
                <label className="block mb-1 font-bold text-sm">Email *</label>
                <input
                  style={fieldStyle}
                  type="email"
                  value={form.email}
                  onChange={handleChange("email")}
                  placeholder="jean.dupont@email.com"
                />
                {errors.email && <p className="text-red-600 text-xs mt-1">{errors.email}</p>}
              </div>

              {/* Phone */}
              <div>
                <label className="block mb-1 font-bold text-sm">Téléphone</label>
                <input
                  style={fieldStyle}
                  type="tel"
                  value={form.phoneNumber}
                  onChange={handleChange("phoneNumber")}
                  placeholder="+1 514 000 0000"
                />
              </div>

              {/* Store name — seller only */}
              {isSeller && (
                <div>
                  <label className="block mb-1 font-bold text-sm">
                    Nom de votre restaurant / boutique *
                  </label>
                  <input
                    style={fieldStyle}
                    type="text"
                    value={form.storeName}
                    onChange={handleChange("storeName")}
                    placeholder="Ex : Chez Marie, Burger House…"
                  />
                  {errors.storeName && (
                    <p className="text-red-600 text-xs mt-1">{errors.storeName}</p>
                  )}
                </div>
              )}

              {/* Password */}
              <div>
                <label className="block mb-1 font-bold text-sm">Mot de passe *</label>
                <div className="relative">
                  <input
                    style={{ ...fieldStyle, paddingRight: "2.5rem" }}
                    type={showPassword ? "text" : "password"}
                    value={form.password}
                    onChange={handleChange("password")}
                    placeholder="Min. 8 caractères"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    style={{ position: "absolute", right: "0.5rem", top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: "#6b7280" }}
                    tabIndex={-1}
                  >
                    <EyeIcon visible={showPassword} />
                  </button>
                </div>
                <PasswordStrength password={form.password} />
                {errors.password && <p className="text-red-600 text-xs mt-1">{errors.password}</p>}
              </div>

              {/* Confirm password */}
              <div>
                <label className="block mb-1 font-bold text-sm">Confirmer le mot de passe *</label>
                <div className="relative">
                  <input
                    style={{ ...fieldStyle, paddingRight: "2.5rem" }}
                    type={showConfirm ? "text" : "password"}
                    value={form.confirmPassword}
                    onChange={handleChange("confirmPassword")}
                    placeholder="Répétez votre mot de passe"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm((v) => !v)}
                    style={{ position: "absolute", right: "0.5rem", top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: "#6b7280" }}
                    tabIndex={-1}
                  >
                    <EyeIcon visible={showConfirm} />
                  </button>
                </div>
                {form.confirmPassword && form.password !== form.confirmPassword && (
                  <p className="text-red-600 text-xs mt-1">Les mots de passe ne correspondent pas</p>
                )}
                {form.confirmPassword && form.password === form.confirmPassword && form.confirmPassword.length > 0 && (
                  <p className="text-green-600 text-xs mt-1">✓ Mots de passe identiques</p>
                )}
                {errors.confirmPassword && <p className="text-red-600 text-xs mt-1">{errors.confirmPassword}</p>}
              </div>

              {/* Terms */}
              <label className="flex items-start gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedTerms}
                  onChange={() => setAcceptedTerms((v) => !v)}
                  className="mt-0.5 rounded border-gray-300"
                />
                <span className="text-sm">
                  J'accepte les{" "}
                  <button type="button" onClick={() => setTermsModalOpen(true)} className="underline font-medium" style={{ background: "none", border: "none", color: "#F97316", cursor: "pointer", padding: 0, fontSize: "inherit" }}>
                    conditions d'utilisation
                  </button>
                  {" "}et la{" "}
                  <button type="button" onClick={() => setTermsModalOpen(true)} className="underline font-medium" style={{ background: "none", border: "none", color: "#F97316", cursor: "pointer", padding: 0, fontSize: "inherit" }}>
                    politique de confidentialité
                  </button>
                </span>
              </label>
              {errors.terms && <p className="text-red-600 text-xs">{errors.terms}</p>}

              {/* Vendor agreement — seller only */}
              {isSeller && (
                <>
                  <label className="flex items-start gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={acceptedVendorAgreement}
                      onChange={() => setAcceptedVendorAgreement((v) => !v)}
                      className="mt-0.5 rounded border-gray-300"
                    />
                    <span className="text-sm">
                      J'accepte l'{" "}
                      <button type="button" onClick={() => setVendorModalOpen(true)} className="underline font-medium" style={{ background: "none", border: "none", color: "#F97316", cursor: "pointer", padding: 0, fontSize: "inherit" }}>
                        accord vendeur
                      </button>
                      {" "}et les responsabilités liées à la vente en ligne
                    </span>
                  </label>
                  {errors.vendorAgreement && <p className="text-red-600 text-xs">{errors.vendorAgreement}</p>}
                </>
              )}

              {/* Legal modals */}
              <LegalModal
                open={termsModalOpen}
                title="Conditions d'utilisation"
                content={TERMS_TEXT}
                onClose={() => setTermsModalOpen(false)}
                onAccept={() => setAcceptedTerms(true)}
              />
              <LegalModal
                open={vendorModalOpen}
                title="Accord Vendeur"
                content={VENDOR_AGREEMENT_TEXT}
                onClose={() => setVendorModalOpen(false)}
                onAccept={() => setAcceptedVendorAgreement(true)}
              />

              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-3 px-6 rounded-full font-semibold text-white transition-colors disabled:opacity-50"
                style={{ background: isLoading ? "#d97706" : "#F97316" }}
              >
                {isLoading ? <Spin size="small" /> : "Créer mon compte"}
              </button>
            </div>
          </form>

          <p className="text-center mt-6 text-sm">
            Déjà un compte ?{" "}
            <Link to="/login" className="font-semibold" style={{ color: "#F97316" }}>
              Se connecter
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

// ─── Main component ────────────────────────────────────────────────────────────

const RegisterPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const urlType = searchParams.get("type") as AccountType | null;

  // Pre-select type from URL param (?type=seller or ?type=buyer),
  // falling back to null (show the selection screen).
  const [accountType, setAccountType] = useState<AccountType | null>(
    urlType === "seller" || urlType === "buyer" ? urlType : null,
  );

  if (!accountType) {
    return <TypeSelectionStep onSelect={setAccountType} />;
  }

  return <FormStep accountType={accountType} onBack={() => setAccountType(null)} />;
};

export default RegisterPage;
