"use client";

import { useEffect, useRef, useCallback } from "react";

interface Dot {
  baseX: number;
  baseY: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
  opacity: number;
}

export default function ParticleGrid() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const mouseRef = useRef({ x: -1000, y: -1000 });
  const dotsRef = useRef<Dot[]>([]);
  const animFrameRef = useRef<number>(0);
  const isVisibleRef = useRef(true);

  const initDots = useCallback((width: number, height: number) => {
    const spacing = 50;
    const cols = Math.ceil(width / spacing) + 1;
    const rows = Math.ceil(height / spacing) + 1;
    const dots: Dot[] = [];

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        dots.push({
          baseX: col * spacing,
          baseY: row * spacing,
          x: col * spacing,
          y: row * spacing,
          vx: 0,
          vy: 0,
          opacity: 0.15 + Math.random() * 0.1,
        });
      }
    }
    dotsRef.current = dots;
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = Math.min(window.devicePixelRatio || 1, 2);

    const resize = () => {
      const rect = canvas.getBoundingClientRect();
      canvas.width = rect.width * dpr;
      canvas.height = rect.height * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      initDots(rect.width, rect.height);
    };

    resize();
    window.addEventListener("resize", resize);

    // Pause animation when not in viewport
    const observer = new IntersectionObserver(
      ([entry]) => {
        isVisibleRef.current = entry.isIntersecting;
      },
      { threshold: 0 }
    );
    observer.observe(canvas);

    const handleMouseMove = (e: MouseEvent) => {
      const rect = canvas.getBoundingClientRect();
      mouseRef.current = {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top,
      };
    };

    const handleMouseLeave = () => {
      mouseRef.current = { x: -1000, y: -1000 };
    };

    canvas.addEventListener("mousemove", handleMouseMove, { passive: true });
    canvas.addEventListener("mouseleave", handleMouseLeave);

    // Read particle color from CSS variable
    const getParticleColor = () => {
      const style = getComputedStyle(document.documentElement);
      return style.getPropertyValue("--particle-color").trim() || "0, 200, 150";
    };

    const animate = () => {
      animFrameRef.current = requestAnimationFrame(animate);

      // Skip rendering when off-screen
      if (!isVisibleRef.current) return;

      const rect = canvas.getBoundingClientRect();
      ctx.clearRect(0, 0, rect.width, rect.height);

      const mouse = mouseRef.current;
      const interactionRadius = 120;
      const pushStrength = 30;
      const particleColor = getParticleColor();

      for (const dot of dotsRef.current) {
        const dx = mouse.x - dot.baseX;
        const dy = mouse.y - dot.baseY;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < interactionRadius) {
          const force = (1 - dist / interactionRadius) * pushStrength;
          const angle = Math.atan2(dy, dx);
          dot.vx += -Math.cos(angle) * force * 0.02;
          dot.vy += -Math.sin(angle) * force * 0.02;
        }

        dot.vx += (dot.baseX - dot.x) * 0.04;
        dot.vy += (dot.baseY - dot.y) * 0.04;
        dot.vx *= 0.88;
        dot.vy *= 0.88;
        dot.x += dot.vx;
        dot.y += dot.vy;

        const distFromMouse = Math.sqrt(
          (mouse.x - dot.x) ** 2 + (mouse.y - dot.y) ** 2
        );
        const glow =
          distFromMouse < interactionRadius
            ? (1 - distFromMouse / interactionRadius) * 0.6
            : 0;

        const radius = 1.2 + glow * 1.5;
        const opacity = dot.opacity + glow;

        ctx.beginPath();
        ctx.arc(dot.x, dot.y, radius, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${particleColor}, ${opacity})`;
        ctx.fill();

        // Only draw connections when mouse is near
        if (glow > 0.05) {
          for (const other of dotsRef.current) {
            const odx = dot.x - other.x;
            const ody = dot.y - other.y;
            const oDist = odx * odx + ody * ody;
            if (oDist > 0 && oDist < 3600) {
              const otherDist =
                (mouse.x - other.x) ** 2 + (mouse.y - other.y) ** 2;
              if (otherDist < interactionRadius * interactionRadius) {
                const lineOpacity =
                  (1 - Math.sqrt(oDist) / 60) * glow * 0.3;
                ctx.beginPath();
                ctx.moveTo(dot.x, dot.y);
                ctx.lineTo(other.x, other.y);
                ctx.strokeStyle = `rgba(${particleColor}, ${lineOpacity})`;
                ctx.lineWidth = 0.5;
                ctx.stroke();
              }
            }
          }
        }
      }
    };

    animate();

    return () => {
      window.removeEventListener("resize", resize);
      canvas.removeEventListener("mousemove", handleMouseMove);
      canvas.removeEventListener("mouseleave", handleMouseLeave);
      cancelAnimationFrame(animFrameRef.current);
      observer.disconnect();
    };
  }, [initDots]);

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full"
      style={{ opacity: 0.6 }}
    />
  );
}
