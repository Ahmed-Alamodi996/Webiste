"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import type { CTABlockData } from "@/lib/cms-types";

export default function CTASection({ block }: { block: CTABlockData }) {
  const isGlass = block.style === "glass";

  return (
    <section className="py-20 px-6">
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ duration: 0.7, ease: [0.19, 1, 0.22, 1] }}
        className={`max-w-4xl mx-auto rounded-3xl p-6 sm:p-12 md:p-16 text-center relative overflow-hidden ${
          isGlass ? "glass glow-border" : ""
        }`}
        style={
          isGlass
            ? undefined
            : {
                background:
                  "linear-gradient(135deg, var(--brand-green), var(--brand-green-dim))",
              }
        }
      >
        {/* Grid overlay */}
        <div className="absolute inset-0 bg-grid-dense opacity-10 pointer-events-none" />

        <div className="relative z-10">
          <h2
            className="text-display mb-4"
            style={{
              color: isGlass ? "var(--text-primary)" : "#fff",
            }}
          >
            {block.heading}
          </h2>

          {block.description && (
            <p
              className="text-body-lg max-w-2xl mx-auto mb-8"
              style={{
                color: isGlass ? "var(--text-secondary)" : "rgba(255,255,255,0.85)",
              }}
            >
              {block.description}
            </p>
          )}

          <Link
            href={block.buttonHref}
            data-cursor-hover
            className={`inline-flex items-center gap-2 px-8 py-4 rounded-full text-sm font-medium transition-all duration-300 hover:scale-[1.02] active:scale-[0.98] ${
              isGlass
                ? "bg-gradient-accent text-white hover:shadow-glow"
                : "bg-white text-gray-900 hover:bg-gray-100"
            }`}
          >
            {block.buttonLabel}
            <ArrowRight size={16} />
          </Link>
        </div>
      </motion.div>
    </section>
  );
}
