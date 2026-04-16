import API from './httpClient';

export const getVerificationRequests = async (
  page: number = 1,
  limit: number = 10,
  status?: string,
  foodStoreId?: string
) => {
  try {
    const response = await API.get('/admin/verification-requests', {
      params: {
        page,
        limit,
        status,
        foodStoreId
      }
    });
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const approveVerificationRequest = async (id: string, note?: string) => {
  try {
    const response = await API.post(
      `/admin/verification-requests/${id}/approve`,
      { note }
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const rejectVerificationRequest = async (id: string, note: string) => {
  try {
    const response = await API.post(
      `/admin/verification-requests/${id}/reject`,
      { note }
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const downloadVerificationDocument = async (requestId: string, mediaId: string) => {
  try {
    const response = await API.get(
      `/admin/verification-requests/${requestId}/documents/${mediaId}`,
      {
        responseType: 'blob',
      }
    );
    return response;
  } catch (error) {
    throw error;
  }
};

export const adminVerificationService = {
  getVerificationRequests,
  approveVerificationRequest,
  rejectVerificationRequest,
  downloadVerificationDocument,
};