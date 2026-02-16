"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function Preloader({ onComplete }: { onComplete: () => void }) {
  const [progress, setProgress] = useState(0);
  const [phase, setPhase] = useState<"loading" | "reveal" | "done">("loading");

  useEffect(() => {
    // Simulate loading with eased progress
    let current = 0;
    const interval = setInterval(() => {
      current += Math.random() * 12 + 3;
      if (current >= 100) {
        current = 100;
        clearInterval(interval);
        setProgress(100);
        setTimeout(() => setPhase("reveal"), 300);
        setTimeout(() => {
          setPhase("done");
          onComplete();
        }, 1200);
      } else {
        setProgress(Math.floor(current));
      }
    }, 80);

    return () => clearInterval(interval);
  }, [onComplete]);

  return (
    <AnimatePresence>
      {phase !== "done" && (
        <motion.div
          exit={{ opacity: 0 }}
          transition={{ duration: 0.5, ease: [0.19, 1, 0.22, 1] }}
          className="fixed inset-0 z-[10000] flex flex-col items-center justify-center"
          style={{ backgroundColor: "var(--bg-secondary)" }}
        >
          {/* Background pulse */}
          <div className="absolute inset-0 overflow-hidden">
            <motion.div
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.03, 0.06, 0.03],
              }}
              transition={{ duration: 3, repeat: Infinity }}
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] rounded-full bg-brand-green blur-[200px]"
            />
          </div>

          {/* Logo reveal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={
              phase === "reveal"
                ? { opacity: 1, scale: 1.1, y: -20 }
                : { opacity: 1, scale: 1 }
            }
            transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
            className="relative mb-12"
          >
            {/* Logo */}
            <div className="flex items-center gap-3">
              <motion.div
                initial={{ width: 0, opacity: 0 }}
                animate={{ width: 48, opacity: 1 }}
                transition={{ duration: 0.6, delay: 0.2, ease: [0.19, 1, 0.22, 1] }}
                className="h-12 rounded-xl bg-gradient-accent flex items-center justify-center overflow-hidden"
              >
                <span className="text-white font-bold text-lg">In</span>
              </motion.div>
              <motion.span
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.5, delay: 0.5 }}
                className="text-2xl font-semibold tracking-tight"
                style={{ color: "var(--text-primary)" }}
              >
                ST
              </motion.span>
            </div>
          </motion.div>

          {/* Progress bar */}
          <div
            className="w-48 h-[1px] rounded-full overflow-hidden mb-4"
            style={{ backgroundColor: "var(--border-color)" }}
          >
            <motion.div
              className="h-full bg-gradient-accent rounded-full"
              initial={{ width: "0%" }}
              animate={{ width: `${progress}%` }}
              transition={{ duration: 0.1 }}
            />
          </div>

          {/* Counter */}
          <motion.span
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.4 }}
            className="text-xs font-mono tabular-nums"
            style={{ color: "var(--text-muted)" }}
          >
            {progress}%
          </motion.span>

          {/* Reveal curtains */}
          {phase === "reveal" && (
            <>
              <motion.div
                initial={{ scaleY: 0 }}
                animate={{ scaleY: 1 }}
                transition={{ duration: 0.6, ease: [0.87, 0, 0.13, 1] }}
                className="absolute top-0 left-0 right-0 h-1/2 origin-top"
                style={{ backgroundColor: "var(--bg-primary)" }}
              />
              <motion.div
                initial={{ scaleY: 0 }}
                animate={{ scaleY: 1 }}
                transition={{ duration: 0.6, ease: [0.87, 0, 0.13, 1] }}
                className="absolute bottom-0 left-0 right-0 h-1/2 origin-bottom"
                style={{ backgroundColor: "var(--bg-primary)" }}
              />
            </>
          )}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
