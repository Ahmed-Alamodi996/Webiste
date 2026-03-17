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
        <div className="group relative h-full rounded-2xl sm:rounded-3xl glass transition-all duration-500 overflow-hidden hover:-translate-y-2 hover:shadow-2xl"
          style={{ padding: "clamp(0.75rem, 2vw, 1.5rem)" }}
          style={{
            transition: "transform 0.5s cubic-bezier(0.19, 1, 0.22, 1), box-shadow 0.5s cubic-bezier(0.19, 1, 0.22, 1), background 0.4s ease, border-color 0.4s ease",
          }}
        >
          {/* Top accent line */}
          <div
            className="absolute top-0 left-0 right-0 h-[2px] opacity-0 group-hover:opacity-100 transition-opacity duration-500"
            style={{
              background: `linear-gradient(90deg, transparent, ${accent}, transparent)`,
            }}
          />

          {/* Hover background glow — stronger */}
          <div
            className="absolute -top-10 -right-10 w-60 h-60 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-700 blur-[100px]"
            style={{ backgroundColor: accent + "20" }}
          />

          {/* Bottom corner glow */}
          <div
            className="absolute -bottom-20 -left-20 w-40 h-40 rounded-full opacity-0 group-hover:opacity-60 transition-opacity duration-700 blur-[80px]"
            style={{ backgroundColor: accent + "15" }}
          />

          <div className="relative z-10">
            {/* Icon with glow */}
            <div
              className="rounded-xl sm:rounded-2xl flex items-center justify-center transition-all duration-500 group-hover:scale-110"
              style={{ width: "clamp(2rem, 4vw, 3rem)", height: "clamp(2rem, 4vw, 3rem)", marginBottom: "clamp(0.5rem, 1.5vw, 1rem)" }}
              style={{
                backgroundColor: accent + "12",
                boxShadow: `0 0 0px ${accent}00`,
                transition: "transform 0.5s cubic-bezier(0.19, 1, 0.22, 1), box-shadow 0.5s ease",
              }}
            >
              <Icon
                size={20}
                style={{
                  color: accent,
                  transition: "filter 0.5s ease",
                  filter: "drop-shadow(0 0 0px transparent)",
                }}
                className="group-hover:drop-shadow-lg"
              />
            </div>

            <h3
              className="font-semibold group-hover:text-brand-green-light transition-colors duration-300"
              style={{ color: "var(--text-primary)", fontSize: "clamp(0.75rem, 1.8vw, 1rem)", marginBottom: "clamp(0.25rem, 0.8vw, 0.5rem)" }}
            >
              {title}
            </h3>
            <p className="leading-relaxed" style={{ color: "var(--text-secondary)", fontSize: "clamp(0.65rem, 1.5vw, 0.875rem)" }}>
              {description}
            </p>
          </div>

          {/* Card index */}
          <span
            className="absolute top-4 right-4 font-mono text-2xl sm:text-4xl font-bold transition-opacity duration-500"
            style={{ opacity: "var(--card-index-opacity)", color: accent }}
          >
            {String(index + 1).padStart(2, "0")}
          </span>

          {/* Bottom glow line on hover */}
          <div
            className="absolute bottom-0 left-[10%] right-[10%] h-[1px] opacity-0 group-hover:opacity-100 transition-all duration-700"
            style={{
              background: `linear-gradient(90deg, transparent, ${accent}40, transparent)`,
              boxShadow: `0 0 15px ${accent}20`,
            }}
          />
        </div>
      </TiltCard>
    </motion.div>
  );
}

interface WhatWeOfferProps {
  offerings?: CMSOffering[];
  className?: string;
}

export default function WhatWeOffer({ offerings, className = "min-h-[100dvh]" }: WhatWeOfferProps) {
  const { t, isRTL } = useLanguage();

  const useCMS = offerings && offerings.length > 0;

  return (
    <section id="offer" className={`relative ${className} flex flex-col justify-center overflow-hidden py-12 sm:py-0`}>
      {/* Background mesh */}
      <GradientMesh />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className={`max-w-2xl ${isRTL ? "text-right ml-auto" : ""}`}
          style={{ marginBottom: "clamp(1rem, 3vw, 3rem)" }}
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
          className="grid grid-cols-2 lg:grid-cols-3 gap-[clamp(0.5rem,1.5vw,1rem)]"
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
