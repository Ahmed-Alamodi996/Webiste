"use client";

import { useRef } from "react";
import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import { ArrowRight, ChevronDown } from "lucide-react";
import MagneticButton from "@/components/ui/MagneticButton";
import TextScramble from "@/components/ui/TextScramble";

const ParticleGrid = dynamic(() => import("@/components/ui/ParticleGrid"), { ssr: false });
const AuroraBeam = dynamic(() => import("@/components/ui/AuroraBeam"), { ssr: false });
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";

export default function Hero() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { goToSlide } = useSlide();
  const { t, isRTL } = useLanguage();
  const themeSettings = t.theme;

  return (
    <section
      ref={containerRef}
      className="relative min-h-screen min-h-[100dvh] flex items-center justify-center overflow-hidden"
    >
      {/* Interactive Particle Grid — CMS toggle */}
      {themeSettings?.enableParticles !== false && <ParticleGrid />}

      {/* Aurora Beams — CMS toggle */}
      {themeSettings?.enableAurora !== false && <AuroraBeam />}

      {/* Gradient Blobs — CSS animated, GPU composited */}
      <style jsx>{`
        @keyframes blob1 {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          50% { transform: translate3d(80px, -60px, 0) scale(1.1); }
        }
        @keyframes blob2 {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          50% { transform: translate3d(-70px, 50px, 0) scale(0.9); }
        }
        @keyframes blob3 {
          0%, 100% { transform: translate3d(-50%, 0, 0) scale(1); }
          50% { transform: translate3d(-50%, -80px, 0) scale(1.15); }
        }
      `}</style>
      <div
        className="absolute top-[15%] left-[15%] w-[300px] sm:w-[600px] h-[300px] sm:h-[600px] rounded-full bg-brand-green/[0.07] blur-[100px]"
        style={{ animation: "blob1 8s ease-in-out infinite", willChange: "transform" }}
      />
      <div
        className="absolute bottom-[15%] right-[15%] w-[250px] sm:w-[500px] h-[250px] sm:h-[500px] rounded-full bg-blue-600/[0.06] blur-[100px]"
        style={{ animation: "blob2 11s ease-in-out infinite", willChange: "transform" }}
      />
      <div
        className="absolute top-[40%] left-[50%] w-[350px] sm:w-[700px] h-[350px] sm:h-[700px] rounded-full bg-brand-green/[0.04] blur-[120px]"
        style={{ animation: "blob3 14s ease-in-out infinite", willChange: "transform" }}
      />

      {/* Radial vignette */}
      <div
        className="absolute inset-0"
        style={{
          background: `radial-gradient(ellipse 80% 60% at 50% 50%, transparent 0%, rgba(var(--vignette-color), 0.4) 60%, rgba(var(--vignette-color), 0.95) 100%)`,
        }}
      />

      {/* Top fade */}
      <div
        className="absolute top-0 left-0 right-0 h-32 z-[1]"
        style={{
          background: `linear-gradient(to bottom, var(--bg-primary), transparent)`,
        }}
      />

      {/* Content */}
      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6 text-center">
        {/* Tag */}
        <motion.div
          initial={{ opacity: 0, y: 20, filter: "blur(10px)" }}
          animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="inline-flex items-center gap-2 sm:gap-2.5 px-4 sm:px-5 py-2 sm:py-2.5 rounded-full glass mb-6 sm:mb-10"
        >
          <span className="relative w-2 h-2">
            <span className="absolute inset-0 rounded-full bg-brand-green animate-ping opacity-75" />
            <span className="relative block w-2 h-2 rounded-full bg-brand-green" />
          </span>
          <TextScramble
            className="text-small tracking-wide font-mono"
            style={{ color: "var(--text-muted-light)" }}
            delay={500}
            speed={30}
          >
            {t.hero.tagline}
          </TextScramble>
        </motion.div>

        {/* Headline */}
        <h1 className="text-display-xl mb-8">
          {t.hero.headlineLine1.filter(Boolean).map((word, i) => (
            <span key={i} className="inline-block overflow-hidden mr-[0.3em]">
              <motion.span
                initial={{ y: "120%", rotateX: -80, opacity: 0 }}
                animate={{ y: "0%", rotateX: 0, opacity: 1 }}
                transition={{
                  duration: 0.9,
                  delay: 0.5 + i * 0.08,
                  ease: [0.19, 1, 0.22, 1],
                }}
                className="inline-block"
                style={{ color: "var(--text-primary)", transformOrigin: "bottom center", perspective: "1000px" }}
              >
                {word}
              </motion.span>
            </span>
          ))}
          <br className="hidden sm:block" />
          {t.hero.headlineLine2.map((word, i) => (
            <span key={word} className="inline-block overflow-hidden mr-[0.3em]">
              <motion.span
                initial={{ y: "120%", rotateX: -80, opacity: 0 }}
                animate={{ y: "0%", rotateX: 0, opacity: 1 }}
                transition={{
                  duration: 0.9,
                  delay: 0.82 + i * 0.08,
                  ease: [0.19, 1, 0.22, 1],
                }}
                className="inline-block text-gradient"
                style={{ transformOrigin: "bottom center", perspective: "1000px" }}
              >
                {word}
              </motion.span>
            </span>
          ))}
        </h1>

        {/* Animated accent line */}
        <motion.div
          initial={{ scaleX: 0, opacity: 0 }}
          animate={{ scaleX: 1, opacity: 1 }}
          transition={{ duration: 1, delay: 1, ease: [0.19, 1, 0.22, 1] }}
          className="w-24 h-[2px] mx-auto mb-8 origin-center"
          style={{ background: "linear-gradient(90deg, transparent, #00C896, transparent)" }}
        />

        {/* Subtext */}
        <motion.p
          initial={{ opacity: 0, y: 20, filter: "blur(8px)" }}
          animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
          transition={{ duration: 0.8, delay: 1.1 }}
          className="text-body-lg max-w-2xl mx-auto mb-8 sm:mb-14 leading-relaxed"
          style={{ color: "var(--text-secondary)" }}
        >
          {t.hero.description}
        </motion.p>

        {/* CTAs */}
        <motion.div
          initial={{ opacity: 0, y: 20, filter: "blur(8px)" }}
          animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
          transition={{ duration: 0.8, delay: 1.3 }}
          className={`flex flex-col sm:flex-row items-center justify-center gap-4 ${isRTL ? "sm:flex-row-reverse" : ""}`}
        >
          <MagneticButton
            onClick={() => goToSlide(1)}
            className="group relative px-6 sm:px-8 py-4 rounded-full bg-gradient-accent text-white font-medium text-body flex items-center gap-2.5 hover:shadow-glow-lg transition-all duration-500 overflow-hidden"
          >
            {/* Shimmer effect */}
            <motion.div
              className="absolute inset-0 -translate-x-full"
              animate={{ translateX: ["-100%", "200%"] }}
              transition={{ duration: 3, repeat: Infinity, repeatDelay: 2, ease: "easeInOut" }}
              style={{
                background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent)",
              }}
            />
            <span className={`relative z-10 flex items-center gap-2.5 ${isRTL ? "flex-row-reverse" : ""}`}>
              {t.hero.exploreSolutions}
              <ArrowRight
                size={18}
                className={`group-hover:translate-x-1 transition-transform duration-300 ${isRTL ? "rotate-180" : ""}`}
              />
            </span>
          </MagneticButton>

          <MagneticButton
            onClick={() => goToSlide(6)}
            className="group px-6 sm:px-8 py-4 rounded-full glass glow-border glow-border-hover font-medium text-body flex items-center gap-2 transition-all duration-500"
            style={{ color: "var(--text-primary)" }}
          >
            {t.hero.getInTouch}
          </MagneticButton>
        </motion.div>

        {/* Stats strip */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.8, duration: 1 }}
          className="mt-10 sm:mt-20 flex flex-wrap items-center justify-center gap-6 sm:gap-10"
        >
          {[
            { value: "50+", label: t.hero.statsProjects || "Projects Delivered" },
            { value: "99.9%", label: t.hero.statsUptime || "Uptime SLA" },
            { value: "24/7", label: t.hero.statsSupport || "Support" },
          ].map((stat) => (
            <div key={stat.label} className="flex flex-col items-center gap-1">
              <span className="text-lg sm:text-xl font-bold text-brand-green">{stat.value}</span>
              <span className="text-[10px] sm:text-xs uppercase tracking-[0.15em]" style={{ color: "var(--text-muted)" }}>
                {stat.label}
              </span>
            </div>
          ))}
        </motion.div>
      </div>

      {/* Next slide indicator */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2, duration: 0.8 }}
        onClick={() => goToSlide(1)}
        className="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2"
        data-cursor-hover
        aria-label={t.hero.next || "Next section"}
      >
        <span className="text-[10px] uppercase tracking-[0.3em]" style={{ color: "var(--text-muted)" }}>
          {t.hero.next}
        </span>
        <motion.div
          animate={{ y: [0, 6, 0] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
        >
          <ChevronDown size={18} className="text-brand-green/60" />
        </motion.div>
      </motion.button>
    </section>
  );
}
