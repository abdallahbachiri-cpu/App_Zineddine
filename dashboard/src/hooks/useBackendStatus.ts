import { useState, useEffect } from 'react';

interface BackendStatus {
  isOnline: boolean;
  isBackendReachable: boolean;
}

export function useBackendStatus(): BackendStatus {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [isBackendReachable, setIsBackendReachable] = useState(true);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    const handleApiNetworkError = () => setIsBackendReachable(false);
    const handleApiOnline = () => setIsBackendReachable(true);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    window.addEventListener('api:network-error', handleApiNetworkError);
    window.addEventListener('api:online', handleApiOnline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
      window.removeEventListener('api:network-error', handleApiNetworkError);
      window.removeEventListener('api:online', handleApiOnline);
    };
  }, []);

  return { isOnline, isBackendReachable };
}
