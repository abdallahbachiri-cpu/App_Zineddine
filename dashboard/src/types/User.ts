export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  profileImageUrl: string;
  vendorAgreementAccepted?: boolean;
  vendorAgreementAcceptedAt?: string;
}
