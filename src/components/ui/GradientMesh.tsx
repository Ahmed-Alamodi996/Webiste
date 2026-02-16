"use client";

/**
 * GradientMesh — uses static CSS blurred blobs instead of animated SVG filters.
 * SVG feGaussianBlur + Framer Motion animation was a major scroll perf killer.
 */
export default function GradientMesh({ className = "" }: { className?: string }) {
  return (
    <div className={`absolute inset-0 overflow-hidden pointer-events-none ${className}`}>
      <div
        className="absolute top-[30%] left-[20%] w-[400px] h-[400px] rounded-full"
        style={{
          background: "radial-gradient(circle, rgba(0, 200, 150, 0.04) 0%, transparent 70%)",
          filter: "blur(80px)",
        }}
      />
      <div
        className="absolute top-[50%] right-[10%] w-[500px] h-[500px] rounded-full"
        style={{
          background: "radial-gradient(circle, rgba(37, 99, 235, 0.03) 0%, transparent 70%)",
          filter: "blur(80px)",
        }}
      />
      <div
        className="absolute top-[10%] left-[40%] w-[300px] h-[300px] rounded-full"
        style={{
          background: "radial-gradient(circle, rgba(124, 58, 237, 0.02) 0%, transparent 70%)",
          filter: "blur(60px)",
        }}
      />
    </div>
  );
}
