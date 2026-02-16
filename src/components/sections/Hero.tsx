"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { heroTextReveal, fadeInUp, staggerContainer } from "@/lib/animations";
import MagneticButton from "@/components/ui/MagneticButton";
import { ArrowDown, ArrowRight } from "lucide-react";

export default function Hero() {
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [0, 200]);
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0]);

  return (
    <section
      ref={containerRef}
      className="relative flex min-h-screen items-center justify-center overflow-hidden"
    >
      {/* Background Elements */}
      <div className="absolute inset-0 bg-grid opacity-40" />

      {/* Gradient Blobs */}
      <motion.div
        style={{ y: useTransform(scrollYProgress, [0, 1], [0, -100]) }}
        className="gradient-blob absolute -right-40 -top-40 h-[500px] w-[500px] bg-primary/20"
      />
      <motion.div
        style={{ y: useTransform(scrollYProgress, [0, 1], [0, -60]) }}
        className="gradient-blob absolute -bottom-40 -left-40 h-[600px] w-[600px] bg-accent/15"
      />
      <motion.div
        className="gradient-blob absolute left-1/2 top-1/3 h-[300px] w-[300px] -translate-x-1/2 bg-primary/10 animate-pulse-glow"
      />

      {/* Grid Pattern Overlay */}
      <div className="absolute inset-0">
        <svg className="h-full w-full opacity-[0.03]" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="hero-grid" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
              <circle cx="1" cy="1" r="1" fill="white" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#hero-grid)" />
        </svg>
      </div>

      {/* Content */}
      <motion.div
        style={{ y, opacity }}
        className="relative z-10 mx-auto max-w-6xl px-6 text-center"
      >
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          animate="visible"
        >
          {/* Badge */}
          <motion.div variants={fadeInUp} className="mb-8 flex justify-center">
            <div className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-sm text-muted backdrop-blur-sm">
              <span className="h-1.5 w-1.5 rounded-full bg-primary animate-pulse" />
              Now pioneering next-gen AI infrastructure
            </div>
          </motion.div>

          {/* Headline */}
          <motion.h1
            variants={heroTextReveal}
            className="mx-auto max-w-5xl text-5xl font-bold leading-[1.1] tracking-tight sm:text-6xl md:text-7xl lg:text-8xl"
          >
            Engineering the{" "}
            <span className="gradient-text">Future</span> of Intelligent
            Solutions
          </motion.h1>

          {/* Subtext */}
          <motion.p
            variants={fadeInUp}
            className="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-muted md:text-xl"
          >
            We architect cutting-edge technology platforms that redefine
            what&apos;s possible. From AI-powered systems to scalable cloud
            infrastructure — we build the backbone of tomorrow.
          </motion.p>

          {/* CTAs */}
          <motion.div
            variants={fadeInUp}
            className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row"
          >
            <MagneticButton
              href="#solutions"
              className="bg-gradient-to-r from-primary to-accent px-8 py-3.5 text-sm text-white shadow-[0_0_30px_rgba(0,200,150,0.2)] hover:shadow-[0_0_50px_rgba(0,200,150,0.35)]"
            >
              Explore Solutions
              <ArrowRight className="ml-2 h-4 w-4" />
            </MagneticButton>
            <MagneticButton
              href="#contact"
              className="border border-white/10 bg-white/5 px-8 py-3.5 text-sm text-foreground backdrop-blur-sm hover:border-white/20 hover:bg-white/10"
            >
              Get in Touch
            </MagneticButton>
          </motion.div>
        </motion.div>
      </motion.div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.5, duration: 0.8 }}
        className="absolute bottom-10 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          className="flex flex-col items-center gap-2"
        >
          <span className="text-xs tracking-widest text-muted/60 uppercase">
            Scroll
          </span>
          <ArrowDown className="h-4 w-4 text-muted/40" />
        </motion.div>
      </motion.div>
    </section>
  );
}
