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
  CMSProjectRaw,
  CMSOfferingRaw,
  CMSServiceRaw,
  CMSTechnology,
  CMSSiteContent,
} from "@/lib/cms-types";
import { resolveProject, resolveOffering, resolveService } from "@/lib/cms-types";

interface HomeClientProps {
  siteContent: CMSSiteContent | { en: CMSSiteContent; ar: CMSSiteContent } | null;
  projects: CMSProjectRaw[];
  offerings: CMSOfferingRaw[];
  services: CMSServiceRaw[];
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
  const { t, locale } = useLanguage();
  const themeSettings = t.theme;

  // Resolve bilingual CMS data to current locale
  const resolvedProjects = projects.map((p) => resolveProject(p, locale));
  const resolvedOfferings = offerings.map((o) => resolveOffering(o, locale));
  const resolvedServices = services.map((s) => resolveService(s, locale));

  const handleLoadComplete = useCallback(() => {
    setIsLoaded(true);
  }, []);

  const slides = [
    <Hero key="hero" />,
    <WhatWeOffer key="offer" offerings={resolvedOfferings} />,
    <FeaturedProjects key="projects" projects={resolvedProjects} />,
    <AboutUs key="about" />,
    <OurServices key="services" services={resolvedServices} />,
    <Technology key="technology" technologies={technologies} />,
    <Contact key="contact" />,
  ];

  return (
    <ThemeProvider>
      <AnimatePresence mode="wait">
        {!isLoaded && <Preloader onComplete={handleLoadComplete} />}
      </AnimatePresence>

      <SlideProvider defaultViewMode={themeSettings?.defaultViewMode || "slides"}>
        {/* CMS-controlled effects (desktop only — mobile perf) */}
        {themeSettings?.enableCustomCursor !== false && (
          <div className="hidden md:block"><CustomCursor /></div>
        )}
        {themeSettings?.enableFloatingOrbs !== false && (
          <div className="hidden sm:block"><FloatingOrbs /></div>
        )}

        <div className={themeSettings?.enableNoiseTexture !== false ? "noise-overlay" : ""}>
          <Navbar />
          <main id="main-content" aria-busy={!isLoaded}>
            <div
              className={isLoaded ? "" : "preloader-hidden"}
              aria-hidden={!isLoaded}
            >
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
