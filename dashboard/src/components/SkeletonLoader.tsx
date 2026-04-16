import React from 'react';

const shimmerStyle: React.CSSProperties = {
  background: 'linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%)',
  backgroundSize: '200% 100%',
  animation: 'shimmer 1.5s infinite',
  borderRadius: '6px',
};

const keyframes = `
@keyframes shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
`;

function ShimmerStyles() {
  return <style>{keyframes}</style>;
}

// 4 stat cards side by side
export function SkeletonStatCard() {
  return (
    <>
      <ShimmerStyles />
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div style={{ ...shimmerStyle, height: 12, width: '40%', marginBottom: 12 }} />
            <div style={{ ...shimmerStyle, height: 28, width: '60%', marginBottom: 8 }} />
            <div style={{ ...shimmerStyle, height: 10, width: '30%' }} />
          </div>
        ))}
      </div>
    </>
  );
}

// Table rows skeleton
export function SkeletonTableRows({ rows = 5 }: { rows?: number }) {
  return (
    <>
      <ShimmerStyles />
      <div className="space-y-2 py-2">
        {Array.from({ length: rows }).map((_, i) => (
          <div key={i} className="flex gap-4 px-4">
            <div style={{ ...shimmerStyle, height: 20, flex: 1 }} />
            <div style={{ ...shimmerStyle, height: 20, flex: 2 }} />
            <div style={{ ...shimmerStyle, height: 20, flex: 1 }} />
            <div style={{ ...shimmerStyle, height: 20, flex: 1 }} />
          </div>
        ))}
      </div>
    </>
  );
}

// Generic card block
export function SkeletonCard({ height = 128 }: { height?: number }) {
  return (
    <>
      <ShimmerStyles />
      <div
        className="bg-white rounded-xl shadow-sm border border-gray-100"
        style={{ ...shimmerStyle, height }}
      />
    </>
  );
}
