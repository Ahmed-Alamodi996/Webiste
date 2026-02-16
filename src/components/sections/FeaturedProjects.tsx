"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowUpRight, ChevronLeft, ChevronRight } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSProject } from "@/lib/cms-types";

const fallbackProjectMeta = [
  {
    gradient: "from-emerald-500/20 to-cyan-500/20",
    accentColor: "#00C896",
    stat: "50M+",
  },
  {
    gradient: "from-blue-500/20 to-violet-500/20",
    accentColor: "#2563EB",
    stat: "99.99%",
  },
  {
    gradient: "from-violet-500/20 to-pink-500/20",
    accentColor: "#7C3AED",
    stat: "$2B+",
  },
  {
    gradient: "from-amber-500/20 to-orange-500/20",
    accentColor: "#F59E0B",
    stat: "1TB+",
  },
];

const cardVariants = {
  enter: (direction: number) => ({
    x: direction > 0 ? 300 : -300,
    opacity: 0,
    scale: 0.95,
  }),
  center: {
    x: 0,
    opacity: 1,
    scale: 1,
  },
  exit: (direction: number) => ({
    x: direction > 0 ? -300 : 300,
    opacity: 0,
    scale: 0.95,
  }),
};

interface FeaturedProjectsProps {
  projects?: CMSProject[];
}

export default function FeaturedProjects({ projects }: FeaturedProjectsProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  const [direction, setDirection] = useState(1);
  const [isPaused, setIsPaused] = useState(false);
  const { t, isRTL } = useLanguage();

  // Use CMS projects if available, otherwise fall back to static data
  const useCMS = projects && projects.length > 0;
  const totalItems = useCMS ? projects.length : fallbackProjectMeta.length;

  const goTo = useCallback(
    (index: number) => {
      setDirection(index > activeIndex ? 1 : -1);
      setActiveIndex(index);
    },
    [activeIndex]
  );

  const next = useCallback(() => {
    setDirection(1);
    setActiveIndex((prev) => (prev + 1) % totalItems);
  }, [totalItems]);

  const prev = useCallback(() => {
    setDirection(-1);
    setActiveIndex((prev) => (prev - 1 + totalItems) % totalItems);
  }, [totalItems]);

  // Auto-advance every 5s
  useEffect(() => {
    if (isPaused) return;
    const timer = setInterval(next, 5000);
    return () => clearInterval(timer);
  }, [isPaused, next]);

  // Get current item data
  const meta = useCMS
    ? {
        gradient: projects[activeIndex].gradient,
        accentColor: projects[activeIndex].accentColor,
        stat: projects[activeIndex].stat,
      }
    : fallbackProjectMeta[activeIndex];

  const projectText = useCMS
    ? {
        title: projects[activeIndex].title,
        category: projects[activeIndex].category,
        description: projects[activeIndex].description,
        statLabel: projects[activeIndex].statLabel,
      }
    : t.projects.items[activeIndex];

  return (
    <section
      id="projects"
      className="relative h-screen flex flex-col justify-center overflow-hidden"
    >
      <div className="max-w-7xl mx-auto px-6 w-full">
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
          {/* Card */}
          <div className="relative h-[400px] md:h-[420px] overflow-hidden rounded-3xl">
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
                <div className="relative h-full rounded-3xl overflow-hidden glass">
                  {/* Background gradient */}
                  <div
                    className={`absolute inset-0 bg-gradient-to-br ${meta.gradient} opacity-30`}
                  />
                  <div className="absolute inset-0 bg-grid-dense opacity-20" />

                  {/* Accent line */}
                  <div
                    className="absolute top-0 left-0 right-0 h-[2px]"
                    style={{
                      background: `linear-gradient(90deg, transparent, ${meta.accentColor}, transparent)`,
                    }}
                  />

                  {/* Large stat watermark */}
                  <div className={`absolute top-8 ${isRTL ? "left-8 text-left" : "right-8 text-right"}`}>
                    <div
                      className="text-[5rem] md:text-[7rem] font-bold leading-none opacity-[0.06]"
                      style={{ color: meta.accentColor }}
                    >
                      {meta.stat}
                    </div>
                  </div>

                  {/* Content */}
                  <div className={`absolute inset-0 flex flex-col justify-end p-8 md:p-12 ${isRTL ? "text-right items-end" : ""}`}>
                    <span
                      className="inline-block w-fit px-3 py-1.5 rounded-full text-xs font-mono uppercase tracking-wider mb-4 glass"
                      style={{ color: meta.accentColor }}
                    >
                      {projectText.category}
                    </span>

                    <h3 className="text-2xl md:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>
                      {projectText.title}
                    </h3>

                    <div className={`flex items-baseline gap-2 mb-3 ${isRTL ? "flex-row-reverse" : ""}`}>
                      <span
                        className="text-subheading font-bold"
                        style={{ color: meta.accentColor }}
                      >
                        {meta.stat}
                      </span>
                      <span className="text-small" style={{ color: "var(--text-secondary)" }}>
                        {projectText.statLabel}
                      </span>
                    </div>

                    <p className="text-body max-w-xl leading-relaxed mb-6" style={{ color: "var(--text-secondary)" }}>
                      {projectText.description}
                    </p>

                    <button
                      data-cursor-hover
                      className={`flex items-center gap-2 text-small font-medium w-fit group/btn ${isRTL ? "flex-row-reverse" : ""}`}
                      style={{ color: "var(--text-primary)" }}
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
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Controls */}
          <div className={`flex items-center justify-between mt-6 ${isRTL ? "flex-row-reverse" : ""}`}>
            {/* Prev/Next buttons */}
            <div className={`flex items-center gap-3 ${isRTL ? "flex-row-reverse" : ""}`}>
              <button
                onClick={prev}
                data-cursor-hover
                className="w-10 h-10 rounded-full glass flex items-center justify-center transition-all duration-300"
                style={{ color: "var(--text-secondary)" }}
              >
                <ChevronLeft size={18} />
              </button>
              <button
                onClick={next}
                data-cursor-hover
                className="w-10 h-10 rounded-full glass flex items-center justify-center transition-all duration-300"
                style={{ color: "var(--text-secondary)" }}
              >
                <ChevronRight size={18} />
              </button>
            </div>

            {/* Dot indicators */}
            <div className="flex items-center gap-2">
              {Array.from({ length: totalItems }).map((_, i) => (
                <button
                  key={i}
                  onClick={() => goTo(i)}
                  data-cursor-hover
                  className="relative h-2 rounded-full overflow-hidden transition-all duration-500"
                  style={{ width: activeIndex === i ? 32 : 8 }}
                >
                  <div
                    className="absolute inset-0 rounded-full transition-colors duration-300"
                    style={{
                      backgroundColor:
                        activeIndex === i
                          ? (useCMS ? projects[i].accentColor : fallbackProjectMeta[i].accentColor)
                          : "rgba(156, 163, 175, 0.3)",
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
