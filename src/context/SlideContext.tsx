"use client";

import { createContext, useContext, useState, useCallback, useRef, useEffect, type ReactNode } from "react";

type ViewMode = "slides" | "scroll";

interface SlideContextType {
  currentSlide: number;
  totalSlides: number;
  goToSlide: (index: number) => void;
  nextSlide: () => void;
  prevSlide: () => void;
  isTransitioning: boolean;
  viewMode: ViewMode;
  setViewMode: (mode: ViewMode) => void;
}

const SlideContext = createContext<SlideContextType | null>(null);

export function useSlide() {
  const ctx = useContext(SlideContext);
  if (!ctx) throw new Error("useSlide must be used within SlideProvider");
  return ctx;
}

const TOTAL_SLIDES = 7;
const TRANSITION_COOLDOWN = 800;

const HASH_TO_SLIDE: Record<string, number> = {
  hero: 0,
  offer: 1,
  projects: 2,
  about: 3,
  services: 4,
  technology: 5,
  contact: 6,
};

function getInitialSlide(): number {
  if (typeof window === "undefined") return 0;
  const hash = window.location.hash.replace("#", "");
  return HASH_TO_SLIDE[hash] ?? 0;
}

interface SlideProviderProps {
  children: ReactNode;
  defaultViewMode?: ViewMode;
}

export function SlideProvider({ children, defaultViewMode = "slides" }: SlideProviderProps) {
  const [currentSlide, setCurrentSlide] = useState(getInitialSlide);
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>(defaultViewMode);
  const cooldownRef = useRef(false);

  // Clear hash after initial read so it doesn't interfere with browser behavior
  useEffect(() => {
    if (window.location.hash) {
      window.history.replaceState(null, "", window.location.pathname);
    }
  }, []);

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
      value={{ currentSlide, totalSlides: TOTAL_SLIDES, goToSlide, nextSlide, prevSlide, isTransitioning, viewMode, setViewMode }}
    >
      {children}
    </SlideContext.Provider>
  );
}
