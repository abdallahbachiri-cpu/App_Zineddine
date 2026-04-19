import React, { useState } from "react";
import { Spin, message } from "antd";
import API from "../../services/httpClient";
import { useAuth } from "../../contexts/AuthContext";

const SUBJECTS = [
  "Problème avec une commande",
  "Problème technique",
  "Question sur mon compte",
  "Signaler un problème",
  "Autre",
];

const SupportPage: React.FC = () => {
  const { type } = useAuth();
  const [subject, setSubject] = useState(SUBJECTS[0]);
  const [body, setBody]       = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent]       = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (body.trim().length < 20) {
      message.error("Votre message doit contenir au moins 20 caractères.");
      return;
    }
    setLoading(true);
    try {
      await API.post("/support/contact", {
        subject,
        message: body,
        userType: type ?? "user",
      });
      setSent(true);
    } catch {
      message.error("Erreur lors de l'envoi. Veuillez réessayer.");
    } finally {
      setLoading(false);
    }
  };

  if (sent) {
    return (
      <div style={{ padding: 28 }}>
        <div style={{ maxWidth: 520, textAlign: "center", paddingTop: 48, margin: "0 auto" }}>
          <div style={{ fontSize: 56 }}>✅</div>
          <h2 style={{ fontWeight: 700, fontSize: "1.3rem", marginTop: 16, color: "#059669" }}>
            Message envoyé !
          </h2>
          <p style={{ color: "#6b7280", marginTop: 8 }}>
            Notre équipe vous répondra à l'adresse email enregistrée sous 24 h.
          </p>
          <button
            onClick={() => { setSent(false); setBody(""); setSubject(SUBJECTS[0]); }}
            style={{ marginTop: 24, background: "#F97316", color: "#fff", border: "none", borderRadius: 8, padding: "9px 20px", cursor: "pointer", fontWeight: 600 }}
          >
            Envoyer un autre message
          </button>
        </div>
      </div>
    );
  }

  return (
    <div style={{ padding: 28 }}>
      <h1 style={{ fontSize: "1.5rem", fontWeight: 800, color: "#111827", marginBottom: 4 }}>
        💬 Contacter le support
      </h1>
      <p style={{ color: "#6b7280", fontSize: 14, marginBottom: 24 }}>
        Notre équipe répond habituellement sous 24 h à{" "}
        <strong>info@cuisinous.ca</strong>.
      </p>

      <div style={{ maxWidth: 520 }}>
        <div style={{ background: "#fff", borderRadius: 12, padding: 24, border: "1px solid #f3f4f6", boxShadow: "0 1px 3px rgba(0,0,0,0.05)" }}>
          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 16 }}>
              <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 6 }}>Sujet *</label>
              <select
                value={subject}
                onChange={e => setSubject(e.target.value)}
                style={{ width: "100%", padding: "9px 12px", border: "1px solid #e5e7eb", borderRadius: 8, fontSize: 14, outline: "none" }}
              >
                {SUBJECTS.map(s => <option key={s}>{s}</option>)}
              </select>
            </div>

            <div style={{ marginBottom: 20 }}>
              <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 6 }}>
                Message * <span style={{ color: "#9ca3af", fontWeight: 400 }}>(min 20 caractères)</span>
              </label>
              <textarea
                value={body}
                onChange={e => setBody(e.target.value)}
                rows={6}
                placeholder="Décrivez votre problème en détail..."
                style={{ width: "100%", padding: "9px 12px", border: "1px solid #e5e7eb", borderRadius: 8, fontSize: 14, outline: "none", resize: "vertical", boxSizing: "border-box" }}
              />
              <div style={{ fontSize: 12, color: body.length < 20 ? "#ef4444" : "#9ca3af", marginTop: 4, textAlign: "right" }}>
                {body.length} caractères
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              style={{ width: "100%", background: "#F97316", color: "#fff", border: "none", borderRadius: 8, padding: "11px 20px", cursor: "pointer", fontWeight: 700, fontSize: 15, opacity: loading ? 0.7 : 1 }}
            >
              {loading ? <Spin size="small" /> : "Envoyer au support"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default SupportPage;
