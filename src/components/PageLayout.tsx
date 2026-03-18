"use client";

import CustomCursor from "@/components/layout/CustomCursor";
import PageNavbar from "@/components/layout/PageNavbar";
import BlockRenderer from "@/components/blocks/BlockRenderer";
import { ThemeProvider } from "@/context/ThemeContext";
import { LanguageProvider } from "@/context/LanguageContext";
import type {
  PageBlock,
  CMSProjectRaw,
  CMSOfferingRaw,
  CMSServiceRaw,
  CMSTechnology,
  CMSSiteContent,
} from "@/lib/cms-types";

interface PageLayoutProps {
  blocks: PageBlock[];
  siteContent: { en: CMSSiteContent; ar: CMSSiteContent } | CMSSiteContent | null;
  projects?: CMSProjectRaw[];
  offerings?: CMSOfferingRaw[];
  services?: CMSServiceRaw[];
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
