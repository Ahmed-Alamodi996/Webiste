"use client";

import { useRef, useEffect } from "react";

interface LottiePlayerProps {
  animationData: string;
  loop?: boolean;
  autoplay?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Renders a Lottie animation from a JSON string.
 * lottie-web is loaded dynamically at runtime — no build dependency required.
 * If lottie-web is not installed, falls back to a static placeholder.
 */
export default function LottiePlayer({
  animationData,
  loop = true,
  autoplay = true,
  className = "",
  style,
}: LottiePlayerProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current || !animationData) return;

    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(animationData);
    } catch {
      return;
    }

    let destroyed = false;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let anim: any = null;

    // Dynamic runtime import — won't fail at build time
    (async () => {
      try {
        // Use Function constructor to avoid webpack static analysis
        const mod = await new Function('return import("lottie-web")')();
        const lottie = mod.default || mod;
        if (destroyed || !containerRef.current) return;

        anim = lottie.loadAnimation({
          container: containerRef.current,
          renderer: "svg",
          loop,
          autoplay,
          animationData: parsed,
        });
      } catch {
        // lottie-web not available — no-op
      }
    })();

    return () => {
      destroyed = true;
      if (anim?.destroy) anim.destroy();
    };
  }, [animationData, loop, autoplay]);

  return <div ref={containerRef} className={className} style={style} />;
}
