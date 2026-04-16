import { useBackendStatus } from '../hooks/useBackendStatus';

export default function OfflineBanner() {
  const { isOnline, isBackendReachable } = useBackendStatus();

  if (isOnline && isBackendReachable) return null;

  const message = !isOnline
    ? '📶 Connexion perdue — Vérifiez votre connexion internet'
    : '⚠️ Backend hors ligne — Les données peuvent être indisponibles';

  const bgColor = !isOnline ? 'bg-red-600' : 'bg-orange-500';

  return (
    <div
      className={`fixed top-0 left-0 right-0 z-50 ${bgColor} text-white text-sm font-medium text-center py-2 px-4 shadow-md`}
      role="alert"
    >
      {message}
    </div>
  );
}
