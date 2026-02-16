"use client";

import { useRef } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { staggerContainer, staggerItem, fadeInUp } from "@/lib/animations";
import {
  Brain,
  Cloud,
  Globe,
  Shield,
  Zap,
  Layers,
} from "lucide-react";

const offerings = [
  {
    icon: Brain,
    title: "AI & Machine Learning",
    description:
      "Custom AI solutions that transform raw data into strategic advantage with state-of-the-art models.",
  },
  {
    icon: Cloud,
    title: "Cloud Architecture",
    description:
      "Resilient, auto-scaling cloud infrastructure designed for peak performance and zero downtime.",
  },
  {
    icon: Globe,
    title: "Web Platforms",
    description:
      "High-performance web applications built with modern frameworks for seamless user experiences.",
  },
  {
    icon: Shield,
    title: "Cybersecurity",
    description:
      "Enterprise-grade security systems that protect your digital assets with proactive threat defense.",
  },
  {
    icon: Zap,
    title: "Performance Engineering",
    description:
      "Optimization at every layer — from database queries to edge delivery for sub-second response times.",
  },
  {
    icon: Layers,
    title: "System Integration",
    description:
      "Seamless integration of complex systems, APIs, and microservices into unified architectures.",
  },
];

function OfferCard({
  icon: Icon,
  title,
  description,
}: (typeof offerings)[0]) {
  const cardRef = useRef<HTMLDivElement>(null);
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const rotateX = useSpring(useTransform(mouseY, [-0.5, 0.5], [5, -5]), {
    stiffness: 300,
    damping: 30,
  });
  const rotateY = useSpring(useTransform(mouseX, [-0.5, 0.5], [-5, 5]), {
    stiffness: 300,
    damping: 30,
  });

  const handleMouse = (e: React.MouseEvent) => {
    const rect = cardRef.current?.getBoundingClientRect();
    if (!rect) return;
    mouseX.set((e.clientX - rect.left) / rect.width - 0.5);
    mouseY.set((e.clientY - rect.top) / rect.height - 0.5);
  };

  const resetMouse = () => {
    mouseX.set(0);
    mouseY.set(0);
  };

  return (
    <motion.div
      ref={cardRef}
      variants={staggerItem}
      onMouseMove={handleMouse}
      onMouseLeave={resetMouse}
      style={{ rotateX, rotateY, transformPerspective: 800 }}
      className="group relative rounded-2xl border border-white/[0.06] bg-surface/50 p-8 backdrop-blur-sm transition-colors duration-500 hover:border-primary/20 hover:bg-surface"
    >
      {/* Glow on hover */}
      <div className="absolute inset-0 rounded-2xl opacity-0 transition-opacity duration-500 group-hover:opacity-100"
        style={{
          background:
            "radial-gradient(400px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(0,200,150,0.06), transparent 60%)",
        }}
      />

      <div className="relative z-10">
        <div className="mb-5 inline-flex rounded-xl bg-gradient-to-br from-primary/10 to-accent/10 p-3">
          <Icon className="h-6 w-6 text-primary" strokeWidth={1.5} />
        </div>
        <h3 className="mb-3 text-lg font-semibold tracking-tight">
          {title}
        </h3>
        <p className="text-sm leading-relaxed text-muted">{description}</p>
      </div>
    </motion.div>
  );
}

export default function WhatWeOffer() {
  return (
    <section id="solutions" className="relative section-padding overflow-hidden">
      {/* Background */}
      <div className="gradient-blob absolute -right-60 top-0 h-[500px] w-[500px] bg-accent/10" />

      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Header */}
        <motion.div
          variants={fadeInUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          className="mb-16 max-w-2xl"
        >
          <span className="mb-4 inline-block text-sm font-medium tracking-wider text-primary uppercase">
            What We Offer
          </span>
          <h2 className="text-3xl font-bold tracking-tight md:text-5xl">
            Solutions that drive{" "}
            <span className="gradient-text">real impact</span>
          </h2>
          <p className="mt-4 text-lg text-muted">
            We deliver end-to-end technology services with deep expertise across
            the modern stack.
          </p>
        </motion.div>

        {/* Cards Grid */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
        >
          {offerings.map((offering) => (
            <OfferCard key={offering.title} {...offering} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
