"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { fadeInUp, staggerContainer, staggerItem } from "@/lib/animations";
import { ChevronDown, ArrowRight } from "lucide-react";
import { cn } from "@/lib/utils";

const services = [
  {
    id: "custom-dev",
    title: "Custom Software Development",
    overview:
      "End-to-end software engineering from concept to deployment. We build bespoke solutions tailored to your unique business requirements with clean architecture and scalable foundations.",
    technologies: ["React", "Next.js", "Node.js", "Python", "Go", "PostgreSQL"],
    cta: "Start Your Project",
  },
  {
    id: "ai-solutions",
    title: "AI & Intelligent Automation",
    overview:
      "Harness the power of machine learning, NLP, and computer vision to automate workflows, extract insights, and create intelligent systems that learn and adapt.",
    technologies: ["TensorFlow", "PyTorch", "OpenAI", "LangChain", "Hugging Face", "CUDA"],
    cta: "Explore AI Solutions",
  },
  {
    id: "cloud-infra",
    title: "Cloud & DevOps Engineering",
    overview:
      "Design, migrate, and optimize cloud infrastructure for maximum performance, reliability, and cost efficiency. Full CI/CD pipelines and infrastructure-as-code.",
    technologies: ["AWS", "GCP", "Azure", "Kubernetes", "Docker", "Terraform"],
    cta: "Optimize Your Cloud",
  },
  {
    id: "data-eng",
    title: "Data Engineering & Analytics",
    overview:
      "Build robust data pipelines, warehouses, and real-time analytics platforms that turn your data into a competitive advantage with actionable insights.",
    technologies: ["Spark", "Kafka", "Snowflake", "dbt", "Airflow", "BigQuery"],
    cta: "Unlock Your Data",
  },
  {
    id: "security",
    title: "Security & Compliance",
    overview:
      "Comprehensive security audits, penetration testing, and compliance frameworks. We protect your digital assets with defense-in-depth strategies.",
    technologies: ["SOC 2", "ISO 27001", "OWASP", "Zero Trust", "SIEM", "IAM"],
    cta: "Secure Your Systems",
  },
];

export default function OurServices() {
  const [openId, setOpenId] = useState<string | null>("custom-dev");

  return (
    <section id="services" className="relative section-padding overflow-hidden">
      <div className="gradient-blob absolute -left-40 top-1/2 h-[400px] w-[400px] -translate-y-1/2 bg-primary/8" />

      <div className="mx-auto max-w-4xl px-6 lg:px-8">
        {/* Header */}
        <motion.div
          variants={fadeInUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          className="mb-16 text-center"
        >
          <span className="mb-4 inline-block text-sm font-medium tracking-wider text-primary uppercase">
            Our Services
          </span>
          <h2 className="text-3xl font-bold tracking-tight md:text-5xl">
            Expertise across the{" "}
            <span className="gradient-text">full spectrum</span>
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg text-muted">
            Deep capabilities across every layer of the technology stack.
          </p>
        </motion.div>

        {/* Accordion */}
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          className="space-y-3"
        >
          {services.map((service) => {
            const isOpen = openId === service.id;

            return (
              <motion.div
                key={service.id}
                variants={staggerItem}
                className={cn(
                  "overflow-hidden rounded-xl border transition-colors duration-300",
                  isOpen
                    ? "border-primary/20 bg-surface"
                    : "border-white/[0.06] bg-surface/30"
                )}
              >
                <button
                  onClick={() => setOpenId(isOpen ? null : service.id)}
                  className="flex w-full items-center justify-between px-6 py-5 text-left"
                >
                  <span
                    className={cn(
                      "text-lg font-semibold transition-colors",
                      isOpen ? "text-foreground" : "text-muted"
                    )}
                  >
                    {service.title}
                  </span>
                  <motion.div
                    animate={{ rotate: isOpen ? 180 : 0 }}
                    transition={{ duration: 0.3, ease: "easeInOut" }}
                  >
                    <ChevronDown
                      className={cn(
                        "h-5 w-5 transition-colors",
                        isOpen ? "text-primary" : "text-muted"
                      )}
                    />
                  </motion.div>
                </button>

                <AnimatePresence>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.4, ease: [0.25, 0.46, 0.45, 0.94] }}
                    >
                      <div className="px-6 pb-6">
                        <p className="mb-4 text-sm leading-relaxed text-muted">
                          {service.overview}
                        </p>

                        {/* Tech tags */}
                        <div className="mb-5 flex flex-wrap gap-2">
                          {service.technologies.map((tech) => (
                            <span
                              key={tech}
                              className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-muted"
                            >
                              {tech}
                            </span>
                          ))}
                        </div>

                        {/* CTA */}
                        <a
                          href="#contact"
                          className="group inline-flex items-center gap-2 text-sm font-medium text-primary transition-colors hover:text-primary-dark"
                        >
                          {service.cta}
                          <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                        </a>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
