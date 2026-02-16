"use client";

import { useState, useCallback } from "react";
import { AnimatePresence } from "framer-motion";
import CustomCursor from "@/components/layout/CustomCursor";
import Navbar from "@/components/layout/Navbar";
import Preloader from "@/components/layout/Preloader";
import SlideContainer from "@/components/layout/SlideContainer";
import { SlideProvider } from "@/context/SlideContext";
import { ThemeProvider } from "@/context/ThemeContext";
import { LanguageProvider } from "@/context/LanguageContext";
import Hero from "@/components/sections/Hero";
import WhatWeOffer from "@/components/sections/WhatWeOffer";
import FeaturedProjects from "@/components/sections/FeaturedProjects";
import AboutUs from "@/components/sections/AboutUs";
import OurServices from "@/components/sections/OurServices";
import Technology from "@/components/sections/Technology";
import Contact from "@/components/sections/Contact";
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

export default function HomeClient({
  siteContent,
  projects,
  offerings,
  services,
  technologies,
}: HomeClientProps) {
  const [isLoaded, setIsLoaded] = useState(false);

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
      <LanguageProvider siteContent={siteContent}>
        <AnimatePresence mode="wait">
          {!isLoaded && <Preloader onComplete={handleLoadComplete} />}
        </AnimatePresence>

        <SlideProvider>
          <CustomCursor />
          <Navbar />
          <SlideContainer slides={slides} />
        </SlideProvider>
      </LanguageProvider>
    </ThemeProvider>
  );
}
