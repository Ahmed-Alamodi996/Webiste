"use client";

import { motion } from "framer-motion";
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";

const SECTION_ACCENTS = [
  "#00C896",
  "#00C896",
  "#2563EB",
  "#7C3AED",
  "#F59E0B",
  "#EC4899",
  "#00C896",
];

export default function SlideIndicator() {
  const { currentSlide, totalSlides, goToSlide } = useSlide();
  const { t, isRTL } = useLanguage();

  const accentColor = SECTION_ACCENTS[currentSlide] || "#00C896";

  return (
    <div
      className={`fixed top-1/2 -translate-y-1/2 z-[101] hidden md:flex flex-col gap-3 ${
        isRTL ? "left-6 items-start" : "right-6 items-end"
      }`}
    >
      {Array.from({ length: totalSlides }).map((_, i) => (
        <button
          key={i}
          onClick={() => goToSlide(i)}
          data-cursor-hover
          className={`group flex items-center gap-3 py-2 min-h-[44px] ${isRTL ? "flex-row-reverse" : ""}`}
          aria-label={`Go to ${t.slides.names[i]}`}
        >
          {/* Label on hover */}
          <span
            className="text-xs opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap pointer-events-none"
            style={{ color: "var(--text-secondary)" }}
          >
            {t.slides.names[i]}
          </span>

          {/* Dot with spring overshoot */}
          <div className="relative flex items-center justify-center w-4 h-4">
            {currentSlide === i && (
              <motion.div
                layoutId="slide-dot-active"
                className="absolute rounded-full"
                style={{ backgroundColor: accentColor + "30" }}
                initial={false}
                animate={{ width: 16, height: 16 }}
                transition={{
                  type: "spring",
                  stiffness: 400,
                  damping: 15,
                  mass: 0.8,
                }}
              />
            )}
            <motion.div
              className="rounded-full"
              animate={{
                width: currentSlide === i ? 8 : 4,
                height: currentSlide === i ? 8 : 4,
                backgroundColor: currentSlide === i ? accentColor : "rgba(156, 163, 175, 0.4)",
              }}
              transition={{
                type: "spring",
                stiffness: 500,
                damping: 18,
                mass: 0.5,
              }}
            />
          </div>
        </button>
      ))}
    </div>
  );
}
