import React, { useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import Input from "../../components/Input";
import { useNavigate, Link } from "react-router-dom";
import LanguageSwitcher from "../../components/LanguageSwitcher";
import logo from "../../assets/logo.svg";
import { useGoogleLogin } from "@react-oauth/google";
import "./Login.css";
import { Spin, message as antdMessage } from "antd";
import { API_BASE_URL } from "../../config/apiConfig";
import axios from "axios";
import { useTranslation } from "react-i18next";

interface GoogleUser {
  access_token: string;
}

// ─── Divider ──────────────────────────────────────────────────────────────────
function Divider({ label }: { label?: string }) {
  return (
    <div className="relative my-4">
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-gray-300" />
      </div>
      {label && (
        <div className="relative flex justify-center">
          <span className="px-3 bg-white/60 text-gray-500 text-sm rounded-full">
            {label}
          </span>
        </div>
      )}
    </div>
  );
}

// ─── Apple SVG icon ───────────────────────────────────────────────────────────
function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 814 1000" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
      <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76 0-103.7 40.8-165.9 40.8s-105-37.5-167.5-121.5c-62.5-84-107.3-215.9-107.3-343.8 0-191.9 125.7-291.9 249.7-291.9 65.7 0 120.4 43.2 161.5 43.2 39.5 0 101.1-46.3 176.3-46.3 28.5 0 130.9 2.6 198.3 99.2zm-234-181.5c31.1-36.9 53.1-88.1 53.1-139.3 0-7.1-.6-14.3-1.9-20.1-50.6 1.9-110.8 33.7-147.1 75.8-28.5 32.4-55.1 83.6-55.1 135.5 0 7.8 1.3 15.6 1.9 18.1 3.2.6 8.4 1.3 13.6 1.3 45.4 0 102.5-30.4 135.5-71.3z" />
    </svg>
  );
}

// ─── Main component ────────────────────────────────────────────────────────────
const LoginPage: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { login, googleLogin } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [staySignedIn, setStaySignedIn] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isForgotPassword, setIsForgotPassword] = useState(false);
  const [forgotPasswordEmail, setForgotPasswordEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  /** Navigate to the right page based on user type after login. */
  const navigateAfterLogin = (userType: string) => {
    switch (userType) {
      case "admin":   navigate("/");                break;
      case "support": navigate("/support-dashboard"); break;
      case "seller":  navigate("/dishes");           break; // VendorContractGuard handles the contract check
      case "buyer":   navigate("/client/orders");    break;
      default:        navigate("/");
    }
  };

  const googlelogin = useGoogleLogin({
    onSuccess: async (codeResponse) => {
      try {
        setError(null);
        setIsLoading(true);
        const data = await googleLogin((codeResponse as GoogleUser).access_token);
        if (staySignedIn) {
          localStorage.setItem("staySignedIn", "true");
        } else {
          localStorage.removeItem("staySignedIn");
        }
        const userType = (data as any)?.user?.type || (data as any)?.type || "admin";
        navigateAfterLogin(userType);
        antdMessage.success(t("login.success.googleLoggedIn"));
      } catch (err) {
        setError(t("login.errors.googleLoginFailed"));
        console.error("Google login error:", err);
      } finally {
        setIsLoading(false);
      }
    },
    onError: (err) => {
      console.error("Google Login Failed:", err);
      setError(t("login.errors.googleLoginFailed"));
    },
  });

  const handleLogin = async (e?: React.FormEvent) => {
    e?.preventDefault();
    try {
      setError(null);
      setIsLoading(true);
      const data = await login(email, password);
      if (staySignedIn) {
        localStorage.setItem("staySignedIn", "true");
      } else {
        localStorage.removeItem("staySignedIn");
      }
      const userType = (data as any)?.user?.type || "admin";
      navigateAfterLogin(userType);
      antdMessage.success(t("login.success.loggedIn"));
    } catch (err) {
      setError(t("login.errors.invalidCredentials"));
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasswordRecovery = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!forgotPasswordEmail.trim()) {
      setError(t("login.errors.enterValidEmail"));
      return;
    }
    try {
      setIsLoading(true);
      setError(null);
      const response = await axios.post(
        `${API_BASE_URL}/api/user/password-reset/request`,
        { email: forgotPasswordEmail },
      );
      if (!response.data) {
        const errorData = await response.data;
        throw new Error(errorData.error || t("login.errors.resetLinkFailed"));
      }
      antdMessage.success(t("login.success.resetLinkSent"));
      setIsForgotPassword(false);
    } catch (err) {
      console.error("Full error:", err);
      setError(err instanceof Error ? err.message : t("login.errors.resetLinkFailed"));
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !isForgotPassword) {
      handleLogin();
    } else if (e.key === "Enter" && isForgotPassword) {
      handlePasswordRecovery(e as unknown as React.FormEvent);
    }
  };

  const handleAppleLogin = () => {
    antdMessage.info("Connexion Apple disponible sur l'application mobile", 4);
  };

  return (
    <div className="relative login-wrapper flex flex-col lg:flex-row justify-center min-h-screen bg-[#FFEFE0]">
      {/* Left — branding */}
      <div className="login-left flex flex-col items-center justify-center w-full lg:w-1/2 z-40 py-8 lg:py-0 px-4">
        <img
          src={logo}
          alt="Logo"
          className="w-[120px] h-[120px] lg:w-[200px] lg:h-[200px] mb-4"
        />
        <span className="text-xl lg:text-2xl font-light italic text-center">
          {t("login.slogan")}
        </span>
      </div>

      {/* Right — form */}
      <div className="login-right bg-[rgba(0,_0,_0,_0.1)] bg-opacity-90 w-full lg:w-1/2 flex flex-col justify-center p-4 sm:p-6 lg:p-12 z-40 shadow-lg overflow-y-auto">
        <div className="ml-auto mb-4 lg:mb-6">
          <LanguageSwitcher />
        </div>

        <div className="w-full lg:w-4/5 mx-auto max-w-md">
          {/* ── 1. Title ── */}
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 mb-6 text-center">
            {isForgotPassword ? t("login.passwordRecovery") : t("login.title")}
          </h1>

          {isForgotPassword ? (
            /* ── Forgot password form ── */
            <form onSubmit={handlePasswordRecovery} onKeyDown={handleKeyPress}>
              <div className="mb-6">
                <Input
                  label={t("login.email")}
                  type="email"
                  value={forgotPasswordEmail}
                  onChange={(e) => setForgotPasswordEmail(e.target.value)}
                  placeholder={t("login.emailPlaceholder")}
                  required
                />
              </div>
              {error && <p className="text-red-600 mb-4 text-center text-sm">{error}</p>}
              <div className="flex flex-col sm:flex-row items-center gap-3 mt-6">
                <button
                  type="submit"
                  className="w-full sm:flex-1 py-3 px-6 rounded-full font-semibold text-white transition-colors disabled:opacity-50"
                  style={{ background: "#F97316" }}
                  disabled={isLoading}
                >
                  {isLoading ? t("login.sending") : t("login.sendRecoveryLink")}
                </button>
                <button
                  type="button"
                  onClick={() => setIsForgotPassword(false)}
                  className="text-blue-600 underline hover:text-blue-800 text-sm py-2"
                >
                  {t("login.backToLogin")}
                </button>
              </div>
            </form>
          ) : (
            <>
              {/* ── 2. Email + password form ── */}
              <form onSubmit={handleLogin} onKeyDown={handleKeyPress}>
                <div className="space-y-4">
                  {/* Email */}
                  <Input
                    label={t("login.email")}
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder={t("login.emailPlaceholder")}
                    required
                  />

                  {/* Password */}
                  <div>
                    <label className="block mb-2 font-bold">{t("login.password")}</label>
                    <div className="relative">
                      <input
                        type={showPassword ? "text" : "password"}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder={t("login.passwordPlaceholder")}
                        required
                        style={{
                          width: "100%",
                          padding: "0.5rem 2.5rem 0.5rem 0.5rem",
                          fontSize: "1rem",
                          border: "1px solid #ccc",
                          borderRadius: "4px",
                          outline: "none",
                          height: "40px",
                          boxSizing: "border-box",
                        }}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword((v) => !v)}
                        tabIndex={-1}
                        style={{
                          position: "absolute",
                          right: "0.5rem",
                          top: "50%",
                          transform: "translateY(-50%)",
                          background: "none",
                          border: "none",
                          cursor: "pointer",
                          color: "#6b7280",
                          padding: 0,
                        }}
                      >
                        {showPassword ? (
                          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                          </svg>
                        ) : (
                          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                          </svg>
                        )}
                      </button>
                    </div>
                  </div>

                  {/* ── 3. Stay signed in + forgot password ── */}
                  <div className="flex flex-col sm:flex-row items-center justify-between gap-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={staySignedIn}
                        onChange={() => setStaySignedIn(!staySignedIn)}
                        className="rounded border-gray-300"
                      />
                      <span className="text-sm">{t("login.staySignedIn")}</span>
                    </label>
                    <button
                      type="button"
                      onClick={() => setIsForgotPassword(true)}
                      className="text-blue-600 underline hover:text-blue-800 text-sm"
                    >
                      {t("login.forgotPassword")}
                    </button>
                  </div>

                  {error && <p className="text-red-600 text-center text-sm">{error}</p>}

                  {/* ── 4. Login button (orange) ── */}
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="w-full py-3 px-6 rounded-full font-semibold text-white transition-colors disabled:opacity-50"
                    style={{ background: isLoading ? "#d97706" : "#F97316" }}
                  >
                    {isLoading ? <Spin size="large" tip={t("login.loading")} /> : t("login.loginButton")}
                  </button>
                </div>
              </form>

              {/* ── 5. Séparateur "Ou" ── */}
              <Divider label={t("login.or")} />

              {/* ── 6. Apple button ── */}
              <button
                type="button"
                onClick={handleAppleLogin}
                disabled={isLoading}
                className="w-full flex items-center justify-center gap-3 py-3 px-6 rounded-full font-semibold text-white transition-opacity disabled:opacity-50 mb-3"
                style={{ background: "#000000" }}
              >
                <AppleIcon />
                <span className="text-sm sm:text-base">Se connecter avec Apple</span>
              </button>

              {/* ── 7. Google button ── */}
              <button
                type="button"
                onClick={() => googlelogin()}
                disabled={isLoading}
                className="w-full flex items-center justify-center gap-3 bg-white border border-gray-300 py-3 px-6 rounded-full hover:bg-gray-50 transition-colors disabled:opacity-50"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 48 48">
                  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z" />
                  <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z" />
                  <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z" />
                  <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z" />
                </svg>
                <span className="text-sm sm:text-base">{t("login.signInWithGoogle")}</span>
              </button>

              {/* ── 8. Séparateur ── */}
              <Divider />

              {/* ── 9 + 10. Nouveau sur Cuisinous ── */}
              <div className="text-center">
                <p className="text-sm text-gray-600 font-medium mb-3">
                  Nouveau sur Cuisinous ?
                </p>
                <div className="flex items-center justify-center gap-3">
                  <Link
                    to="/register?type=seller"
                    className="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold transition-colors hover:bg-orange-50"
                    style={{
                      border: "1.5px solid #F97316",
                      color: "#F97316",
                      textDecoration: "none",
                      fontSize: "0.875rem",
                    }}
                  >
                    🏪 Compte Vendeur
                  </Link>
                  <Link
                    to="/register?type=buyer"
                    className="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold transition-colors hover:bg-orange-50"
                    style={{
                      border: "1.5px solid #F97316",
                      color: "#F97316",
                      textDecoration: "none",
                      fontSize: "0.875rem",
                    }}
                  >
                    🛒 Compte Client
                  </Link>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
