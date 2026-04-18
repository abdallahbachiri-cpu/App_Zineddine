import React from "react";
import { Navigate } from "react-router-dom";

interface VendorContractGuardProps {
  children: React.ReactNode;
}

const VendorContractGuard: React.FC<VendorContractGuardProps> = ({ children }) => {
  const storedUser = localStorage.getItem("user");
  const user = storedUser ? JSON.parse(storedUser) : {};

  if (!user.hasSignedVendorContract) {
    return <Navigate to="/vendor/contract" replace />;
  }

  return <>{children}</>;
};

export default VendorContractGuard;
