"use client";

import type {
  PageBlock,
  CMSProjectRaw,
  CMSOfferingRaw,
  CMSServiceRaw,
  CMSTechnology,
} from "@/lib/cms-types";

import PageHero from "./PageHero";
import RichTextSection from "./RichTextSection";
import PageFeaturedProjects from "./PageFeaturedProjects";
import PageServices from "./PageServices";
import PageOfferings from "./PageOfferings";
import PageTechnology from "./PageTechnology";
import PageContactForm from "./PageContactForm";
import CTASection from "./CTASection";
import ImageSection from "./ImageSection";
import Spacer from "./Spacer";

interface BlockRendererProps {
  blocks: PageBlock[];
  projects?: CMSProjectRaw[];
  offerings?: CMSOfferingRaw[];
  services?: CMSServiceRaw[];
  technologies?: CMSTechnology[];
}

export default function BlockRenderer({
  blocks,
  projects,
  offerings,
  services,
  technologies,
}: BlockRendererProps) {
  return (
    <>
      {blocks.map((block, index) => {
        const key = block.id || `block-${index}`;

        switch (block.blockType) {
          case "hero":
            return <PageHero key={key} block={block} />;
          case "richText":
            return <RichTextSection key={key} block={block} />;
          case "featuredProjects":
            return <PageFeaturedProjects key={key} projects={projects} />;
          case "services":
            return <PageServices key={key} services={services} />;
          case "offerings":
            return <PageOfferings key={key} offerings={offerings} />;
          case "technology":
            return <PageTechnology key={key} technologies={technologies} />;
          case "contactForm":
            return <PageContactForm key={key} block={block} />;
          case "cta":
            return <CTASection key={key} block={block} />;
          case "image":
            return <ImageSection key={key} block={block} />;
          case "spacer":
            return <Spacer key={key} block={block} />;
          default:
            return null;
        }
      })}
    </>
  );
}
