"use client";

import { motion } from "framer-motion";
import InfiniteMarquee from "@/components/ui/InfiniteMarquee";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSTechnology } from "@/lib/cms-types";

const fallbackTechRow1 = [
  { name: "React", color: "#61DAFB" },
  { name: "Next.js", color: "#888888" },
  { name: "TypeScript", color: "#3178C6" },
  { name: "Node.js", color: "#339933" },
  { name: "Python", color: "#3776AB" },
  { name: "PostgreSQL", color: "#4169E1" },
  { name: "Kubernetes", color: "#326CE5" },
  { name: "Docker", color: "#2496ED" },
];

const fallbackTechRow2 = [
  { name: "AWS", color: "#FF9900" },
  { name: "Terraform", color: "#7B42BC" },
  { name: "GraphQL", color: "#E10098" },
  { name: "Redis", color: "#DC382D" },
  { name: "TensorFlow", color: "#FF6F00" },
  { name: "PyTorch", color: "#EE4C2C" },
  { name: "Kafka", color: "#888888" },
  { name: "Go", color: "#00ADD8" },
];

const fallbackTechRow3 = [
  { name: "Rust", color: "#CE412B" },
  { name: "Swift", color: "#F05138" },
  { name: "MongoDB", color: "#47A248" },
  { name: "Snowflake", color: "#29B5E8" },
  { name: "OpenAI", color: "#00A67E" },
  { name: "Figma", color: "#F24E1E" },
  { name: "Vercel", color: "#888888" },
  { name: "GitHub", color: "#888888" },
];

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
      className="group flex items-center gap-3 px-6 py-3.5 rounded-full glass transition-all duration-300 hover:scale-105 flex-shrink-0"
    >
      {/* Glow dot */}
      <div
        className="w-2.5 h-2.5 rounded-full transition-all duration-300 group-hover:shadow-lg"
        style={{
          backgroundColor: color,
          boxShadow: `0 0 0px ${color}00`,
        }}
      />
      <span
        className="text-small font-medium transition-colors duration-300 whitespace-nowrap"
        style={{ color: "var(--text-secondary)" }}
      >
        {name}
      </span>

      {/* Hover glow */}
      <div
        className="absolute inset-0 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"
        style={{
          background: `radial-gradient(circle at center, ${color}06 0%, transparent 70%)`,
        }}
      />
    </div>
  );
}

interface TechnologyProps {
  technologies?: CMSTechnology[];
}

export default function Technology({ technologies }: TechnologyProps) {
  const { t, isRTL } = useLanguage();

  // Group CMS technologies by row, or fall back to hardcoded data
  const useCMS = technologies && technologies.length > 0;

  let techRow1: { name: string; color: string }[];
  let techRow2: { name: string; color: string }[];
  let techRow3: { name: string; color: string }[];

  if (useCMS) {
    techRow1 = technologies
      .filter((t) => t.row === "1")
      .sort((a, b) => a.order - b.order)
      .map((t) => ({ name: t.name, color: t.color }));
    techRow2 = technologies
      .filter((t) => t.row === "2")
      .sort((a, b) => a.order - b.order)
      .map((t) => ({ name: t.name, color: t.color }));
    techRow3 = technologies
      .filter((t) => t.row === "3")
      .sort((a, b) => a.order - b.order)
      .map((t) => ({ name: t.name, color: t.color }));
  } else {
    techRow1 = fallbackTechRow1;
    techRow2 = fallbackTechRow2;
    techRow3 = fallbackTechRow3;
  }

  return (
    <section id="technology" className="relative h-screen flex flex-col justify-center overflow-hidden">
      <div className="max-w-6xl mx-auto px-6 mb-16">
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
