"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowUpRight, ChevronLeft, ChevronRight } from "lucide-react";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSProject } from "@/lib/cms-types";

/** Sanitize a hex color value to prevent CSS injection */
function sanitizeHexColor(color: string | undefined): string {
  if (!color) return "#888888";
  return /^#[0-9A-Fa-f]{6}$/.test(color) ? color : "#888888";
}

// No static fallbacks — CMS data only

const cardVariants = {
  enter: (direction: number) => ({
    x: direction > 0 ? "30%" : "-30%",
    opacity: 0,
    scale: 0.95,
  }),
  center: {
    x: 0,
    opacity: 1,
    scale: 1,
  },
  exit: (direction: number) => ({
    x: direction > 0 ? "-30%" : "30%",
    opacity: 0,
    scale: 0.95,
  }),
};

interface FeaturedProjectsProps {
  projects?: CMSProject[];
  className?: string;
}

export default function FeaturedProjects({ projects, className = "min-h-screen min-h-[100dvh]" }: FeaturedProjectsProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  const [direction, setDirection] = useState(1);
  const [isPaused, setIsPaused] = useState(false);
  const { t, isRTL } = useLanguage();

  // Spotlight glow tracking
  const cardRef = useRef<HTMLDivElement>(null);
  const [spotlightPos, setSpotlightPos] = useState({ x: 0, y: 0 });
  const [isHoveringCard, setIsHoveringCard] = useState(false);

  const totalItems = projects?.length ?? 0;

  const goTo = useCallback(
    (index: number) => {
      setDirection(index > activeIndex ? 1 : -1);
      setActiveIndex(index);
    },
    [activeIndex]
  );

  const next = useCallback(() => {
    setDirection(1);
    setActiveIndex((prev) => (prev + 1) % (totalItems || 1));
  }, [totalItems]);

  const prev = useCallback(() => {
    setDirection(-1);
    setActiveIndex((prev) => (prev - 1 + (totalItems || 1)) % (totalItems || 1));
  }, [totalItems]);

  useEffect(() => {
    if (isPaused || !totalItems) return;
    const timer = setInterval(next, 5000);
    return () => clearInterval(timer);
  }, [isPaused, next, totalItems]);

  const handleCardMouseMove = useCallback((e: React.MouseEvent) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    setSpotlightPos({
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    });
  }, []);

  if (!projects || projects.length === 0) return null;

  const meta = {
    gradient: projects[activeIndex].gradient,
    accentColor: sanitizeHexColor(projects[activeIndex].accentColor),
    stat: projects[activeIndex].stat,
  };

  const projectText = {
    title: projects[activeIndex].title,
    category: projects[activeIndex].category,
    description: projects[activeIndex].description,
    statLabel: projects[activeIndex].statLabel,
  };

  return (
    <section
      id="projects"
      className={`relative ${className} flex flex-col justify-center overflow-hidden py-12 sm:py-0`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 w-full">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className={`flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-10 ${isRTL ? "md:flex-row-reverse" : ""}`}
        >
          <div className={isRTL ? "text-right" : ""}>
            <span className="text-small font-mono text-brand-green uppercase tracking-widest mb-4 block">
              &mdash; {t.projects.label}
            </span>
            <h2 className="text-display" style={{ color: "var(--text-primary)" }}>
              {t.projects.heading}{" "}
              <span className="text-gradient">{t.projects.headingAccent}</span>
            </h2>
          </div>
          <p className={`text-body max-w-md ${isRTL ? "text-right" : ""}`} style={{ color: "var(--text-secondary)" }}>
            {t.projects.description}
          </p>
        </motion.div>

        {/* Carousel */}
        <div
          className="relative"
          onMouseEnter={() => setIsPaused(true)}
          onMouseLeave={() => setIsPaused(false)}
        >
          {/* Card with spotlight glow */}
          <div
            ref={cardRef}
            className="relative h-[320px] sm:h-[350px] md:h-[420px] overflow-hidden rounded-2xl sm:rounded-3xl"
            onMouseMove={handleCardMouseMove}
            onMouseEnter={() => setIsHoveringCard(true)}
            onMouseLeave={() => setIsHoveringCard(false)}
            role="region"
            aria-roledescription="carousel"
            aria-label="Featured projects"
            aria-live="polite"
          >
            {/* Spotlight glow overlay — enhanced with dual rings */}
            <div
              className="absolute z-[5] pointer-events-none transition-opacity duration-300 rounded-3xl"
              style={{
                left: spotlightPos.x - 250,
                top: spotlightPos.y - 250,
                width: 500,
                height: 500,
                background: `radial-gradient(circle, ${meta.accentColor}18 0%, ${meta.accentColor}08 30%, transparent 70%)`,
                opacity: isHoveringCard ? 1 : 0,
              }}
            />
            <div
              className="absolute z-[5] pointer-events-none transition-opacity duration-500 rounded-3xl"
              style={{
                left: spotlightPos.x - 100,
                top: spotlightPos.y - 100,
                width: 200,
                height: 200,
                background: `radial-gradient(circle, ${meta.accentColor}20 0%, transparent 60%)`,
                opacity: isHoveringCard ? 0.7 : 0,
              }}
            />

            <AnimatePresence mode="wait" custom={direction}>
              <motion.div
                key={activeIndex}
                custom={direction}
                variants={cardVariants}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{ duration: 0.5, ease: [0.19, 1, 0.22, 1] }}
                className="absolute inset-0"
              >
                <div className="relative h-full rounded-3xl overflow-hidden glass project-card-glass">
                  {/* Background gradient — stronger for light mode visibility */}
                  <div
                    className={`absolute inset-0 bg-gradient-to-br ${meta.gradient}`}
                    style={{ opacity: "var(--project-card-gradient-opacity, 0.3)" }}
                  />
                  <div className="absolute inset-0 bg-grid-dense opacity-20" />

                  {/* Bottom content overlay for readability in light mode */}
                  <div
                    className="absolute bottom-0 left-0 right-0 h-[70%] pointer-events-none"
                    style={{
                      background: `linear-gradient(to top, var(--project-card-overlay, rgba(11,15,25,0.4)) 0%, transparent 100%)`,
                    }}
                  />

                  {/* Accent line */}
                  <div
                    className="absolute top-0 left-0 right-0 h-[2px]"
                    style={{
                      background: `linear-gradient(90deg, transparent, ${meta.accentColor}, transparent)`,
                    }}
                  />

                  {/* Large stat watermark */}
                  <div className={`absolute top-4 sm:top-8 ${isRTL ? "left-4 sm:left-8 text-left" : "right-4 sm:right-8 text-right"}`}>
                    <div
                      className="text-[3.5rem] sm:text-[5rem] md:text-[7rem] font-bold leading-none"
                      style={{ color: meta.accentColor, opacity: "var(--project-card-watermark-opacity, 0.06)" }}
                    >
                      {meta.stat}
                    </div>
                  </div>

                  {/* Content */}
                  <div className={`absolute inset-0 flex flex-col justify-end p-5 sm:p-8 md:p-12 ${isRTL ? "text-right items-end" : ""}`}>
                    <span
                      className="inline-block w-fit px-3 py-1.5 rounded-full text-xs font-mono uppercase tracking-wider mb-4"
                      style={{
                        color: meta.accentColor,
                        backgroundColor: "rgba(0,0,0,0.3)",
                        border: `1px solid ${meta.accentColor}30`,
                      }}
                    >
                      {projectText.category}
                    </span>

                    <h3 className="text-xl sm:text-2xl md:text-3xl font-bold mb-2 sm:mb-3" style={{ color: "var(--project-card-text)" }}>
                      {projectText.title}
                    </h3>

                    <div className={`flex items-baseline gap-2 mb-3 ${isRTL ? "flex-row-reverse" : ""}`}>
                      <span
                        className="text-subheading font-bold"
                        style={{ color: meta.accentColor }}
                      >
                        {meta.stat}
                      </span>
                      <span className="text-small" style={{ color: "var(--project-card-text-secondary)" }}>
                        {projectText.statLabel}
                      </span>
                    </div>

                    <p className="text-body max-w-xl leading-relaxed mb-4 sm:mb-6 line-clamp-2 sm:line-clamp-none" style={{ color: "var(--project-card-text-secondary)" }}>
                      {projectText.description}
                    </p>

                    {projects[activeIndex].slug ? (
                      <Link
                        href={`/projects/${projects[activeIndex].slug}`}
                        data-cursor-hover
                        className={`flex items-center gap-2 text-small font-medium w-fit group/btn ${isRTL ? "flex-row-reverse" : ""}`}
                        style={{ color: "var(--project-card-text)" }}
                      >
                        <span className="relative">
                          {t.projects.viewCaseStudy}
                          <span
                            className="absolute bottom-0 left-0 w-0 h-[1px] group-hover/btn:w-full transition-all duration-300"
                            style={{ backgroundColor: meta.accentColor }}
                          />
                        </span>
                        <ArrowUpRight
                          size={14}
                          className="group-hover/btn:translate-x-0.5 group-hover/btn:-translate-y-0.5 transition-transform duration-300"
                          style={{ color: meta.accentColor }}
                        />
                      </Link>
                    ) : (
                      <button
                        data-cursor-hover
                        className={`flex items-center gap-2 text-small font-medium w-fit group/btn ${isRTL ? "flex-row-reverse" : ""}`}
                        style={{ color: "var(--project-card-text)" }}
                      >
                        <span className="relative">
                          {t.projects.viewCaseStudy}
                          <span
                            className="absolute bottom-0 left-0 w-0 h-[1px] group-hover/btn:w-full transition-all duration-300"
                            style={{ backgroundColor: meta.accentColor }}
                          />
                        </span>
                        <ArrowUpRight
                          size={14}
                          className="group-hover/btn:translate-x-0.5 group-hover/btn:-translate-y-0.5 transition-transform duration-300"
                          style={{ color: meta.accentColor }}
                        />
                      </button>
                    )}
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Controls */}
          <div className={`flex items-center justify-between mt-4 sm:mt-6 gap-2 ${isRTL ? "flex-row-reverse" : ""}`}>
            {/* Prev/Next buttons */}
            <div className={`flex items-center gap-3 ${isRTL ? "flex-row-reverse" : ""}`}>
              <button
                onClick={prev}
                data-cursor-hover
                aria-label="Previous project"
                className="w-11 h-11 rounded-full glass flex items-center justify-center transition-all duration-300 hover:scale-110 hover:border-brand-green/30 glow-border-hover"
                style={{ color: "var(--text-secondary)" }}
              >
                <ChevronLeft size={18} />
              </button>
              <button
                onClick={next}
                data-cursor-hover
                aria-label="Next project"
                className="w-11 h-11 rounded-full glass flex items-center justify-center transition-all duration-300 hover:scale-110 hover:border-brand-green/30 glow-border-hover"
                style={{ color: "var(--text-secondary)" }}
              >
                <ChevronRight size={18} />
              </button>
            </div>

            {/* Dot indicators with spring overshoot */}
            <div className="flex items-center gap-2">
              {Array.from({ length: totalItems }).map((_, i) => (
                <button
                  key={i}
                  onClick={() => goTo(i)}
                  data-cursor-hover
                  aria-label={`Go to project ${i + 1}`}
                  className="relative h-2 rounded-full overflow-hidden py-5 flex items-center"
                >
                  <motion.div
                    className="h-full rounded-full"
                    animate={{
                      width: activeIndex === i ? 32 : 8,
                      backgroundColor:
                        activeIndex === i
                          ? sanitizeHexColor(projects[i].accentColor)
                          : "rgba(156, 163, 175, 0.3)",
                    }}
                    transition={{
                      width: { type: "spring", stiffness: 400, damping: 22, mass: 0.6 },
                      backgroundColor: { duration: 0.3 },
                    }}
                  />
                  {activeIndex === i && !isPaused && (
                    <motion.div
                      className="absolute inset-0 rounded-full bg-white/20"
                      initial={{ scaleX: 0, originX: 0 }}
                      animate={{ scaleX: 1 }}
                      transition={{ duration: 5, ease: "linear" }}
                      key={`progress-${activeIndex}`}
                    />
                  )}
                </button>
              ))}
            </div>

            {/* Counter */}
            <span className="text-xs font-mono" style={{ color: "var(--text-muted)" }}>
              {String(activeIndex + 1).padStart(2, "0")} / {String(totalItems).padStart(2, "0")}
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
