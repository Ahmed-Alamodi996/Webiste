"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { fadeInUp, staggerContainer, staggerItem } from "@/lib/animations";
import { ArrowRight } from "lucide-react";

const projects = [
  {
    title: "NeuralFlow Platform",
    category: "AI / Machine Learning",
    description:
      "An enterprise AI orchestration platform processing 10M+ predictions daily with 99.99% uptime across distributed GPU clusters.",
    gradient: "from-primary/20 to-accent/20",
    accent: "bg-primary",
  },
  {
    title: "CloudMatrix",
    category: "Cloud Infrastructure",
    description:
      "Multi-region cloud architecture serving 50M+ users with auto-scaling, edge caching, and real-time failover capabilities.",
    gradient: "from-accent/20 to-purple-500/20",
    accent: "bg-accent",
  },
  {
    title: "SecureVault Pro",
    category: "Cybersecurity",
    description:
      "Zero-trust security framework protecting Fortune 500 financial data with AI-driven threat detection and response.",
    gradient: "from-emerald-500/20 to-primary/20",
    accent: "bg-emerald-500",
  },
  {
    title: "DataStream Engine",
    category: "Data Engineering",
    description:
      "Real-time data pipeline processing 1TB+ daily with sub-millisecond latency for financial trading systems.",
    gradient: "from-purple-500/20 to-pink-500/20",
    accent: "bg-purple-500",
  },
];

function ProjectCard({
  project,
  index,
}: {
  project: (typeof projects)[0];
  index: number;
}) {
  const cardRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: cardRef,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [60, -60]);

  return (
    <motion.div
      ref={cardRef}
      variants={staggerItem}
      className="group relative"
    >
      <motion.div
        style={{ y: index % 2 === 0 ? y : undefined }}
        className="relative overflow-hidden rounded-2xl border border-white/[0.06]"
      >
        {/* Project Image Placeholder */}
        <div
          className={`relative aspect-[4/3] bg-gradient-to-br ${project.gradient} flex items-center justify-center overflow-hidden`}
        >
          {/* Abstract geometric pattern */}
          <div className="absolute inset-0 bg-grid opacity-30" />
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="grid grid-cols-3 gap-3 p-8 opacity-20">
              {Array.from({ length: 9 }).map((_, i) => (
                <div
                  key={i}
                  className={`h-12 w-12 rounded-lg ${project.accent}/30 md:h-16 md:w-16`}
                  style={{
                    animationDelay: `${i * 0.1}s`,
                    opacity: 0.3 + (i * 0.08),
                  }}
                />
              ))}
            </div>
          </div>

          {/* Overlay on hover */}
          <div className="absolute inset-0 bg-background/60 opacity-0 transition-opacity duration-500 group-hover:opacity-100" />

          {/* View Case Study button */}
          <div className="absolute inset-0 flex items-center justify-center opacity-0 transition-all duration-500 group-hover:opacity-100">
            <span className="inline-flex items-center gap-2 rounded-full bg-white/10 px-6 py-3 text-sm font-medium backdrop-blur-md transition-transform duration-300 group-hover:scale-105">
              View Case Study
              <ArrowRight className="h-4 w-4" />
            </span>
          </div>
        </div>

        {/* Info */}
        <div className="glass p-6">
          <div className="mb-3 flex items-center gap-2">
            <span className={`h-1.5 w-1.5 rounded-full ${project.accent}`} />
            <span className="text-xs font-medium tracking-wider text-muted uppercase">
              {project.category}
            </span>
          </div>
          <h3 className="mb-2 text-xl font-semibold tracking-tight">
            {project.title}
          </h3>
          <p className="text-sm leading-relaxed text-muted">
            {project.description}
          </p>
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function FeaturedProjects() {
  return (
    <section id="projects" className="relative section-padding overflow-hidden">
      <div className="gradient-blob absolute -left-60 bottom-0 h-[400px] w-[400px] bg-primary/10" />

      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Header */}
        <motion.div
          variants={fadeInUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          className="mb-16 text-center"
        >
          <span className="mb-4 inline-block text-sm font-medium tracking-wider text-primary uppercase">
            Featured Projects
          </span>
          <h2 className="text-3xl font-bold tracking-tight md:text-5xl">
            Work that <span className="gradient-text">speaks volumes</span>
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg text-muted">
            Showcasing our most impactful solutions across industries.
          </p>
        </motion.div>

        {/* Project Grid */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          className="grid gap-8 md:grid-cols-2"
        >
          {projects.map((project, index) => (
            <ProjectCard key={project.title} project={project} index={index} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
