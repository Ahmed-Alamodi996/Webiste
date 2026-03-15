"use client";

import { useEffect, useRef, type ReactNode } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";
import SlideIndicator from "@/components/ui/SlideIndicator";

interface SlideContainerProps {
  slides: ReactNode[];
}

const SECTION_ACCENTS = [
  "#00C896", // Hero
  "#00C896", // What We Offer
  "#2563EB", // Featured Projects
  "#7C3AED", // About Us
  "#F59E0B", // Our Services
  "#EC4899", // Technology
  "#00C896", // Contact
];

const slideVariants = {
  enter: (direction: number) => ({
    opacity: 0,
    y: direction > 0 ? 40 : -40,
    scale: 0.97,
    filter: "blur(4px)",
  }),
  center: {
    opacity: 1,
    y: 0,
    scale: 1,
    filter: "blur(0px)",
  },
  exit: (direction: number) => ({
    opacity: 0,
    y: direction > 0 ? -30 : 30,
    scale: 1.02,
    filter: "blur(3px)",
  }),
};

export default function SlideContainer({ slides }: SlideContainerProps) {
  const { currentSlide, nextSlide, prevSlide, viewMode } = useSlide();
  const { t, isRTL } = useLanguage();
  const cooldownRef = useRef(false);
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  // Track direction for cinematic transitions
  const directionRef = useRef(1);
  const prevSlideRef = useRef(currentSlide);
  if (currentSlide !== prevSlideRef.current) {
    directionRef.current = currentSlide > prevSlideRef.current ? 1 : -1;
    prevSlideRef.current = currentSlide;
  }

  // ─── Slide mode event handlers ───────────────────────
  useEffect(() => {
    if (viewMode !== "slides") return;

    const handleWheel = (e: WheelEvent) => {
      e.preventDefault();
      if (cooldownRef.current) return;
      const threshold = 30;
      if (Math.abs(e.deltaY) < threshold) return;

      cooldownRef.current = true;
      if (e.deltaY > 0) nextSlide();
      else prevSlide();
      setTimeout(() => { cooldownRef.current = false; }, 900);
    };

    window.addEventListener("wheel", handleWheel, { passive: false });
    return () => window.removeEventListener("wheel", handleWheel);
  }, [nextSlide, prevSlide, viewMode]);

  useEffect(() => {
    if (viewMode !== "slides") return;

    const handleKeyDown = (e: KeyboardEvent) => {
      const tag = (e.target as HTMLElement).tagName;
      if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;

      switch (e.key) {
        case "ArrowDown":
        case "ArrowRight":
        case "PageDown":
          e.preventDefault();
          nextSlide();
          break;
        case "ArrowUp":
        case "ArrowLeft":
        case "PageUp":
          e.preventDefault();
          prevSlide();
          break;
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [nextSlide, prevSlide, viewMode]);

  useEffect(() => {
    if (viewMode !== "slides") return;

    let touchStartY = 0;
    let touchStartTime = 0;

    const handleTouchStart = (e: TouchEvent) => {
      touchStartY = e.touches[0].clientY;
      touchStartTime = Date.now();
    };

    const handleTouchEnd = (e: TouchEvent) => {
      const deltaY = touchStartY - e.changedTouches[0].clientY;
      const elapsed = Date.now() - touchStartTime;
      const velocity = Math.abs(deltaY) / elapsed;
      const isValidSwipe = Math.abs(deltaY) > 50 || (Math.abs(deltaY) > 25 && velocity > 0.3);
      if (isValidSwipe) {
        if (deltaY > 0) nextSlide();
        else prevSlide();
      }
    };

    const handleTouchMove = (e: TouchEvent) => {
      const target = e.target as HTMLElement;
      if (target.closest("input, textarea, select, [data-scrollable]")) return;
      e.preventDefault();
    };

    window.addEventListener("touchstart", handleTouchStart, { passive: true });
    window.addEventListener("touchend", handleTouchEnd, { passive: true });
    window.addEventListener("touchmove", handleTouchMove, { passive: false });
    return () => {
      window.removeEventListener("touchstart", handleTouchStart);
      window.removeEventListener("touchend", handleTouchEnd);
      window.removeEventListener("touchmove", handleTouchMove);
    };
  }, [nextSlide, prevSlide, viewMode]);

  const accentColor = SECTION_ACCENTS[currentSlide] || "#00C896";
  const slideName = t.slides.names[currentSlide] || "";

  // ─── Scroll mode ─────────────────────────────────────
  if (viewMode === "scroll") {
    return (
      <div
        ref={scrollContainerRef}
        className="h-screen overflow-y-auto overflow-x-hidden scroll-smooth"
        style={{ scrollSnapType: "y mandatory" }}
      >
        {slides.map((slide, i) => (
          <div
            key={i}
            className="min-h-screen min-h-[100dvh] w-full"
            style={{ scrollSnapAlign: "start" }}
          >
            {slide}
          </div>
        ))}
      </div>
    );
  }

  // ─── Slide mode (default) ────────────────────────────
  return (
    <div
      className="fixed inset-0 overflow-hidden"
      style={{ height: "100dvh" }}
    >
      {/* Section accent color cross-fade line */}
      <motion.div
        className="absolute top-0 left-0 right-0 h-[2px] z-[102]"
        animate={{
          background: `linear-gradient(90deg, transparent, ${accentColor}, transparent)`,
        }}
        transition={{ duration: 0.6, ease: "easeInOut" }}
      />

      {/* Floating section label */}
      <div className={`fixed bottom-8 z-[102] ${isRTL ? "right-6" : "left-6"}`}>
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSlide}
            initial={{ opacity: 0, y: 12, filter: "blur(4px)" }}
            animate={{ opacity: 0.4, y: 0, filter: "blur(0px)" }}
            exit={{ opacity: 0, y: -12, filter: "blur(4px)" }}
            transition={{ duration: 0.4, ease: [0.19, 1, 0.22, 1] }}
            className="flex items-center gap-3"
          >
            <motion.div
              className="w-2 h-2 rounded-full"
              animate={{ backgroundColor: accentColor }}
              transition={{ duration: 0.4 }}
            />
            <span
              className="text-xs font-mono uppercase tracking-[0.2em]"
              style={{ color: "var(--text-muted)" }}
            >
              {slideName}
            </span>
          </motion.div>
        </AnimatePresence>
      </div>

      <AnimatePresence mode="wait" custom={directionRef.current}>
        <motion.div
          key={currentSlide}
          custom={directionRef.current}
          variants={slideVariants}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{
            duration: 0.55,
            ease: [0.25, 0.46, 0.45, 0.94],
            filter: { duration: 0.4 },
          }}
          className="absolute inset-0 overflow-y-auto overflow-x-hidden"
          style={{ willChange: "transform, opacity, filter" }}
        >
          {slides[currentSlide]}
        </motion.div>
      </AnimatePresence>

      <SlideIndicator />
    </div>
  );
}
