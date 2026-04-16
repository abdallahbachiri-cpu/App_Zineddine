import axios, { AxiosError, AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { API_BASE_URL } from "../config/apiConfig";

interface TokenResponse {
  accessToken: string;
  refreshToken: string;
}

interface QueuedRequest {
  resolve: (value: string) => void;
  reject: (reason?: any) => void;
}

class ApiClient {
  private instance: AxiosInstance;
  private isRefreshing = false;
  private failedRequestsQueue: QueuedRequest[] = [];

  constructor() {
    this.instance = axios.create({
      baseURL: `${API_BASE_URL}/api`,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
    this.setupStorageListener();
  }

  private getAccessToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getRefreshToken(): string | null {
    return localStorage.getItem('refreshToken');
  }

  private setTokens(accessToken: string, refreshToken: string): void {
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
  }

  private clearTokens(): void {
    localStorage.removeItem('user');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }

  private processQueue(error: AxiosError | null, token: string | null = null): void {
    this.failedRequestsQueue.forEach(prom => {
      if (error) {
        prom.reject(error);
      } else if (token) {
        prom.resolve(token);
      }
    });
    this.failedRequestsQueue = [];
  }

  private setupInterceptors(): void {
    // Request interceptor
    this.instance.interceptors.request.use(
      (config) => {
        const token = this.getAccessToken();
        if (token && config.headers) {
          config.headers['Authorization'] = `Bearer ${token}`;
        }
        return config;
      },
      (error: AxiosError) => Promise.reject(error)
    );

    // Response interceptor
    this.instance.interceptors.response.use(
      (response: AxiosResponse) => response,
      async (error: AxiosError) => {
        const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };
        
        if (error.response?.status === 401 && !originalRequest._retry) {
          if (this.isRefreshing) {
            return new Promise<string>((resolve, reject) => {
              this.failedRequestsQueue.push({ resolve, reject });
            }).then(token => {
              if (originalRequest.headers) {
                originalRequest.headers['Authorization'] = `Bearer ${token}`;
              }
              return this.instance(originalRequest);
            }).catch(err => Promise.reject(err));
          }

          originalRequest._retry = true;
          this.isRefreshing = true;

          try {
            const refreshToken = this.getRefreshToken();
            if (!refreshToken) throw new Error('No refresh token available');
            
            const response = await axios.post<TokenResponse>(`${API_BASE_URL}/auth/token/refresh`, {
              refreshToken,
            });

            const { accessToken, refreshToken: newRefreshToken } = response.data;
            this.setTokens(accessToken, newRefreshToken);

            if (originalRequest.headers) {
              originalRequest.headers['Authorization'] = `Bearer ${accessToken}`;
            }
            this.processQueue(null, accessToken);
            return this.instance(originalRequest);
          } catch (refreshError) {
            this.processQueue(refreshError as AxiosError);
            this.clearTokens();
            window.location.href = '/';
            return Promise.reject(refreshError);
          } finally {
            this.isRefreshing = false;
          }
        }

        return Promise.reject(error);
      }
    );
  }

  private setupStorageListener(): void {
    window.addEventListener('storage', (event: StorageEvent) => {
      if (event.key === 'accessToken' || event.key === 'refreshToken') {
        // Handle token updates from other tabs if needed
      }
    });
  }

  public getInstance(): AxiosInstance {
    return this.instance;
  }
}

const api = new ApiClient().getInstance();
export default api;