import React, { useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import Input from "../../components/Input";
import { useNavigate } from "react-router-dom";
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

const LoginPage: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { login, googleLogin } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [staySignedIn, setStaySignedIn] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isForgotPassword, setIsForgotPassword] = useState(false);
  const [forgotPasswordEmail, setForgotPasswordEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const googlelogin = useGoogleLogin({
    onSuccess: async (codeResponse) => {
      try {
        setError(null);
        setIsLoading(true);
        await googleLogin((codeResponse as GoogleUser).access_token);
        if (staySignedIn) {
          localStorage.setItem("staySignedIn", "true");
        } else {
          localStorage.removeItem("staySignedIn");
        }
        navigate("/");
        antdMessage.success(t("login.success.googleLoggedIn"));
      } catch (err) {
        setError(t("login.errors.googleLoginFailed"));
        console.error("Google login error:", err);
      } finally {
        setIsLoading(false);
      }
    },
    onError: (error) => {
      console.error("Google Login Failed:", error);
      setError(t("login.errors.googleLoginFailed"));
    },
  });

  const handleLogin = async (e?: React.FormEvent) => {
    e?.preventDefault();
    try {
      setError(null);
      setIsLoading(true);
      await login(email, password);
      if (staySignedIn) {
        localStorage.setItem("staySignedIn", "true");
      } else {
        localStorage.removeItem("staySignedIn");
      }
      navigate("/");
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

  return (
    <div className="relative login-wrapper flex flex-col lg:flex-row justify-center min-h-screen bg-[#FFEFE0]">
      <div className="login-left flex flex-col items-center justify-center w-full lg:w-1/2 z-40 py-8 lg:py-0 px-4">
        <img
          src={logo}
          alt="Logo"
          className="w-[120px] h-[120px] lg:w-[200px] lg:h-[200px] mb-4"
        />
        <span className="text-xl lg:text-2xl font-light italic text-center">{t("login.slogan")}</span>
      </div>

      {/* Right side - login form */}
      <div className="login-right bg-[rgba(0,_0,_0,_0.1)] bg-opacity-90 w-full lg:w-1/2 flex flex-col justify-center p-4 sm:p-6 lg:p-12 z-40 shadow-lg">
        <div className="ml-auto mb-4 lg:mb-8">
          <LanguageSwitcher />
        </div>

        <div className="w-full lg:w-4/5 mx-auto max-w-md">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 mb-6 lg:mb-10 text-center">
            {isForgotPassword ? t("login.passwordRecovery") : t("login.title")}
          </h1>

          {isForgotPassword ? (
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

              {error && <p className="text-red-600 mb-4 text-center text-sm sm:text-base">{error}</p>}

              <div className="flex flex-col sm:flex-row items-center gap-3 mt-6">
                <button
                  type="submit"
                  className="w-full sm:w-auto bg-[#4A5568] text-white px-6 py-3 rounded-full hover:bg-[#2D3748] transition-colors flex-1 min-w-[160px]"
                  disabled={isLoading}
                >
                  {isLoading ? t("login.sending") : t("login.sendRecoveryLink")}
                </button>
                <button
                  type="button"
                  onClick={() => setIsForgotPassword(false)}
                  className="w-full sm:w-auto text-blue-600 underline hover:text-blue-800 text-center sm:text-left py-2"
                >
                  {t("login.backToLogin")}
                </button>
              </div>
            </form>
          ) : (
            <>
              <form onSubmit={handleLogin} onKeyDown={handleKeyPress}>
                <div className="space-y-4 sm:space-y-6">
                  <div>
                    <Input
                      label={t("login.email")}
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder={t("login.emailPlaceholder")}
                      required
                    />
                  </div>

                  <div>
                    <Input
                      label={t("login.password")}
                      type="password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder={t("login.passwordPlaceholder")}
                      required
                    />
                  </div>

                  <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
                    <label className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="staySignedIn"
                        checked={staySignedIn}
                        onChange={() => setStaySignedIn(!staySignedIn)}
                        className="rounded border-gray-300 text-[#4A5568] focus:ring-[#4A5568]"
                      />
                      <span className="text-sm sm:text-base">{t("login.staySignedIn")}</span>
                    </label>
                    <button
                      type="button"
                      onClick={() => setIsForgotPassword(true)}
                      className="text-blue-600 underline hover:text-blue-800 text-sm sm:text-base"
                    >
                      {t("login.forgotPassword")}
                    </button>
                  </div>

                  {error && <p className="text-red-600 text-center text-sm sm:text-base">{error}</p>}

                  <button
                    type="submit"
                    className="w-full bg-[#4A5568] text-white py-3 px-6 rounded-full hover:bg-[#2D3748] transition-colors"
                    disabled={isLoading}
                  >
                    {isLoading ? <Spin size="large" tip={t("login.loading")} /> : t("login.loginButton")}
                  </button>
                </div>
              </form>

              <div className="relative my-4 sm:my-6">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300"></div>
                </div>
                <div className="relative flex justify-center">
                  <span className="px-2 bg-transparent lg:bg-white text-gray-500 text-sm sm:text-base">
                    {t("login.or")}
                  </span>
                </div>
              </div>

              <button
                onClick={() => googlelogin()}
                className="w-full flex items-center justify-center gap-2 bg-white border border-gray-300 py-3 px-6 rounded-full hover:bg-gray-50 transition-colors"
                disabled={isLoading}
              >
                <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="18" height="18" viewBox="0 0 48 48">
                  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"></path><path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"></path><path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"></path><path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"></path>
                </svg>
                <span className="text-sm sm:text-base">{t("login.signInWithGoogle")}</span>
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
