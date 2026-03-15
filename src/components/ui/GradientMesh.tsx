"use client";

import { useRef, useEffect } from "react";

interface Blob {
  x: number;
  y: number;
  vx: number;
  vy: number;
  r: number;
  color: [number, number, number];
}

/**
 * GradientMesh — animated canvas metaballs that react to cursor position.
 * Renders at 1/4 resolution with CSS blur for organic, living feel.
 */
export default function GradientMesh({ className = "" }: { className?: string }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const mouseRef = useRef({ x: -9999, y: -9999 });
  const blobsRef = useRef<Blob[]>([]);
  const rafRef = useRef(0);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d", { alpha: true });
    if (!ctx) return;

    const SCALE = 0.25;
    let parentW = 0;
    let parentH = 0;

    const resize = () => {
      const p = canvas.parentElement;
      if (!p) return;
      parentW = p.clientWidth;
      parentH = p.clientHeight;
      canvas.width = Math.floor(parentW * SCALE);
      canvas.height = Math.floor(parentH * SCALE);
      canvas.style.width = parentW + "px";
      canvas.style.height = parentH + "px";
    };

    const initBlobs = () => {
      const cw = canvas.width;
      const ch = canvas.height;
      blobsRef.current = [
        { x: cw * 0.25, y: ch * 0.3, vx: 0.15, vy: 0.1, r: cw * 0.38, color: [0, 230, 172] },
        { x: cw * 0.75, y: ch * 0.5, vx: -0.2, vy: 0.15, r: cw * 0.42, color: [59, 130, 246] },
        { x: cw * 0.5, y: ch * 0.7, vx: 0.1, vy: -0.15, r: cw * 0.32, color: [139, 92, 246] },
        { x: cw * 0.15, y: ch * 0.55, vx: -0.12, vy: -0.1, r: cw * 0.3, color: [0, 200, 150] },
        { x: cw * 0.85, y: ch * 0.25, vx: 0.13, vy: 0.18, r: cw * 0.34, color: [37, 99, 235] },
        { x: cw * 0.5, y: ch * 0.15, vx: -0.08, vy: 0.12, r: cw * 0.25, color: [245, 158, 11] },
      ];
    };

    resize();
    initBlobs();

    const onResize = () => {
      resize();
      initBlobs();
    };
    window.addEventListener("resize", onResize);

    const onMouse = (e: MouseEvent) => {
      const rect = canvas.getBoundingClientRect();
      mouseRef.current = {
        x: (e.clientX - rect.left) * SCALE,
        y: (e.clientY - rect.top) * SCALE,
      };
    };
    window.addEventListener("mousemove", onMouse, { passive: true });

    const render = () => {
      const cw = canvas.width;
      const ch = canvas.height;
      const blobs = blobsRef.current;
      const mouse = mouseRef.current;

      ctx.clearRect(0, 0, cw, ch);

      for (const b of blobs) {
        b.x += b.vx;
        b.y += b.vy;

        // Wrap around edges
        if (b.x < -b.r * 0.5) b.x = cw + b.r * 0.3;
        if (b.x > cw + b.r * 0.5) b.x = -b.r * 0.3;
        if (b.y < -b.r * 0.5) b.y = ch + b.r * 0.3;
        if (b.y > ch + b.r * 0.5) b.y = -b.r * 0.3;

        // Mouse attraction — stronger pull
        const dx = mouse.x - b.x;
        const dy = mouse.y - b.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist > 0 && dist < cw * 0.7) {
          const force = Math.max(0, (cw * 0.7 - dist) / (cw * 0.7)) * 0.015;
          b.vx += dx * force;
          b.vy += dy * force;
        }

        // Dampen velocity
        b.vx *= 0.998;
        b.vy *= 0.998;

        // Clamp velocity
        const maxV = 0.5;
        const v = Math.sqrt(b.vx * b.vx + b.vy * b.vy);
        if (v > maxV) {
          b.vx = (b.vx / v) * maxV;
          b.vy = (b.vy / v) * maxV;
        }

        // Draw radial gradient blob — more vibrant
        const grad = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r);
        grad.addColorStop(0, `rgba(${b.color[0]},${b.color[1]},${b.color[2]},0.14)`);
        grad.addColorStop(0.3, `rgba(${b.color[0]},${b.color[1]},${b.color[2]},0.08)`);
        grad.addColorStop(0.6, `rgba(${b.color[0]},${b.color[1]},${b.color[2]},0.03)`);
        grad.addColorStop(1, `rgba(${b.color[0]},${b.color[1]},${b.color[2]},0)`);
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
        ctx.fill();
      }

      rafRef.current = requestAnimationFrame(render);
    };

    rafRef.current = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(rafRef.current);
      window.removeEventListener("resize", onResize);
      window.removeEventListener("mousemove", onMouse);
    };
  }, []);

  return (
    <div className={`absolute inset-0 overflow-hidden pointer-events-none ${className}`}>
      <canvas
        ref={canvasRef}
        className="absolute inset-0"
        style={{ filter: "blur(30px)" }}
      />
    </div>
  );
}
