export interface Location {
    latitude: number;
    longitude: number;
    street?: string;
    city?: string;
    state?: string;
    zipCode?: string;
    country?: string;
    additionalDetails?: string;
  }
  
  export interface FoodStore {
    name: string;
    description?: string;
    profileImage?: string;
    location: Location;
  }

  export interface VerificationRequest {
    documentIds: any;
    documents: any;
    id: string;
    foodStoreId: string;
    foodStoreName: string;
    status: 'pending' | 'approved' | 'rejected';
    createdAt: string;
    updatedAt: string;
    verificationDocument: {
      id: string;
      originalName: string;
      url?: string; // Optional if you need the download URL
    };
    adminComment?: string;
    processedBy?: {
      id: string;
      name: string;
      email?: string; // Optional if you need admin email
    };
    processedAt?: string;
    // Additional fields you might want to include:
    submittedAt?: string; // If different from createdAt
    adminComments?: string[]; // For tracking multiple admin comments
    verificationType?: string; // If you have different verification types
    expirationDate?: string; // If approvals have an expiration
  }