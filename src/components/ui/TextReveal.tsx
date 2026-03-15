"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";

interface TextRevealProps {
  children: string;
  className?: string;
  delay?: number;
  gradient?: boolean;
  mode?: "word" | "char";
}

export default function TextReveal({
  children,
  className = "",
  delay = 0,
  gradient = false,
  mode = "word",
}: TextRevealProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const isInView = useInView(ref, { once: true, margin: "-50px" });

  // Character-level split with blur trails
  if (mode === "char") {
    const chars = children.split("");
    return (
      <span ref={ref} className={`inline ${className}`}>
        {chars.map((char, i) =>
          char === " " ? (
            <span key={i} className="inline-block" style={{ width: "0.25em" }}>
              {"\u00A0"}
            </span>
          ) : (
            <span key={i} className="inline-block overflow-hidden">
              <motion.span
                initial={{ y: "110%", opacity: 0, filter: "blur(8px)" }}
                animate={
                  isInView
                    ? { y: "0%", opacity: 1, filter: "blur(0px)" }
                    : {}
                }
                transition={{
                  duration: 0.5,
                  delay: delay + i * 0.02,
                  ease: [0.19, 1, 0.22, 1],
                }}
                className={`inline-block ${gradient ? "text-gradient" : ""}`}
              >
                {char}
              </motion.span>
            </span>
          )
        )}
      </span>
    );
  }

  // Default word-level mode with organic stagger
  const words = children.split(" ");
  return (
    <span ref={ref} className={`inline-flex flex-wrap ${className}`}>
      {words.map((word, i) => {
        // Organic stagger: slightly varied timing for natural feel
        const baseDelay = delay + i * 0.06;
        const jitter = (i % 3 === 0) ? 0.02 : (i % 3 === 1) ? -0.01 : 0;
        const wordDelay = baseDelay + jitter;
        const wordDuration = 0.7 + (i % 2 === 0 ? 0.05 : 0);

        return (
          <span key={i} className="overflow-hidden inline-block mr-[0.3em]">
            <motion.span
              initial={{ y: "110%", rotateX: -80, filter: "blur(4px)" }}
              animate={isInView ? { y: "0%", rotateX: 0, filter: "blur(0px)" } : {}}
              transition={{
                duration: wordDuration,
                delay: wordDelay,
                ease: [0.19, 1, 0.22, 1],
              }}
              className={`inline-block ${gradient ? "text-gradient" : ""}`}
              style={{
                transformOrigin: "bottom",
                perspective: "1000px",
              }}
            >
              {word}
            </motion.span>
          </span>
        );
      })}
    </span>
  );
}
