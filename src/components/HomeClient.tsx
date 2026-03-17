"use client";

import { useState, useCallback } from "react";
import { AnimatePresence } from "framer-motion";
import CustomCursor from "@/components/layout/CustomCursor";
import Navbar from "@/components/layout/Navbar";
import Preloader from "@/components/layout/Preloader";
import SlideContainer from "@/components/layout/SlideContainer";
import FloatingOrbs from "@/components/ui/FloatingOrbs";
import { SlideProvider } from "@/context/SlideContext";
import { ThemeProvider } from "@/context/ThemeContext";
import { LanguageProvider, useLanguage } from "@/context/LanguageContext";
import Hero from "@/components/sections/Hero";
import WhatWeOffer from "@/components/sections/WhatWeOffer";
import FeaturedProjects from "@/components/sections/FeaturedProjects";
import AboutUs from "@/components/sections/AboutUs";
import OurServices from "@/components/sections/OurServices";
import Technology from "@/components/sections/Technology";
import Contact from "@/components/sections/Contact";
import ErrorBoundary from "@/components/ErrorBoundary";
import type {
  CMSProject,
  CMSOffering,
  CMSService,
  CMSTechnology,
  CMSSiteContent,
} from "@/lib/cms-types";

interface HomeClientProps {
  siteContent: { en: CMSSiteContent; ar: CMSSiteContent } | null;
  projects: CMSProject[];
  offerings: CMSOffering[];
  services: CMSService[];
  technologies: CMSTechnology[];
}

/** Inner component that has access to LanguageContext */
function HomeInner({
  projects,
  offerings,
  services,
  technologies,
}: Omit<HomeClientProps, "siteContent">) {
  const [isLoaded, setIsLoaded] = useState(false);
  const { t } = useLanguage();
  const themeSettings = t.theme;

  const handleLoadComplete = useCallback(() => {
    setIsLoaded(true);
  }, []);

  const slides = [
    <Hero key="hero" />,
    <WhatWeOffer key="offer" offerings={offerings} />,
    <FeaturedProjects key="projects" projects={projects} />,
    <AboutUs key="about" />,
    <OurServices key="services" services={services} />,
    <Technology key="technology" technologies={technologies} />,
    <Contact key="contact" />,
  ];

  return (
    <ThemeProvider>
      <AnimatePresence mode="wait">
        {!isLoaded && <Preloader onComplete={handleLoadComplete} />}
      </AnimatePresence>

      <SlideProvider defaultViewMode={themeSettings?.defaultViewMode || "slides"}>
        {/* CMS-controlled effects */}
        {themeSettings?.enableCustomCursor !== false && <CustomCursor />}
        {themeSettings?.enableFloatingOrbs !== false && <FloatingOrbs />}

        <div className={themeSettings?.enableNoiseTexture !== false ? "noise-overlay" : ""}>
          <Navbar />
          <main id="main-content" aria-busy={!isLoaded}>
            <div style={isLoaded ? undefined : { opacity: 0, position: "fixed", pointerEvents: "none" }}>
              <SlideContainer slides={slides} />
            </div>
          </main>
        </div>
      </SlideProvider>
    </ThemeProvider>
  );
}

export default function HomeClient({
  siteContent,
  projects,
  offerings,
  services,
  technologies,
}: HomeClientProps) {
  return (
    <ErrorBoundary>
      <LanguageProvider siteContent={siteContent}>
        <HomeInner
          projects={projects}
          offerings={offerings}
          services={services}
          technologies={technologies}
        />
      </LanguageProvider>
    </ErrorBoundary>
  );
}
