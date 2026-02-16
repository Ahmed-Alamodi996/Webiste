"use client";

import { motion } from "framer-motion";
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";

export default function SlideIndicator() {
  const { currentSlide, totalSlides, goToSlide } = useSlide();
  const { t, isRTL } = useLanguage();

  return (
    <div
      className={`fixed top-1/2 -translate-y-1/2 z-[101] flex flex-col gap-3 ${
        isRTL ? "left-6 items-start" : "right-6 items-end"
      }`}
    >
      {Array.from({ length: totalSlides }).map((_, i) => (
        <button
          key={i}
          onClick={() => goToSlide(i)}
          data-cursor-hover
          className={`group flex items-center gap-3 py-1 ${isRTL ? "flex-row-reverse" : ""}`}
          aria-label={`Go to ${t.slides.names[i]}`}
        >
          {/* Label on hover */}
          <span
            className="text-xs opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap pointer-events-none"
            style={{ color: "var(--text-secondary)" }}
          >
            {t.slides.names[i]}
          </span>

          {/* Dot */}
          <div className="relative flex items-center justify-center w-3 h-3">
            {currentSlide === i && (
              <motion.div
                layoutId="slide-dot-active"
                className="absolute inset-0 rounded-full bg-brand-green/20"
                transition={{ type: "spring", stiffness: 300, damping: 25 }}
              />
            )}
            <motion.div
              className="rounded-full transition-colors duration-300"
              animate={{
                width: currentSlide === i ? 8 : 4,
                height: currentSlide === i ? 8 : 4,
                backgroundColor: currentSlide === i ? "#00C896" : "rgba(156, 163, 175, 0.4)",
              }}
              transition={{ duration: 0.3 }}
            />
          </div>
        </button>
      ))}
    </div>
  );
}
