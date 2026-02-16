"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronDown, ArrowRight } from "lucide-react";
import GradientMesh from "@/components/ui/GradientMesh";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSService } from "@/lib/cms-types";

const fallbackServiceMeta = [
  {
    id: "ai",
    technologies: ["PyTorch", "TensorFlow", "LangChain", "OpenAI", "Hugging Face", "MLflow"],
    accent: "#00C896",
  },
  {
    id: "cloud",
    technologies: ["AWS", "GCP", "Azure", "Kubernetes", "Terraform", "Docker"],
    accent: "#2563EB",
  },
  {
    id: "product",
    technologies: ["React", "Next.js", "React Native", "Node.js", "PostgreSQL", "GraphQL"],
    accent: "#7C3AED",
  },
  {
    id: "security",
    technologies: ["Zero Trust", "SOC 2", "HIPAA", "Vault", "WAF", "SIEM"],
    accent: "#F59E0B",
  },
  {
    id: "data",
    technologies: ["Spark", "Kafka", "Snowflake", "dbt", "Airflow", "Looker"],
    accent: "#EC4899",
  },
];

function ServiceItem({
  title,
  overview,
  technologies,
  accent,
  isOpen,
  onToggle,
  index,
  learnMore,
  isRTL,
}: {
  title: string;
  overview: string;
  technologies: string[];
  accent: string;
  isOpen: boolean;
  onToggle: () => void;
  index: number;
  learnMore: string;
  isRTL: boolean;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.1, duration: 0.6, ease: [0.19, 1, 0.22, 1] }}
      className="relative"
      style={{ borderBottom: "1px solid var(--border-color)" }}
    >
      {/* Active indicator */}
      {isOpen && (
        <motion.div
          layoutId="service-indicator"
          className={`absolute top-0 bottom-0 w-[2px] ${isRTL ? "right-0" : "left-0"}`}
          style={{ backgroundColor: accent }}
          transition={{ type: "spring", stiffness: 300, damping: 30 }}
        />
      )}

      <button
        onClick={onToggle}
        data-cursor-hover
        className={`w-full flex items-center justify-between py-5 md:py-6 group ${isRTL ? "text-right pr-4 md:pr-6 flex-row-reverse" : "text-left pl-4 md:pl-6"}`}
      >
        <div className={`flex items-center gap-4 md:gap-6 ${isRTL ? "flex-row-reverse" : ""}`}>
          <span className="text-xs font-mono hidden sm:block w-6" style={{ color: "var(--text-muted)" }}>
            {String(index + 1).padStart(2, "0")}
          </span>
          <h3
            className={`text-lg md:text-xl font-semibold transition-all duration-500 ${
              isOpen ? "translate-x-2" : "translate-x-0"
            }`}
            style={{
              color: isOpen ? accent : "var(--text-primary)",
              transform: isOpen ? (isRTL ? "translateX(-8px)" : "translateX(8px)") : "translateX(0)",
            }}
          >
            {title}
          </h3>
        </div>
        <motion.div
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.4, ease: [0.19, 1, 0.22, 1] }}
          className="flex-shrink-0 ml-4"
        >
          <ChevronDown
            size={20}
            className="transition-colors duration-300"
            style={{ color: isOpen ? accent : "var(--text-muted)" }}
          />
        </motion.div>
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.5, ease: [0.19, 1, 0.22, 1] }}
            className="overflow-hidden"
          >
            <div className={`pb-5 ${isRTL ? "pr-4 sm:pr-16 md:pr-[4.5rem] text-right" : "pl-4 sm:pl-16 md:pl-[4.5rem]"}`}>
              <motion.p
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1, duration: 0.4 }}
                className="text-body mb-4 max-w-2xl leading-relaxed"
                style={{ color: "var(--text-secondary)" }}
              >
                {overview}
              </motion.p>

              {/* Tech Tags */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.2, duration: 0.4 }}
                className={`flex flex-wrap gap-2 mb-4 ${isRTL ? "justify-end" : ""}`}
              >
                {technologies.map((tech, i) => (
                  <motion.span
                    key={tech}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.2 + i * 0.05, duration: 0.3 }}
                    className="px-3 py-1.5 rounded-full text-xs font-mono border"
                    style={{
                      color: accent,
                      backgroundColor: accent + "10",
                      borderColor: accent + "20",
                    }}
                  >
                    {tech}
                  </motion.span>
                ))}
              </motion.div>

              <motion.button
                initial={{ opacity: 0, x: isRTL ? 10 : -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.3, duration: 0.4 }}
                data-cursor-hover
                className={`flex items-center gap-2 text-small font-medium transition-colors duration-300 group/cta ${isRTL ? "flex-row-reverse" : ""}`}
                style={{ color: accent }}
              >
                {learnMore}
                <ArrowRight
                  size={14}
                  className={`group-hover/cta:translate-x-1 transition-transform duration-300 ${isRTL ? "rotate-180" : ""}`}
                />
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

interface OurServicesProps {
  services?: CMSService[];
}

export default function OurServices({ services }: OurServicesProps) {
  const [openIndex, setOpenIndex] = useState<number>(0);
  const { t, isRTL } = useLanguage();

  const useCMS = services && services.length > 0;

  return (
    <section id="services" className="relative h-screen flex flex-col justify-center overflow-hidden">
      <GradientMesh className="opacity-50" />

      <div className="max-w-5xl mx-auto px-6 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className={`mb-8 ${isRTL ? "text-right" : ""}`}
        >
          <span className="text-small font-mono text-brand-green uppercase tracking-widest mb-4 block">
            &mdash; {t.services.label}
          </span>
          <h2 className="text-display mb-4" style={{ color: "var(--text-primary)" }}>
            {t.services.heading}{" "}
            <span className="text-gradient">{t.services.headingAccent}</span>
          </h2>
          <p className="text-body-lg max-w-xl" style={{ color: "var(--text-secondary)" }}>
            {t.services.description}
          </p>
        </motion.div>

        {/* Accordion */}
        <div className="glass rounded-3xl p-2 md:p-4 glow-border">
          {useCMS
            ? services.map((service, i) => (
                <ServiceItem
                  key={service.id}
                  title={service.title}
                  overview={service.overview}
                  technologies={service.technologies.map((t) => t.name)}
                  accent={service.accentColor}
                  isOpen={openIndex === i}
                  onToggle={() => setOpenIndex(openIndex === i ? -1 : i)}
                  index={i}
                  learnMore={t.services.learnMore}
                  isRTL={isRTL}
                />
              ))
            : t.services.items.map((service, i) => (
                <ServiceItem
                  key={fallbackServiceMeta[i].id}
                  title={service.title}
                  overview={service.overview}
                  technologies={fallbackServiceMeta[i].technologies}
                  accent={fallbackServiceMeta[i].accent}
                  isOpen={openIndex === i}
                  onToggle={() => setOpenIndex(openIndex === i ? -1 : i)}
                  index={i}
                  learnMore={t.services.learnMore}
                  isRTL={isRTL}
                />
              ))}
        </div>
      </div>
    </section>
  );
}
