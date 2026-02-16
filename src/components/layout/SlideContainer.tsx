"use client";

import { useEffect, useRef, type ReactNode } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useSlide } from "@/context/SlideContext";
import SlideIndicator from "@/components/ui/SlideIndicator";

interface SlideContainerProps {
  slides: ReactNode[];
}

const slideVariants = {
  enter: {
    opacity: 0,
    y: 60,
  },
  center: {
    opacity: 1,
    y: 0,
  },
  exit: {
    opacity: 0,
    y: -40,
  },
};

export default function SlideContainer({ slides }: SlideContainerProps) {
  const { currentSlide, nextSlide, prevSlide } = useSlide();
  const cooldownRef = useRef(false);

  // Wheel navigation with debounce
  useEffect(() => {
    const handleWheel = (e: WheelEvent) => {
      e.preventDefault();
      if (cooldownRef.current) return;

      const threshold = 30;
      if (Math.abs(e.deltaY) < threshold) return;

      cooldownRef.current = true;
      if (e.deltaY > 0) {
        nextSlide();
      } else {
        prevSlide();
      }
      setTimeout(() => {
        cooldownRef.current = false;
      }, 900);
    };

    window.addEventListener("wheel", handleWheel, { passive: false });
    return () => window.removeEventListener("wheel", handleWheel);
  }, [nextSlide, prevSlide]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Don't hijack keyboard when user is typing in a form
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
        case "Home":
          e.preventDefault();
          break;
        case "End":
          e.preventDefault();
          break;
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [nextSlide, prevSlide]);

  // Touch swipe navigation — improved with velocity detection
  useEffect(() => {
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

      // Allow shorter swipes if fast enough, or longer swipes at any speed
      const isValidSwipe = (Math.abs(deltaY) > 50) || (Math.abs(deltaY) > 25 && velocity > 0.3);

      if (isValidSwipe) {
        if (deltaY > 0) nextSlide();
        else prevSlide();
      }
    };

    // Prevent overscroll bounce on mobile
    const handleTouchMove = (e: TouchEvent) => {
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
  }, [nextSlide, prevSlide]);

  return (
    <div
      className="fixed inset-0 overflow-hidden"
      style={{ height: "100dvh" }}
    >
      <AnimatePresence mode="wait">
        <motion.div
          key={currentSlide}
          variants={slideVariants}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{
            duration: 0.6,
            ease: [0.19, 1, 0.22, 1],
          }}
          className="absolute inset-0 overflow-y-auto overflow-x-hidden"
        >
          {slides[currentSlide]}
        </motion.div>
      </AnimatePresence>

      <SlideIndicator />
    </div>
  );
}
