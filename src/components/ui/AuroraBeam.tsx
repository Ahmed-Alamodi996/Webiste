"use client";

/**
 * AuroraBeam — uses pure CSS animations instead of Framer Motion
 * to avoid JS overhead during scroll.
 */
interface AuroraBeamProps {
  className?: string;
}

export default function AuroraBeam({ className = "" }: AuroraBeamProps) {
  return (
    <div className={`absolute inset-0 overflow-hidden pointer-events-none ${className}`}>
      <style jsx>{`
        @keyframes beam1-x {
          0% { transform: translateX(-30%); }
          100% { transform: translateX(120%); }
        }
        @keyframes beam2-x {
          0% { transform: translateX(120%); }
          100% { transform: translateX(-30%); }
        }
        @keyframes beam3 {
          0% { transform: translateX(-20%); opacity: 0; }
          25% { opacity: 0.5; }
          50% { opacity: 1; }
          75% { opacity: 0.5; }
          100% { transform: translateX(130%); opacity: 0; }
        }
      `}</style>

      {/* Beam 1 — green */}
      <div
        className="absolute top-0 left-0 w-[40%] h-full"
        style={{
          background:
            "linear-gradient(90deg, transparent 0%, rgba(0, 200, 150, 0.03) 30%, rgba(0, 200, 150, 0.06) 50%, rgba(0, 200, 150, 0.03) 70%, transparent 100%)",
          filter: "blur(40px)",
          animation: "beam1-x 8s linear infinite",
          willChange: "transform",
        }}
      />

      {/* Beam 2 — blue */}
      <div
        className="absolute top-0 left-0 w-[35%] h-full"
        style={{
          background:
            "linear-gradient(90deg, transparent 0%, rgba(37, 99, 235, 0.03) 30%, rgba(37, 99, 235, 0.05) 50%, rgba(37, 99, 235, 0.03) 70%, transparent 100%)",
          filter: "blur(50px)",
          animation: "beam2-x 10s linear infinite",
          willChange: "transform",
        }}
      />

      {/* Beam 3 — narrow accent */}
      <div
        className="absolute top-1/3 left-0 w-[2px] h-[40%]"
        style={{
          background: "linear-gradient(180deg, transparent, #00C896, transparent)",
          filter: "blur(1px)",
          boxShadow: "0 0 20px 4px rgba(0, 200, 150, 0.15)",
          animation: "beam3 6s linear infinite",
          willChange: "transform, opacity",
        }}
      />
    </div>
  );
}
