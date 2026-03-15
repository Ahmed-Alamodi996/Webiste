"use client";

import { useEffect, useRef, useState, useCallback } from "react";

const TRAIL_LENGTH = 8;

export default function CustomCursor() {
  const cursorRef = useRef<HTMLDivElement>(null);
  const glowRef = useRef<HTMLDivElement>(null);
  const trailRefs = useRef<(HTMLDivElement | null)[]>([]);
  const [isHovering, setIsHovering] = useState(false);
  const isVisibleRef = useRef(false);
  const posRef = useRef({ x: 0, y: 0 });
  const glowPosRef = useRef({ x: 0, y: 0 });
  const trailPosRef = useRef(
    Array.from({ length: TRAIL_LENGTH }, () => ({ x: 0, y: 0 }))
  );
  const targetRef = useRef({ x: 0, y: 0 });

  const setVisible = useCallback((v: boolean) => {
    isVisibleRef.current = v;
    if (cursorRef.current) {
      cursorRef.current.style.opacity = v ? "1" : "0";
    }
    if (glowRef.current) {
      glowRef.current.style.opacity = v ? "1" : "0";
    }
    trailRefs.current.forEach((el) => {
      if (el) el.style.opacity = v ? "1" : "0";
    });
  }, []);

  useEffect(() => {
    if (window.matchMedia("(hover: none)").matches) return;

    const handleMouseMove = (e: MouseEvent) => {
      targetRef.current = { x: e.clientX, y: e.clientY };
      if (!isVisibleRef.current) setVisible(true);
    };

    const handleMouseEnter = () => setVisible(true);
    const handleMouseLeave = () => setVisible(false);

    const addHoverListeners = () => {
      const interactiveElements = document.querySelectorAll(
        'a, button, [role="button"], input, textarea, select, [data-cursor-hover]'
      );
      interactiveElements.forEach((el) => {
        el.addEventListener("mouseenter", () => setIsHovering(true));
        el.addEventListener("mouseleave", () => setIsHovering(false));
      });
    };

    let animationFrameId: number;
    const animate = () => {
      const lerp = 0.15;
      const glowLerp = 0.08;

      posRef.current.x += (targetRef.current.x - posRef.current.x) * lerp;
      posRef.current.y += (targetRef.current.y - posRef.current.y) * lerp;

      glowPosRef.current.x +=
        (targetRef.current.x - glowPosRef.current.x) * glowLerp;
      glowPosRef.current.y +=
        (targetRef.current.y - glowPosRef.current.y) * glowLerp;

      // Trail follows with cascading delay
      for (let i = 0; i < TRAIL_LENGTH; i++) {
        const prev = i === 0 ? posRef.current : trailPosRef.current[i - 1];
        const trailLerp = 0.12 - i * 0.012;
        trailPosRef.current[i].x +=
          (prev.x - trailPosRef.current[i].x) * trailLerp;
        trailPosRef.current[i].y +=
          (prev.y - trailPosRef.current[i].y) * trailLerp;

        const el = trailRefs.current[i];
        if (el) {
          el.style.transform = `translate3d(${trailPosRef.current[i].x}px, ${trailPosRef.current[i].y}px, 0) translate(-50%, -50%)`;
        }
      }

      if (cursorRef.current) {
        cursorRef.current.style.transform = `translate3d(${posRef.current.x}px, ${posRef.current.y}px, 0) translate(-50%, -50%)`;
      }
      if (glowRef.current) {
        glowRef.current.style.transform = `translate3d(${glowPosRef.current.x}px, ${glowPosRef.current.y}px, 0) translate(-50%, -50%)`;
      }

      animationFrameId = requestAnimationFrame(animate);
    };

    window.addEventListener("mousemove", handleMouseMove, { passive: true });
    document.addEventListener("mouseenter", handleMouseEnter);
    document.addEventListener("mouseleave", handleMouseLeave);

    addHoverListeners();
    animate();

    let mutationTimer: ReturnType<typeof setTimeout>;
    const observer = new MutationObserver(() => {
      clearTimeout(mutationTimer);
      mutationTimer = setTimeout(addHoverListeners, 200);
    });
    observer.observe(document.body, { childList: true, subtree: true });

    return () => {
      window.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("mouseenter", handleMouseEnter);
      document.removeEventListener("mouseleave", handleMouseLeave);
      cancelAnimationFrame(animationFrameId);
      clearTimeout(mutationTimer);
      observer.disconnect();
    };
  }, [setVisible]);

  return (
    <>
      {/* Glow trail dots */}
      {Array.from({ length: TRAIL_LENGTH }).map((_, i) => (
        <div
          key={i}
          ref={(el) => { trailRefs.current[i] = el; }}
          className="cursor-trail-dot"
          style={{
            opacity: 0,
            position: "fixed",
            left: 0,
            top: 0,
            width: `${4 - i * 0.3}px`,
            height: `${4 - i * 0.3}px`,
            borderRadius: "50%",
            backgroundColor: `rgba(0, 200, 150, ${0.4 - i * 0.045})`,
            boxShadow: `0 0 ${6 - i * 0.5}px rgba(0, 200, 150, ${0.3 - i * 0.035})`,
            pointerEvents: "none",
            zIndex: 99997,
            willChange: "transform",
          }}
        />
      ))}

      {/* Soft glow that follows with more lag */}
      <div
        ref={glowRef}
        className="cursor-glow"
        style={{
          opacity: 0,
          position: "fixed",
          left: 0,
          top: 0,
          width: isHovering ? "120px" : "60px",
          height: isHovering ? "120px" : "60px",
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(0,200,150,0.08) 0%, rgba(0,200,150,0.03) 40%, transparent 70%)",
          pointerEvents: "none",
          zIndex: 99996,
          willChange: "transform",
          transition: "width 0.4s ease, height 0.4s ease",
        }}
      />

      {/* Main cursor ring */}
      <div
        ref={cursorRef}
        className={`custom-cursor ${isHovering ? "hovering" : ""}`}
        style={{
          opacity: 0,
          pointerEvents: "none",
          willChange: "transform",
          left: 0,
          top: 0,
        }}
      />
    </>
  );
}
