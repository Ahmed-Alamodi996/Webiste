"use client";

import {
  createContext,
  useContext,
  useState,
  useCallback,
  useEffect,
  type ReactNode,
} from "react";
import { locales, isRTL as checkRTL, type Locale, type Translations } from "@/locales";
import type { CMSSiteContent } from "@/lib/cms-types";

interface LanguageContextType {
  locale: Locale;
  t: Translations;
  setLocale: (locale: Locale) => void;
  dir: "ltr" | "rtl";
  isRTL: boolean;
}

const LanguageContext = createContext<LanguageContextType | null>(null);

export function useLanguage() {
  const ctx = useContext(LanguageContext);
  if (!ctx) throw new Error("useLanguage must be used within LanguageProvider");
  return ctx;
}

/**
 * Build a Translations object from CMS SiteContent data.
 * Falls back to static locale data for any missing fields.
 */
function buildTranslations(
  cms: CMSSiteContent | undefined,
  fallback: Translations
): Translations {
  if (!cms) return fallback;

  return {
    nav: {
      services: cms.nav?.services ?? fallback.nav.services,
      projects: cms.nav?.projects ?? fallback.nav.projects,
      about: cms.nav?.about ?? fallback.nav.about,
      technology: cms.nav?.technology ?? fallback.nav.technology,
      contact: cms.nav?.contact ?? fallback.nav.contact,
      getInTouch: cms.nav?.getInTouch ?? fallback.nav.getInTouch,
    },
    hero: {
      tagline: cms.hero?.tagline ?? fallback.hero.tagline,
      headlineLine1: cms.hero?.headlineLine1?.length
        ? cms.hero.headlineLine1.map((w) => w.word)
        : fallback.hero.headlineLine1,
      headlineLine2: cms.hero?.headlineLine2?.length
        ? cms.hero.headlineLine2.map((w) => w.word)
        : fallback.hero.headlineLine2,
      description: cms.hero?.description ?? fallback.hero.description,
      exploreSolutions: cms.hero?.exploreSolutions ?? fallback.hero.exploreSolutions,
      getInTouch: cms.hero?.getInTouch ?? fallback.hero.getInTouch,
      trustedBy: cms.hero?.trustedBy ?? fallback.hero.trustedBy,
      statsProjects: cms.hero?.statsProjects ?? fallback.hero.statsProjects,
      statsUptime: cms.hero?.statsUptime ?? fallback.hero.statsUptime,
      statsSupport: cms.hero?.statsSupport ?? fallback.hero.statsSupport,
      next: cms.hero?.next ?? fallback.hero.next,
    },
    about: {
      label: cms.about?.label ?? fallback.about.label,
      headingLine1: cms.about?.headingLine1 ?? fallback.about.headingLine1,
      headingWord1: cms.about?.headingWord1 ?? fallback.about.headingWord1,
      headingLine2: cms.about?.headingLine2 ?? fallback.about.headingLine2,
      headingWord2: cms.about?.headingWord2 ?? fallback.about.headingWord2,
      paragraph1: cms.about?.paragraph1 ?? fallback.about.paragraph1,
      paragraph2: cms.about?.paragraph2 ?? fallback.about.paragraph2,
      stats: cms.about?.stats?.length
        ? cms.about.stats.map((s) => ({
            target: s.target,
            suffix: s.suffix,
            label: s.label,
          }))
        : fallback.about.stats,
    },
    offer: {
      label: cms.offer?.label ?? fallback.offer.label,
      heading: cms.offer?.heading ?? fallback.offer.heading,
      headingAccent: cms.offer?.headingAccent ?? fallback.offer.headingAccent,
      description: cms.offer?.description ?? fallback.offer.description,
      // Items come from the Offerings collection, not from SiteContent.
      // We preserve the static items here as fallback — HomeClient passes
      // offerings as a separate prop to WhatWeOffer.
      items: fallback.offer.items,
    },
    services: {
      label: cms.services?.label ?? fallback.services.label,
      heading: cms.services?.heading ?? fallback.services.heading,
      headingAccent: cms.services?.headingAccent ?? fallback.services.headingAccent,
      description: cms.services?.description ?? fallback.services.description,
      learnMore: cms.services?.learnMore ?? fallback.services.learnMore,
      // Items come from Services collection
      items: fallback.services.items,
    },
    projects: {
      label: cms.projects?.label ?? fallback.projects.label,
      heading: cms.projects?.heading ?? fallback.projects.heading,
      headingAccent: cms.projects?.headingAccent ?? fallback.projects.headingAccent,
      description: cms.projects?.description ?? fallback.projects.description,
      viewCaseStudy: cms.projects?.viewCaseStudy ?? fallback.projects.viewCaseStudy,
      // Items come from Projects collection
      items: fallback.projects.items,
    },
    technology: {
      label: cms.technology?.label ?? fallback.technology.label,
      heading: cms.technology?.heading ?? fallback.technology.heading,
      headingAccent: cms.technology?.headingAccent ?? fallback.technology.headingAccent,
      description: cms.technology?.description ?? fallback.technology.description,
    },
    contact: {
      label: cms.contact?.label ?? fallback.contact.label,
      heading: cms.contact?.heading ?? fallback.contact.heading,
      headingAccent: cms.contact?.headingAccent ?? fallback.contact.headingAccent,
      description: cms.contact?.description ?? fallback.contact.description,
      features: cms.contact?.features?.length
        ? cms.contact.features.map((f) => f.text)
        : fallback.contact.features,
      form: {
        name: cms.contact?.form?.name ?? fallback.contact.form.name,
        namePlaceholder: cms.contact?.form?.namePlaceholder ?? fallback.contact.form.namePlaceholder,
        email: cms.contact?.form?.email ?? fallback.contact.form.email,
        emailPlaceholder: cms.contact?.form?.emailPlaceholder ?? fallback.contact.form.emailPlaceholder,
        message: cms.contact?.form?.message ?? fallback.contact.form.message,
        messagePlaceholder: cms.contact?.form?.messagePlaceholder ?? fallback.contact.form.messagePlaceholder,
        send: cms.contact?.form?.send ?? fallback.contact.form.send,
        successTitle: cms.contact?.form?.successTitle ?? fallback.contact.form.successTitle,
        successMessage: cms.contact?.form?.successMessage ?? fallback.contact.form.successMessage,
      },
    },
    theme: {
      brandPrimary: cms.theme?.brandPrimary ?? fallback.theme?.brandPrimary ?? "#00C896",
      brandSecondary: cms.theme?.brandSecondary ?? fallback.theme?.brandSecondary ?? "#2563EB",
      gradientAngle: cms.theme?.gradientAngle ?? fallback.theme?.gradientAngle ?? 135,
      defaultTheme: (cms.theme?.defaultTheme ?? fallback.theme?.defaultTheme ?? "dark") as "dark" | "light",
      defaultViewMode: (cms.theme?.defaultViewMode ?? fallback.theme?.defaultViewMode ?? "slides") as "slides" | "scroll",
      animationSpeed: (cms.theme?.animationSpeed ?? fallback.theme?.animationSpeed ?? "normal") as "fast" | "normal" | "slow",
      enableParticles: cms.theme?.enableParticles ?? fallback.theme?.enableParticles ?? true,
      enableAurora: cms.theme?.enableAurora ?? fallback.theme?.enableAurora ?? true,
      enableFloatingOrbs: cms.theme?.enableFloatingOrbs ?? fallback.theme?.enableFloatingOrbs ?? true,
      enableNoiseTexture: cms.theme?.enableNoiseTexture ?? fallback.theme?.enableNoiseTexture ?? true,
      enableCustomCursor: cms.theme?.enableCustomCursor ?? fallback.theme?.enableCustomCursor ?? true,
      enableGradientMesh: cms.theme?.enableGradientMesh ?? fallback.theme?.enableGradientMesh ?? true,
      sectionAccents: cms.theme?.sectionAccents?.length
        ? cms.theme.sectionAccents.map((s) => ({ color: s.color }))
        : fallback.theme?.sectionAccents ?? [],
    },
    branding: {
      siteName: cms.branding?.siteName ?? fallback.branding?.siteName ?? "InST",
      siteFullName: cms.branding?.siteFullName ?? fallback.branding?.siteFullName ?? "Innovative Solutions Tech",
      siteDescription: cms.branding?.siteDescription ?? fallback.branding?.siteDescription,
      logoText: cms.branding?.logoText ?? fallback.branding?.logoText ?? "In",
      contactEmail: cms.branding?.contactEmail ?? fallback.branding?.contactEmail,
    },
    social: {
      linkedinUrl: cms.social?.linkedinUrl ?? fallback.social?.linkedinUrl,
      twitterUrl: cms.social?.twitterUrl ?? fallback.social?.twitterUrl,
      githubUrl: cms.social?.githubUrl ?? fallback.social?.githubUrl,
      instagramUrl: cms.social?.instagramUrl ?? fallback.social?.instagramUrl,
      youtubeUrl: cms.social?.youtubeUrl ?? fallback.social?.youtubeUrl,
    },
    footer: {
      copyright: cms.footer?.copyright ?? fallback.footer.copyright,
      company: {
        about: cms.footer?.company?.about ?? fallback.footer.company.about,
        services: cms.footer?.company?.services ?? fallback.footer.company.services,
        projects: cms.footer?.company?.projects ?? fallback.footer.company.projects,
      },
      connect: {
        linkedin: cms.footer?.connect?.linkedin ?? fallback.footer.connect.linkedin,
        twitter: cms.footer?.connect?.twitter ?? fallback.footer.connect.twitter,
        github: cms.footer?.connect?.github ?? fallback.footer.connect.github,
      },
    },
    slides: {
      names: cms.slides?.names?.length
        ? cms.slides.names.map((n) => n.name)
        : fallback.slides.names,
    },
  };
}

interface LanguageProviderProps {
  children: ReactNode;
  siteContent?: { en: CMSSiteContent; ar: CMSSiteContent } | null;
}

export function LanguageProvider({ children, siteContent }: LanguageProviderProps) {
  const [locale, setLocaleState] = useState<Locale>("en");

  // Load saved locale on mount
  useEffect(() => {
    const saved = localStorage.getItem("inst-locale") as Locale | null;
    if (saved && locales[saved]) {
      setLocaleState(saved);
    }
  }, []);

  // Apply dir and lang to <html> when locale changes
  useEffect(() => {
    const html = document.documentElement;
    html.lang = locale;
    html.dir = checkRTL(locale) ? "rtl" : "ltr";
  }, [locale]);

  const setLocale = useCallback((newLocale: Locale) => {
    setLocaleState(newLocale);
    localStorage.setItem("inst-locale", newLocale);
  }, []);

  const dir = checkRTL(locale) ? "rtl" : "ltr";
  const isRTL = checkRTL(locale);

  // Build translations from CMS data with static fallback
  const fallback = locales[locale];
  const cmsData = siteContent?.[locale] ?? undefined;
  const t = buildTranslations(cmsData, fallback);

  return (
    <LanguageContext.Provider value={{ locale, t, setLocale, dir, isRTL }}>
      {children}
    </LanguageContext.Provider>
  );
}
