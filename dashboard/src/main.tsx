import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { AuthProvider } from './contexts/AuthContext.tsx'
import { SettingsProvider } from './contexts/SettingsContext.tsx'
import { NotificationProvider } from './contexts/NotificationContext.tsx'
import './i18n';
import 'ag-grid-community/styles/ag-grid.css'; // Core styles
import 'ag-grid-community/styles/ag-theme-alpine.css'; // Theme styles
import { GoogleOAuthProvider } from "@react-oauth/google";
import { GOOGLE_CLIENT_ID } from "./config/apiConfig";
createRoot(document.getElementById('root')!).render(
  <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
  <AuthProvider>
    <SettingsProvider>
      {/* NotificationProvider must be inside AuthProvider (needs useAuth) */}
      <NotificationProvider>
        <StrictMode>
          <App />
        </StrictMode>
      </NotificationProvider>
    </SettingsProvider>
  </AuthProvider>
  </GoogleOAuthProvider>
,
)
