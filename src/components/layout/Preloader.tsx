"use client";

import { useEffect, useState, useRef } from "react";
import { motion, AnimatePresence, useSpring, useTransform } from "framer-motion";
import { useLanguage } from "@/context/LanguageContext";
import LottiePlayer from "@/components/ui/LottiePlayer";

export default function Preloader({ onComplete }: { onComplete: () => void }) {
  const { t } = useLanguage();
  const lottieData = t.theme?.animations?.preloaderAnimation;
  const [progress, setProgress] = useState(0);
  const [phase, setPhase] = useState<"loading" | "reveal" | "done">("loading");
  const completedRef = useRef(false);

  // Spring-physics counter
  const springProgress = useSpring(0, { stiffness: 60, damping: 20, mass: 0.5 });
  const displayProgress = useTransform(springProgress, (v) => Math.round(v));
  const [counterDisplay, setCounterDisplay] = useState(0);

  useEffect(() => {
    const unsub = displayProgress.on("change", (v) => setCounterDisplay(v));
    return unsub;
  }, [displayProgress]);

  useEffect(() => {
    springProgress.set(progress);
  }, [progress, springProgress]);

  useEffect(() => {
    let current = 0;
    const interval = setInterval(() => {
      current += Math.random() * 15 + 4;
      if (current >= 100) {
        current = 100;
        clearInterval(interval);
        setProgress(100);
        setTimeout(() => setPhase("reveal"), 400);
        setTimeout(() => {
          if (!completedRef.current) {
            completedRef.current = true;
            setPhase("done");
            onComplete();
          }
        }, 1400);
      } else {
        setProgress(Math.floor(current));
      }
    }, 90);

    return () => clearInterval(interval);
  }, [onComplete]);

  return (
    <AnimatePresence>
      {phase !== "done" && (
        <motion.div
          exit={{ opacity: 0 }}
          transition={{ duration: 0.4, ease: [0.19, 1, 0.22, 1] }}
          className="fixed inset-0 z-[10000] flex flex-col items-center justify-center"
          style={{ backgroundColor: "var(--bg-secondary)" }}
          role="status"
          aria-live="polite"
          aria-label="Loading website"
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

          {/* SVG Stroke-Draw Logo */}
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
            {lottieData ? (
              <LottiePlayer
                animationData={lottieData}
                loop={false}
                className="w-24 h-24"
              />
            ) : (
              <div className="flex items-center gap-3">
                <motion.div
                  initial={{ width: 0, opacity: 0 }}
                  animate={{ width: 56, opacity: 1 }}
                  transition={{ duration: 0.6, delay: 0.2, ease: [0.19, 1, 0.22, 1] }}
                  className="h-14 rounded-xl bg-gradient-accent flex items-center justify-center overflow-hidden"
                >
                  <svg
                    width="32"
                    height="28"
                    viewBox="0 0 32 28"
                    fill="none"
                    className="relative z-10"
                  >
                    <motion.path
                      d="M5 4 L5 24"
                      stroke="white"
                      strokeWidth="3.5"
                      strokeLinecap="round"
                      initial={{ pathLength: 0 }}
                      animate={{ pathLength: 1 }}
                      transition={{ duration: 0.6, delay: 0.3, ease: [0.19, 1, 0.22, 1] }}
                    />
                    <motion.path
                      d="M13 24 L13 12 C13 7 18 5 22 5 C26 5 28 7 28 12 L28 24"
                      stroke="white"
                      strokeWidth="3.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      fill="none"
                      initial={{ pathLength: 0 }}
                      animate={{ pathLength: 1 }}
                      transition={{ duration: 0.8, delay: 0.6, ease: [0.19, 1, 0.22, 1] }}
                    />
                  </svg>
                </motion.div>
                <motion.span
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.5, delay: 0.8 }}
                  className="text-2xl font-semibold tracking-tight"
                  style={{ color: "var(--text-primary)" }}
                >
                  ST
                </motion.span>
              </div>
            )}
          </motion.div>

          {/* Progress bar */}
          <div
            className="w-48 h-[1px] rounded-full overflow-hidden mb-4"
            style={{ backgroundColor: "var(--border-color)" }}
          >
            <motion.div
              className="h-full bg-gradient-accent rounded-full"
              style={{ width: `${progress}%` }}
            />
          </div>

          {/* Spring-physics Counter */}
          <motion.span
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.4 }}
            className="text-xs font-mono tabular-nums"
            style={{ color: "var(--text-muted)" }}
          >
            {counterDisplay}%
          </motion.span>

          {/* Radial mask reveal — expanding circle from center */}
          {phase === "reveal" && (
            <motion.div
              initial={{ clipPath: "circle(0% at 50% 50%)" }}
              animate={{ clipPath: "circle(100% at 50% 50%)" }}
              transition={{ duration: 0.8, ease: [0.87, 0, 0.13, 1] }}
              className="absolute inset-0"
              style={{ backgroundColor: "var(--bg-primary)" }}
            />
          )}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
