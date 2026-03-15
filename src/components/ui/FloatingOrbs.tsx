"use client";

/**
 * FloatingOrbs — uses pure CSS animations instead of Framer Motion
 * to avoid JS overhead during scroll. GPU-composited via will-change.
 */
export default function FloatingOrbs() {
  return (
    <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
      <style jsx>{`
        @keyframes orb1 {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          25% { transform: translate3d(100px, -80px, 0) scale(1.1); }
          50% { transform: translate3d(-50px, 60px, 0) scale(0.95); }
          75% { transform: translate3d(80px, -40px, 0) scale(1.05); }
        }
        @keyframes orb2 {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          25% { transform: translate3d(-120px, 60px, 0) scale(0.9); }
          50% { transform: translate3d(60px, -100px, 0) scale(1.15); }
          75% { transform: translate3d(-30px, 40px, 0) scale(0.95); }
        }
        @keyframes orb3 {
          0%, 100% { transform: translate3d(0, 0, 0); }
          25% { transform: translate3d(60px, -60px, 0); }
          50% { transform: translate3d(-80px, 30px, 0); }
          75% { transform: translate3d(40px, -90px, 0); }
        }
      `}</style>

      {/* Large ambient orb — green */}
      <div
        className="absolute top-[20%] left-[10%] w-[300px] sm:w-[600px] h-[300px] sm:h-[600px] rounded-full opacity-[0.06]"
        style={{
          background: "radial-gradient(circle, #00C896 0%, #00E6AC 30%, transparent 70%)",
          filter: "blur(90px)",
          animation: "orb1 25s ease-in-out infinite",
          willChange: "transform",
        }}
      />

      {/* Medium orb — blue */}
      <div
        className="absolute top-[50%] right-[5%] w-[250px] sm:w-[500px] h-[250px] sm:h-[500px] rounded-full opacity-[0.05]"
        style={{
          background: "radial-gradient(circle, #2563EB 0%, #3B82F6 30%, transparent 70%)",
          filter: "blur(90px)",
          animation: "orb2 30s ease-in-out infinite",
          willChange: "transform",
        }}
      />

      {/* Small accent orb — purple */}
      <div
        className="absolute top-[75%] left-[40%] w-[200px] sm:w-[400px] h-[200px] sm:h-[400px] rounded-full opacity-[0.04]"
        style={{
          background: "radial-gradient(circle, #7C3AED 0%, #A855F7 30%, transparent 70%)",
          filter: "blur(70px)",
          animation: "orb3 20s ease-in-out infinite",
          willChange: "transform",
        }}
      />

      {/* Extra warm orb — subtle amber */}
      <div
        className="absolute top-[30%] right-[30%] w-[180px] sm:w-[350px] h-[180px] sm:h-[350px] rounded-full opacity-[0.025]"
        style={{
          background: "radial-gradient(circle, #F59E0B 0%, transparent 70%)",
          filter: "blur(80px)",
          animation: "orb1 35s ease-in-out infinite reverse",
          willChange: "transform",
        }}
      />
    </div>
  );
}
