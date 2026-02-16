"use client";

import { motion } from "framer-motion";
import { Brain, Cloud, Shield, Zap, Globe, BarChart3 } from "lucide-react";
import { staggerContainer, staggerItem } from "@/lib/animations";
import TiltCard from "@/components/ui/TiltCard";
import GradientMesh from "@/components/ui/GradientMesh";
import { useLanguage } from "@/context/LanguageContext";
import type { CMSOffering } from "@/lib/cms-types";

const iconMap: Record<string, typeof Brain> = {
  brain: Brain,
  cloud: Cloud,
  shield: Shield,
  zap: Zap,
  globe: Globe,
  barChart3: BarChart3,
};

const fallbackIcons = [Brain, Cloud, Shield, Zap, Globe, BarChart3];
const fallbackAccents = ["#00C896", "#2563EB", "#7C3AED", "#F59E0B", "#EC4899", "#06B6D4"];

function OfferCard({
  icon: Icon,
  title,
  description,
  accent,
  index,
}: {
  icon: typeof Brain;
  title: string;
  description: string;
  accent: string;
  index: number;
}) {
  return (
    <motion.div variants={staggerItem}>
      <TiltCard
        className="h-full rounded-3xl"
        intensity={8}
        glare
      >
        <div className="group relative h-full p-6 rounded-3xl glass transition-all duration-500 overflow-hidden">
          {/* Top accent line */}
          <div
            className="absolute top-0 left-0 right-0 h-[1px] opacity-0 group-hover:opacity-100 transition-opacity duration-500"
            style={{
              background: `linear-gradient(90deg, transparent, ${accent}, transparent)`,
            }}
          />

          {/* Hover background glow */}
          <div
            className="absolute -top-20 -right-20 w-40 h-40 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-700 blur-[80px]"
            style={{ backgroundColor: accent + "15" }}
          />

          <div className="relative z-10">
            {/* Icon with glow */}
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center mb-4 transition-all duration-500 group-hover:shadow-lg"
              style={{
                backgroundColor: accent + "12",
                boxShadow: `0 0 0px ${accent}00`,
              }}
            >
              <Icon size={22} style={{ color: accent }} />
            </div>

            <h3
              className="text-base font-semibold mb-2 group-hover:text-brand-green-light transition-colors duration-300"
              style={{ color: "var(--text-primary)" }}
            >
              {title}
            </h3>
            <p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
              {description}
            </p>
          </div>

          {/* Card index */}
          <span
            className="absolute top-4 right-4 text-xs font-mono text-4xl font-bold"
            style={{ opacity: "var(--card-index-opacity)", color: "var(--text-primary)" }}
          >
            {String(index + 1).padStart(2, "0")}
          </span>
        </div>
      </TiltCard>
    </motion.div>
  );
}

interface WhatWeOfferProps {
  offerings?: CMSOffering[];
}

export default function WhatWeOffer({ offerings }: WhatWeOfferProps) {
  const { t, isRTL } = useLanguage();

  const useCMS = offerings && offerings.length > 0;

  return (
    <section id="offer" className="relative h-screen flex flex-col justify-center overflow-hidden">
      {/* Background mesh */}
      <GradientMesh />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className={`max-w-2xl mb-12 ${isRTL ? "text-right ml-auto" : ""}`}
        >
          <span className="text-small font-mono text-brand-green uppercase tracking-widest mb-4 block">
            &mdash; {t.offer.label}
          </span>
          <h2 className="text-display mb-4" style={{ color: "var(--text-primary)" }}>
            {t.offer.heading}{" "}
            <span className="text-gradient">{t.offer.headingAccent}</span>
          </h2>
          <p className="text-body-lg" style={{ color: "var(--text-secondary)" }}>
            {t.offer.description}
          </p>
        </motion.div>

        {/* Cards Grid */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          animate="visible"
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
        >
          {useCMS
            ? offerings.map((offering, i) => (
                <OfferCard
                  key={offering.id}
                  icon={iconMap[offering.icon] || Brain}
                  title={offering.title}
                  description={offering.description}
                  accent={offering.accentColor}
                  index={i}
                />
              ))
            : t.offer.items.map((offering, i) => (
                <OfferCard
                  key={offering.title}
                  icon={fallbackIcons[i]}
                  title={offering.title}
                  description={offering.description}
                  accent={fallbackAccents[i]}
                  index={i}
                />
              ))}
        </motion.div>
      </div>
    </section>
  );
}
