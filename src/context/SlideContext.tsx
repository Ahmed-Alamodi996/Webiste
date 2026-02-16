"use client";

import { createContext, useContext, useState, useCallback, useRef, type ReactNode } from "react";

interface SlideContextType {
  currentSlide: number;
  totalSlides: number;
  goToSlide: (index: number) => void;
  nextSlide: () => void;
  prevSlide: () => void;
  isTransitioning: boolean;
}

const SlideContext = createContext<SlideContextType | null>(null);

export function useSlide() {
  const ctx = useContext(SlideContext);
  if (!ctx) throw new Error("useSlide must be used within SlideProvider");
  return ctx;
}

const TOTAL_SLIDES = 7;
const TRANSITION_COOLDOWN = 800;

export function SlideProvider({ children }: { children: ReactNode }) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false);
  const cooldownRef = useRef(false);

  const goToSlide = useCallback((index: number) => {
    if (cooldownRef.current) return;
    if (index < 0 || index >= TOTAL_SLIDES) return;
    if (index === currentSlide) return;

    cooldownRef.current = true;
    setIsTransitioning(true);
    setCurrentSlide(index);

    setTimeout(() => {
      cooldownRef.current = false;
      setIsTransitioning(false);
    }, TRANSITION_COOLDOWN);
  }, [currentSlide]);

  const nextSlide = useCallback(() => {
    goToSlide(currentSlide + 1);
  }, [currentSlide, goToSlide]);

  const prevSlide = useCallback(() => {
    goToSlide(currentSlide - 1);
  }, [currentSlide, goToSlide]);

  return (
    <SlideContext.Provider
      value={{ currentSlide, totalSlides: TOTAL_SLIDES, goToSlide, nextSlide, prevSlide, isTransitioning }}
    >
      {children}
    </SlideContext.Provider>
  );
}
