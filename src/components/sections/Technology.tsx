"use client";

import { motion } from "framer-motion";
import { fadeInUp, staggerContainer } from "@/lib/animations";

const technologies = [
  { name: "React", color: "#61DAFB" },
  { name: "Next.js", color: "#FFFFFF" },
  { name: "Node.js", color: "#68A063" },
  { name: "Python", color: "#3776AB" },
  { name: "TensorFlow", color: "#FF6F00" },
  { name: "Kubernetes", color: "#326CE5" },
  { name: "AWS", color: "#FF9900" },
  { name: "PostgreSQL", color: "#336791" },
  { name: "Docker", color: "#2496ED" },
  { name: "Go", color: "#00ADD8" },
  { name: "GraphQL", color: "#E10098" },
  { name: "Redis", color: "#DC382D" },
  { name: "TypeScript", color: "#3178C6" },
  { name: "Rust", color: "#DEA584" },
  { name: "GCP", color: "#4285F4" },
  { name: "Kafka", color: "#231F20" },
];

function TechLogo({
  name,
  color,
  index,
}: {
  name: string;
  color: string;
  index: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{
        delay: index * 0.05,
        duration: 0.5,
        ease: [0.25, 0.46, 0.45, 0.94],
      }}
      whileHover={{
        y: -8,
        transition: { duration: 0.3, ease: "easeOut" },
      }}
      className="group relative flex flex-col items-center gap-3"
    >
      {/* Logo container */}
      <div className="relative flex h-20 w-20 items-center justify-center rounded-2xl border border-white/[0.06] bg-surface/50 transition-all duration-300 group-hover:border-white/20 group-hover:bg-surface md:h-24 md:w-24">
        {/* Glow effect */}
        <div
          className="absolute inset-0 rounded-2xl opacity-0 transition-opacity duration-300 group-hover:opacity-100"
          style={{
            boxShadow: `0 0 30px ${color}20, 0 0 60px ${color}10`,
          }}
        />
        {/* Text Logo */}
        <span
          className="relative z-10 text-xs font-bold tracking-wider opacity-60 transition-opacity duration-300 group-hover:opacity-100"
          style={{ color }}
        >
          {name.slice(0, 4).toUpperCase()}
        </span>
      </div>

      {/* Name */}
      <span className="text-xs text-muted/60 transition-colors duration-300 group-hover:text-muted">
        {name}
      </span>
    </motion.div>
  );
}

export default function Technology() {
  return (
    <section
      id="technology"
      className="relative section-padding overflow-hidden"
    >
      <div className="gradient-blob absolute left-1/2 top-0 h-[400px] w-[600px] -translate-x-1/2 bg-primary/5" />

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
            Technology Stack
          </span>
          <h2 className="text-3xl font-bold tracking-tight md:text-5xl">
            Powered by the{" "}
            <span className="gradient-text">best in class</span>
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg text-muted">
            We leverage industry-leading technologies to deliver exceptional
            results.
          </p>
        </motion.div>

        {/* Tech Grid */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          className="grid grid-cols-4 gap-6 sm:grid-cols-4 md:grid-cols-8 md:gap-8"
        >
          {technologies.map((tech, index) => (
            <TechLogo key={tech.name} {...tech} index={index} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
