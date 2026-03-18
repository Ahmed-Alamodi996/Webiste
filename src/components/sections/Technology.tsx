"use client";

import { motion } from "framer-motion";
import InfiniteMarquee from "@/components/ui/InfiniteMarquee";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSTechnology } from "@/lib/cms-types";

// No static fallbacks — CMS data only

function TechPill({
  name,
  color,
}: {
  name: string;
  color: string;
}) {
  return (
    <div
      data-cursor-hover
      className="group relative flex items-center gap-3 px-6 py-3.5 rounded-full glass transition-all duration-400 hover:scale-105 hover:-translate-y-0.5 flex-shrink-0"
      style={{
        transition: "transform 0.4s cubic-bezier(0.19, 1, 0.22, 1), box-shadow 0.4s ease, border-color 0.4s ease",
      }}
    >
      {/* Glow dot with pulse */}
      <div className="relative">
        <div
          className="w-2.5 h-2.5 rounded-full transition-all duration-400 group-hover:scale-125"
          style={{
            backgroundColor: color,
            boxShadow: `0 0 8px ${color}50`,
            transition: "transform 0.4s ease, box-shadow 0.4s ease",
          }}
        />
        <div
          className="absolute inset-0 rounded-full opacity-0 group-hover:opacity-100 animate-ping"
          style={{
            backgroundColor: color,
            animationDuration: "2s",
          }}
        />
      </div>
      <span
        className="text-small font-medium transition-colors duration-300 whitespace-nowrap group-hover:text-white"
        style={{ color: "var(--text-secondary)" }}
      >
        {name}
      </span>

      {/* Hover glow — stronger */}
      <div
        className="absolute inset-0 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"
        style={{
          background: `radial-gradient(circle at center, ${color}12 0%, transparent 70%)`,
          boxShadow: `inset 0 0 20px ${color}08`,
        }}
      />
    </div>
  );
}

interface TechnologyProps {
  technologies?: CMSTechnology[];
  className?: string;
}

export default function Technology({ technologies, className = "min-h-screen min-h-[100dvh]" }: TechnologyProps) {
  const { t, isRTL } = useLanguage();

  if (!technologies || technologies.length === 0) return null;

  const techRow1 = technologies
    .filter((t) => t.row === "1")
    .sort((a, b) => a.order - b.order)
    .map((t) => ({ name: t.name, color: t.color }));
  const techRow2 = technologies
    .filter((t) => t.row === "2")
    .sort((a, b) => a.order - b.order)
    .map((t) => ({ name: t.name, color: t.color }));
  const techRow3 = technologies
    .filter((t) => t.row === "3")
    .sort((a, b) => a.order - b.order)
    .map((t) => ({ name: t.name, color: t.color }));

  return (
    <section id="technology" className={`relative ${className} flex flex-col justify-center overflow-hidden py-12 sm:py-0`}>
      <div className="max-w-6xl mx-auto px-4 sm:px-6 mb-8 md:mb-16">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className="text-center"
        >
          <span className="text-small font-mono text-brand-green uppercase tracking-widest mb-4 block">
            &mdash; {t.technology.label}
          </span>
          <h2 className="text-display mb-4" style={{ color: "var(--text-primary)" }}>
            {t.technology.heading}{" "}
            <span className="text-gradient">{t.technology.headingAccent}</span>
          </h2>
          <p className="text-body-lg max-w-xl mx-auto" style={{ color: "var(--text-secondary)" }}>
            {t.technology.description}
          </p>
        </motion.div>
      </div>

      {/* Marquee Rows */}
      <div className="space-y-4">
        {/* Row 1 */}
        <motion.div
          initial={{ opacity: 0, x: isRTL ? 40 : -40 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
        >
          <InfiniteMarquee speed={35} direction={isRTL ? "right" : "left"}>
            <div className="flex gap-4">
              {techRow1.map((tech) => (
                <TechPill key={tech.name} {...tech} />
              ))}
            </div>
          </InfiniteMarquee>
        </motion.div>

        {/* Row 2 */}
        <motion.div
          initial={{ opacity: 0, x: isRTL ? -40 : 40 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, delay: 0.35 }}
        >
          <InfiniteMarquee speed={40} direction={isRTL ? "left" : "right"}>
            <div className="flex gap-4">
              {techRow2.map((tech) => (
                <TechPill key={tech.name} {...tech} />
              ))}
            </div>
          </InfiniteMarquee>
        </motion.div>

        {/* Row 3 */}
        <motion.div
          initial={{ opacity: 0, x: isRTL ? 40 : -40 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
        >
          <InfiniteMarquee speed={45} direction={isRTL ? "right" : "left"}>
            <div className="flex gap-4">
              {techRow3.map((tech) => (
                <TechPill key={tech.name} {...tech} />
              ))}
            </div>
          </InfiniteMarquee>
        </motion.div>
      </div>
    </section>
  );
}
