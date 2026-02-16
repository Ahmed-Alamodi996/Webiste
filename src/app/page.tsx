"use client";

import dynamic from "next/dynamic";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import ScrollProgress from "@/components/layout/ScrollProgress";
import Hero from "@/components/sections/Hero";
import WhatWeOffer from "@/components/sections/WhatWeOffer";
import FeaturedProjects from "@/components/sections/FeaturedProjects";
import AboutUs from "@/components/sections/AboutUs";
import OurServices from "@/components/sections/OurServices";
import Technology from "@/components/sections/Technology";
import Contact from "@/components/sections/Contact";

const CustomCursor = dynamic(
  () => import("@/components/layout/CustomCursor"),
  { ssr: false }
);

const SmoothScroll = dynamic(
  () => import("@/components/layout/SmoothScroll"),
  { ssr: false }
);

export default function Home() {
  return (
    <SmoothScroll>
      <CustomCursor />
      <ScrollProgress />
      <div className="noise-overlay" />

      <Navbar />

      <main>
        <Hero />
        <WhatWeOffer />
        <FeaturedProjects />
        <AboutUs />
        <OurServices />
        <Technology />
        <Contact />
      </main>

      <Footer />
    </SmoothScroll>
  );
}
