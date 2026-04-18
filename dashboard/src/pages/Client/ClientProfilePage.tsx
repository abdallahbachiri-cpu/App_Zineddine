import React, { useState } from "react";
import { message, Modal, Spin } from "antd";
import API from "../../services/httpClient";
import { useAuth } from "../../contexts/AuthContext";
import { useNavigate } from "react-router-dom";

const fieldStyle: React.CSSProperties = {
  width: "100%",
  padding: "8px 12px",
  border: "1px solid #e5e7eb",
  borderRadius: 8,
  fontSize: 14,
  outline: "none",
  boxSizing: "border-box",
};

const ClientProfilePage: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    firstName: (user as any)?.firstName ?? "",
    lastName:  (user as any)?.lastName  ?? "",
    email:     (user as any)?.email     ?? "",
    phoneNumber: (user as any)?.phoneNumber ?? "",
  });
  const [saving, setSaving] = useState(false);

  const [pwForm, setPwForm]   = useState({ current: "", next: "", confirm: "" });
  const [pwSaving, setPwSaving] = useState(false);

  const [deleteModal, setDeleteModal] = useState(false);
  const [deleteWord, setDeleteWord]   = useState("");
  const [deleting, setDeleting]       = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await API.put("/user/profile", form);
      message.success("Profil mis à jour !");
    } catch {
      message.error("Impossible de mettre à jour le profil.");
    } finally {
      setSaving(false);
    }
  };

  const handlePasswordChange = async (e: React.FormEvent) => {
    e.preventDefault();
    if (pwForm.next !== pwForm.confirm) {
      message.error("Les mots de passe ne correspondent pas.");
      return;
    }
    if (pwForm.next.length < 8) {
      message.error("Le nouveau mot de passe doit contenir au moins 8 caractères.");
      return;
    }
    setPwSaving(true);
    try {
      await API.put("/user/password", { currentPassword: pwForm.current, newPassword: pwForm.next });
      message.success("Mot de passe modifié !");
      setPwForm({ current: "", next: "", confirm: "" });
    } catch {
      message.error("Mot de passe actuel incorrect.");
    } finally {
      setPwSaving(false);
    }
  };

  const handleDelete = async () => {
    if (deleteWord !== "SUPPRIMER") {
      message.error("Veuillez saisir SUPPRIMER pour confirmer.");
      return;
    }
    setDeleting(true);
    try {
      await API.delete("/user/account");
      await logout();
      navigate("/login");
    } catch {
      message.error("Impossible de supprimer le compte.");
    } finally {
      setDeleting(false);
    }
  };

  const section = (title: string, children: React.ReactNode) => (
    <div style={{ background: "#fff", borderRadius: 12, padding: 24, border: "1px solid #f3f4f6", marginBottom: 20, boxShadow: "0 1px 3px rgba(0,0,0,0.05)" }}>
      <h2 style={{ fontSize: "1rem", fontWeight: 700, marginBottom: 16, color: "#111827" }}>{title}</h2>
      {children}
    </div>
  );

  return (
    <div style={{ maxWidth: 560 }}>
      <h1 style={{ fontSize: "1.5rem", fontWeight: 700, marginBottom: 24 }}>👤 Mon Profil</h1>

      {/* Profile info */}
      {section("Informations personnelles",
        <form onSubmit={handleSave}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 12 }}>
            <div>
              <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 4 }}>Prénom</label>
              <input style={fieldStyle} value={form.firstName} onChange={e => setForm(p => ({ ...p, firstName: e.target.value }))} />
            </div>
            <div>
              <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 4 }}>Nom</label>
              <input style={fieldStyle} value={form.lastName} onChange={e => setForm(p => ({ ...p, lastName: e.target.value }))} />
            </div>
          </div>
          <div style={{ marginBottom: 12 }}>
            <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 4 }}>Email</label>
            <input style={{ ...fieldStyle, background: "#f9fafb", color: "#6b7280" }} value={form.email} readOnly />
          </div>
          <div style={{ marginBottom: 16 }}>
            <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 4 }}>Téléphone</label>
            <input style={fieldStyle} value={form.phoneNumber} onChange={e => setForm(p => ({ ...p, phoneNumber: e.target.value }))} />
          </div>
          <button type="submit" disabled={saving} style={{ background: "#F97316", color: "#fff", border: "none", borderRadius: 8, padding: "9px 20px", cursor: "pointer", fontWeight: 600, fontSize: 14 }}>
            {saving ? <Spin size="small" /> : "Sauvegarder"}
          </button>
        </form>
      )}

      {/* Change password */}
      {section("Changer le mot de passe",
        <form onSubmit={handlePasswordChange}>
          {(["current","next","confirm"] as const).map((k) => (
            <div key={k} style={{ marginBottom: 12 }}>
              <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 4 }}>
                {k === "current" ? "Mot de passe actuel" : k === "next" ? "Nouveau mot de passe" : "Confirmer le nouveau"}
              </label>
              <input type="password" style={fieldStyle} value={pwForm[k]} onChange={e => setPwForm(p => ({ ...p, [k]: e.target.value }))} />
            </div>
          ))}
          <button type="submit" disabled={pwSaving} style={{ background: "#374151", color: "#fff", border: "none", borderRadius: 8, padding: "9px 20px", cursor: "pointer", fontWeight: 600, fontSize: 14 }}>
            {pwSaving ? <Spin size="small" /> : "Modifier le mot de passe"}
          </button>
        </form>
      )}

      {/* Danger zone */}
      <div style={{ background: "#fff", borderRadius: 12, padding: 24, border: "1px solid #fecaca", marginBottom: 20 }}>
        <h2 style={{ fontSize: "1rem", fontWeight: 700, marginBottom: 8, color: "#dc2626" }}>Zone dangereuse</h2>
        <p style={{ fontSize: 13, color: "#6b7280", marginBottom: 14 }}>La suppression de votre compte est permanente et irréversible.</p>
        <button onClick={() => setDeleteModal(true)} style={{ background: "#dc2626", color: "#fff", border: "none", borderRadius: 8, padding: "9px 20px", cursor: "pointer", fontWeight: 600, fontSize: 14 }}>
          Supprimer mon compte
        </button>
      </div>

      <Modal
        title="Supprimer mon compte"
        open={deleteModal}
        onCancel={() => { setDeleteModal(false); setDeleteWord(""); }}
        footer={null}
      >
        <p style={{ marginBottom: 12 }}>Cette action est <strong>permanente</strong>. Tapez <strong>SUPPRIMER</strong> pour confirmer.</p>
        <input style={{ ...fieldStyle, marginBottom: 16 }} value={deleteWord} onChange={e => setDeleteWord(e.target.value)} placeholder="SUPPRIMER" />
        <button onClick={handleDelete} disabled={deleting || deleteWord !== "SUPPRIMER"} style={{ background: "#dc2626", color: "#fff", border: "none", borderRadius: 8, padding: "9px 20px", cursor: "pointer", fontWeight: 600, fontSize: 14, opacity: deleteWord !== "SUPPRIMER" ? 0.5 : 1 }}>
          {deleting ? <Spin size="small" /> : "Confirmer la suppression"}
        </button>
      </Modal>
    </div>
  );
};

export default ClientProfilePage;
