"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";

interface TextRevealProps {
  children: string;
  className?: string;
  delay?: number;
  gradient?: boolean;
}

export default function TextReveal({
  children,
  className = "",
  delay = 0,
  gradient = false,
}: TextRevealProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const isInView = useInView(ref, { once: true, margin: "-50px" });

  const words = children.split(" ");

  return (
    <span ref={ref} className={`inline-flex flex-wrap ${className}`}>
      {words.map((word, i) => (
        <span key={i} className="overflow-hidden inline-block mr-[0.3em]">
          <motion.span
            initial={{ y: "110%", rotateX: -80 }}
            animate={isInView ? { y: "0%", rotateX: 0 } : {}}
            transition={{
              duration: 0.7,
              delay: delay + i * 0.06,
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
      ))}
    </span>
  );
}
