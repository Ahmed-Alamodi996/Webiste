"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import Image from "next/image";
import type { HeroBlockData, CMSMedia } from "@/lib/cms-types";

function isMedia(val: CMSMedia | string | undefined): val is CMSMedia {
  return typeof val === "object" && val !== null && "url" in val;
}

export default function PageHero({ block }: { block: HeroBlockData }) {
  const hasBg = isMedia(block.backgroundImage);

  return (
    <section className="relative min-h-[70vh] flex items-center justify-center overflow-hidden">
      {/* Background image */}
      {hasBg && (
        <Image
          src={(block.backgroundImage as CMSMedia).url}
          alt=""
          fill
          className="object-cover"
          priority
        />
      )}

      {/* Overlay */}
      <div
        className="absolute inset-0"
        style={{
          background: hasBg
            ? "linear-gradient(to bottom, rgba(0,0,0,0.6), rgba(0,0,0,0.8))"
            : "radial-gradient(ellipse 80% 60% at 50% 0%, var(--brand-green-dim) 0%, transparent 70%)",
        }}
      />

      {/* Top accent line */}
      <div
        className="absolute top-0 left-0 right-0 h-[2px]"
        style={{
          background:
            "linear-gradient(90deg, transparent, var(--brand-green), transparent)",
        }}
      />

      {/* Content */}
      <div className="relative z-10 max-w-5xl mx-auto px-6 py-24 text-center">
        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className="text-display-xl mb-6"
          style={{ color: hasBg ? "#fff" : "var(--text-primary)" }}
        >
          {block.heading}{" "}
          {block.headingAccent && (
            <span className="text-gradient">{block.headingAccent}</span>
          )}
        </motion.h1>

        {block.description && (
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.15, ease: [0.19, 1, 0.22, 1] }}
            className="text-body-lg max-w-2xl mx-auto mb-10"
            style={{
              color: hasBg ? "rgba(255,255,255,0.8)" : "var(--text-secondary)",
            }}
          >
            {block.description}
          </motion.p>
        )}

        {block.ctas && block.ctas.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3, ease: [0.19, 1, 0.22, 1] }}
            className="flex flex-wrap items-center justify-center gap-4"
          >
            {block.ctas.map((cta, i) => (
              <Link
                key={i}
                href={cta.href}
                data-cursor-hover
                className={
                  cta.variant === "secondary"
                    ? "px-6 py-3 rounded-full glass glow-border glow-border-hover text-sm font-medium transition-all duration-300"
                    : "px-6 py-3 rounded-full bg-gradient-accent text-white text-sm font-medium transition-all duration-300 hover:shadow-glow hover:scale-[1.02] active:scale-[0.98]"
                }
                style={
                  cta.variant === "secondary"
                    ? { color: hasBg ? "#fff" : "var(--text-primary)" }
                    : undefined
                }
              >
                {cta.label}
              </Link>
            ))}
          </motion.div>
        )}
      </div>
    </section>
  );
}
