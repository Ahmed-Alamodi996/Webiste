"use client";

import { motion } from "framer-motion";
import {
  fadeInUp,
  slideInLeft,
  slideInRight,
  staggerContainer,
} from "@/lib/animations";
import AnimatedCounter from "@/components/ui/AnimatedCounter";

const stats = [
  { target: 12, suffix: "+", label: "Years of Excellence" },
  { target: 200, suffix: "+", label: "Projects Delivered" },
  { target: 85, suffix: "+", label: "Global Clients" },
  { target: 99, suffix: "%", label: "Client Satisfaction" },
];

export default function AboutUs() {
  return (
    <section id="about" className="relative section-padding overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-grid opacity-30" />
      <div className="gradient-blob absolute right-0 top-1/2 h-[500px] w-[500px] -translate-y-1/2 bg-accent/10" />

      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Split Layout */}
        <div className="grid items-center gap-16 lg:grid-cols-2">
          {/* Left - Typography */}
          <motion.div
            variants={slideInLeft}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
          >
            <span className="mb-4 inline-block text-sm font-medium tracking-wider text-primary uppercase">
              About Us
            </span>
            <h2 className="text-4xl font-bold leading-[1.1] tracking-tight md:text-5xl lg:text-6xl">
              We build what{" "}
              <span className="gradient-text">others imagine</span>
            </h2>
          </motion.div>

          {/* Right - Description */}
          <motion.div
            variants={slideInRight}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
          >
            <p className="text-lg leading-relaxed text-muted">
              Innovative Solutions Tech was founded with a singular vision: to
              bridge the gap between cutting-edge research and real-world
              application. Our team of elite engineers, architects, and
              strategists partner with forward-thinking organizations to build
              technology that doesn&apos;t just solve today&apos;s
              problems — it anticipates tomorrow&apos;s opportunities.
            </p>
            <p className="mt-4 text-lg leading-relaxed text-muted">
              From stealth startups to Fortune 500 enterprises, we deliver
              solutions with the precision of a research lab and the speed of a
              startup. Every line of code, every architecture decision, every
              deployment is engineered for impact.
            </p>
          </motion.div>
        </div>

        {/* Counters */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          className="mt-20 grid grid-cols-2 gap-8 rounded-2xl border border-white/[0.06] bg-surface/50 p-10 backdrop-blur-sm md:grid-cols-4"
        >
          {stats.map((stat) => (
            <AnimatedCounter key={stat.label} {...stat} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
