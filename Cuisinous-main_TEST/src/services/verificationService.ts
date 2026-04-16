import API from './api';

const submitVerificationRequest = async (files: File[]) => {
  const formData = new FormData();
  
  // Append each file with the key 'documents[]' to match backend expectation
  files.forEach(file => {
    formData.append('documents[]', file);
  });

  try {
    const response = await API.post(
      '/seller/food-store/verification-requests',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};

const getVerificationRequests = async () => {
  try {
    const response = await API.get('/seller/food-store/verification-requests');
    return response.data;
  } catch (error) {
    throw error;
  }
};

const downloadVerificationDocument = async (requestId: string, mediaId: string) => {
  try {
    const response = await API.get(
      `/seller/food-store/verification-requests/${requestId}/documents/${mediaId}`,
      {
        responseType: 'blob', // Important for file downloads
      }
    );
    return response;
  } catch (error) {
    throw error;
  }
};

const deleteVerificationRequest = async (requestId: string) => {
  try {
    const response = await API.delete(
      `/seller/food-store/verification-requests/${requestId}`
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const verificationService = {
  submitVerificationRequest,
  getVerificationRequests,
  downloadVerificationDocument,
  deleteVerificationRequest,
};