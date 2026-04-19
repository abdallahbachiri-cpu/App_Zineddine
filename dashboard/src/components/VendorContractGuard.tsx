import React from "react";
import { Navigate } from "react-router-dom";

interface VendorContractGuardProps {
  children: React.ReactNode;
}

const VendorContractGuard: React.FC<VendorContractGuardProps> = ({ children }) => {
  const storedUser = localStorage.getItem("user");
  const user = storedUser ? (() => { try { return JSON.parse(storedUser); } catch { return {}; } })() : {};

  const isSeller = user?.roles?.includes('ROLE_SELLER') || user?.type === 'seller';

  const userId = user?.id ?? '';
  // Per-user key (canonical) + legacy global key (backward-compat)
  const signedLocally =
    (userId && localStorage.getItem(`vendorContractSigned_${userId}`) === 'true') ||
    localStorage.getItem('vendorContractSigned') === 'true';
  const signedViaAPI = user?.hasSignedVendorContract === true;

  if (isSeller && !signedLocally && !signedViaAPI) {
    return <Navigate to="/vendor/contract" replace />;
  }

  return <>{children}</>;
};

export default VendorContractGuard;
