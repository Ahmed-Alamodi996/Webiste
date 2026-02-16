"use client";

interface MarqueeProps {
  children: React.ReactNode;
  speed?: number;
  direction?: "left" | "right";
  className?: string;
  pauseOnHover?: boolean;
}

export default function InfiniteMarquee({
  children,
  speed = 30,
  direction = "left",
  className = "",
  pauseOnHover = true,
}: MarqueeProps) {
  const animName = direction === "left" ? "marquee-left" : "marquee-right";

  return (
    <div
      className={`overflow-hidden ${pauseOnHover ? "[&:hover_.marquee-track]:pause" : ""} ${className}`}
    >
      <style jsx>{`
        @keyframes marquee-left {
          0% { transform: translate3d(0, 0, 0); }
          100% { transform: translate3d(-50%, 0, 0); }
        }
        @keyframes marquee-right {
          0% { transform: translate3d(-50%, 0, 0); }
          100% { transform: translate3d(0, 0, 0); }
        }
      `}</style>
      <div
        className="marquee-track flex gap-6 w-fit"
        style={{
          animation: `${animName} ${speed}s linear infinite`,
          willChange: "transform",
        }}
      >
        {children}
        {children}
      </div>
    </div>
  );
}
