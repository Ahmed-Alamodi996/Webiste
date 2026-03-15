"use client";

import CustomCursor from "@/components/layout/CustomCursor";
import PageNavbar from "@/components/layout/PageNavbar";
import BlockRenderer from "@/components/blocks/BlockRenderer";
import { ThemeProvider } from "@/context/ThemeContext";
import { LanguageProvider } from "@/context/LanguageContext";
import type {
  PageBlock,
  CMSProject,
  CMSOffering,
  CMSService,
  CMSTechnology,
  CMSSiteContent,
} from "@/lib/cms-types";

interface PageLayoutProps {
  blocks: PageBlock[];
  siteContent: { en: CMSSiteContent; ar: CMSSiteContent } | null;
  projects?: CMSProject[];
  offerings?: CMSOffering[];
  services?: CMSService[];
  technologies?: CMSTechnology[];
}

export default function PageLayout({
  blocks,
  siteContent,
  projects,
  offerings,
  services,
  technologies,
}: PageLayoutProps) {
  return (
    <ThemeProvider>
      <LanguageProvider siteContent={siteContent}>
        <CustomCursor />
        <PageNavbar />
        <main className="pt-20">
          <BlockRenderer
            blocks={blocks}
            projects={projects}
            offerings={offerings}
            services={services}
            technologies={technologies}
          />
        </main>
      </LanguageProvider>
    </ThemeProvider>
  );
}
