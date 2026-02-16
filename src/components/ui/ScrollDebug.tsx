"use client";

import { useEffect, useRef, useState } from "react";

export default function ScrollDebug() {
  const [visible, setVisible] = useState(true);
  const lastScrollY = useRef(0);
  const lastTime = useRef(0);
  const wheelEvents = useRef<{ delta: number; time: number; scrollY: number }[]>([]);
  const [stats, setStats] = useState({
    scrollY: 0,
    velocity: 0,
    direction: "none",
    wheelDelta: 0,
    fps: 0,
    wheelCount: 0,
  });

  useEffect(() => {
    let frameCount = 0;
    let lastFpsTime = performance.now();

    // Track wheel events
    const handleWheel = (e: WheelEvent) => {
      const now = performance.now();
      wheelEvents.current.push({
        delta: e.deltaY,
        time: now,
        scrollY: window.scrollY,
      });

      // Keep last 20
      if (wheelEvents.current.length > 20) {
        wheelEvents.current.shift();
      }

      console.log(
        `[WHEEL] deltaY=${e.deltaY.toFixed(1)} | deltaMode=${e.deltaMode} | scrollY=${window.scrollY.toFixed(1)} | time=${now.toFixed(0)}`
      );
    };

    // Track scroll position
    const handleScroll = () => {
      const now = performance.now();
      const dt = now - lastTime.current;
      const dy = window.scrollY - lastScrollY.current;
      const velocity = dt > 0 ? (dy / dt) * 1000 : 0;

      if (Math.abs(dy) > 0) {
        console.log(
          `[SCROLL] y=${window.scrollY.toFixed(1)} | dy=${dy.toFixed(1)} | velocity=${velocity.toFixed(1)}px/s | dt=${dt.toFixed(1)}ms`
        );
      }

      lastScrollY.current = window.scrollY;
      lastTime.current = now;
    };

    // FPS counter
    const measureFps = () => {
      frameCount++;
      const now = performance.now();
      if (now - lastFpsTime >= 1000) {
        const fps = frameCount;
        frameCount = 0;
        lastFpsTime = now;

        const lastWheel = wheelEvents.current[wheelEvents.current.length - 1];
        setStats({
          scrollY: Math.round(window.scrollY),
          velocity: Math.round(
            ((window.scrollY - lastScrollY.current) /
              (performance.now() - lastTime.current)) *
              1000
          ),
          direction: window.scrollY > lastScrollY.current ? "DOWN" : window.scrollY < lastScrollY.current ? "UP" : "IDLE",
          wheelDelta: lastWheel?.delta ?? 0,
          fps,
          wheelCount: wheelEvents.current.length,
        });
      }
      requestAnimationFrame(measureFps);
    };

    window.addEventListener("wheel", handleWheel, { passive: true });
    window.addEventListener("scroll", handleScroll, { passive: true });
    requestAnimationFrame(measureFps);

    console.log("[ScrollDebug] Initialized — check console for scroll/wheel logs");

    return () => {
      window.removeEventListener("wheel", handleWheel);
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  if (!visible) return null;

  return (
    <div className="fixed bottom-4 left-4 z-[99999] bg-black/90 text-green-400 font-mono text-xs p-3 rounded-lg border border-green-500/30 max-w-xs">
      <div className="flex justify-between items-center mb-2">
        <span className="text-green-500 font-bold">Scroll Debug</span>
        <button
          onClick={() => setVisible(false)}
          className="text-red-400 hover:text-red-300 text-[10px]"
        >
          [close]
        </button>
      </div>
      <div className="space-y-0.5">
        <div>scrollY: <span className="text-white">{stats.scrollY}px</span></div>
        <div>FPS: <span className={stats.fps < 50 ? "text-red-400" : "text-white"}>{stats.fps}</span></div>
        <div>direction: <span className="text-white">{stats.direction}</span></div>
        <div>last wheelΔ: <span className="text-white">{stats.wheelDelta.toFixed(1)}</span></div>
      </div>
      <div className="mt-2 text-[10px] text-green-600">Open console for detailed logs</div>
    </div>
  );
}
