"use client";

import { motion } from "framer-motion";
import AnimatedCounter from "@/components/ui/AnimatedCounter";
import AuroraBeam from "@/components/ui/AuroraBeam";
import TextReveal from "@/components/ui/TextReveal";
import { useLanguage } from "@/context/LanguageContext";

export default function AboutUs() {
  const { t, isRTL } = useLanguage();

  return (
    <section id="about" className="relative min-h-screen min-h-[100dvh] flex flex-col justify-center overflow-hidden py-12 sm:py-0">
      {/* Background grid with perspective fade */}
      <div className="absolute inset-0 bg-grid opacity-20" />
      <AuroraBeam className="opacity-50" />

      {/* Top gradient separator */}
      <div
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background: "linear-gradient(90deg, transparent, rgba(0, 200, 150, 0.15), transparent)",
        }}
      />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 relative z-10">
        <div className={`grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-center ${isRTL ? "direction-rtl" : ""}`}>
          {/* Left — Big Typography with text reveal */}
          <div className={isRTL ? "text-right" : ""}>
            <motion.span
              initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6, ease: [0.19, 1, 0.22, 1] }}
              className="text-small font-mono text-brand-green uppercase tracking-widest mb-6 block"
            >
              &mdash; {t.about.label}
            </motion.span>

            <h2 className="text-display-lg mb-6" style={{ color: "var(--text-primary)" }}>
              <TextReveal delay={0.1}>{t.about.headingLine1}</TextReveal>{" "}
              <TextReveal delay={0.3} gradient>{t.about.headingWord1}</TextReveal>
              <br />
              <TextReveal delay={0.5}>{t.about.headingLine2}</TextReveal>{" "}
              <TextReveal delay={0.7} gradient>{t.about.headingWord2}</TextReveal>
            </h2>

            <motion.div
              initial={{ scaleX: 0 }}
              animate={{ scaleX: 1 }}
              transition={{ duration: 0.8, delay: 0.9, ease: [0.19, 1, 0.22, 1] }}
              className={`w-20 h-[2px] bg-gradient-accent mb-8 ${isRTL ? "origin-right" : "origin-left"}`}
            />
          </div>

          {/* Right — Description with staggered paragraphs */}
          <div className={isRTL ? "text-right" : ""}>
            <motion.p
              initial={{ opacity: 0, y: 20, filter: "blur(6px)" }}
              animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
              transition={{ duration: 0.7, delay: 0.3, ease: [0.19, 1, 0.22, 1] }}
              className="text-body-lg mb-6 leading-relaxed"
              style={{ color: "var(--text-secondary)" }}
            >
              {t.about.paragraph1}
            </motion.p>
            <motion.p
              initial={{ opacity: 0, y: 20, filter: "blur(6px)" }}
              animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
              transition={{ duration: 0.7, delay: 0.5, ease: [0.19, 1, 0.22, 1] }}
              className="text-body-lg leading-relaxed"
              style={{ color: "var(--text-secondary)" }}
            >
              {t.about.paragraph2}
            </motion.p>
          </div>
        </div>

        {/* Counters — enhanced with glass cards */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6, ease: [0.19, 1, 0.22, 1] }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6 mt-8 md:mt-16"
        >
          {t.about.stats.map((counter, i) => (
            <motion.div
              key={`stat-${i}`}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.7 + i * 0.1, duration: 0.5 }}
              className="glass rounded-2xl p-4 sm:p-6 md:p-8 glow-border"
            >
              <AnimatedCounter {...counter} />
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
