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

/** Helper: pick EN or AR value from a bilingual CMS field */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function pick(obj: any, field: string, locale: Locale): string | undefined {
  if (!obj) return undefined;
  return obj[`${field}_${locale}`] ?? obj[`${field}_en`];
}

/**
 * Build Translations from the new bilingual CMS format.
 * CMS fields use _en/_ar suffixes instead of Payload's localization.
 * Falls back to static locale data.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function buildTranslations(cms: any, locale: Locale, fallback: Translations): Translations {
  if (!cms) return fallback;

  const l = locale;

  return {
    theme: {
      brandPrimary: cms.theme?.brandPrimary ?? fallback.theme?.brandPrimary ?? "#00C896",
      brandSecondary: cms.theme?.brandSecondary ?? fallback.theme?.brandSecondary ?? "#2563EB",
      gradientAngle: cms.theme?.gradientAngle ?? fallback.theme?.gradientAngle ?? 135,
      defaultTheme: cms.theme?.defaultTheme ?? fallback.theme?.defaultTheme ?? "dark",
      defaultViewMode: cms.theme?.defaultViewMode ?? fallback.theme?.defaultViewMode ?? "slides",
      animationSpeed: cms.theme?.animationSpeed ?? fallback.theme?.animationSpeed ?? "normal",
      enableParticles: cms.theme?.enableParticles ?? fallback.theme?.enableParticles ?? true,
      enableAurora: cms.theme?.enableAurora ?? fallback.theme?.enableAurora ?? true,
      enableFloatingOrbs: cms.theme?.enableFloatingOrbs ?? fallback.theme?.enableFloatingOrbs ?? true,
      enableNoiseTexture: cms.theme?.enableNoiseTexture ?? fallback.theme?.enableNoiseTexture ?? true,
      enableCustomCursor: cms.theme?.enableCustomCursor ?? fallback.theme?.enableCustomCursor ?? true,
      enableGradientMesh: cms.theme?.enableGradientMesh ?? fallback.theme?.enableGradientMesh ?? true,
      sectionAccents: cms.theme?.sectionAccents?.length
        ? cms.theme.sectionAccents.map((s: { color: string }) => ({ color: s.color }))
        : fallback.theme?.sectionAccents ?? [],
      preset: cms.theme?.preset ?? fallback.theme?.preset ?? "default",
      customCSS: cms.theme?.customCSS ?? fallback.theme?.customCSS,
      animations: {
        preloaderAnimation: cms.theme?.animations?.preloaderAnimation ?? undefined,
        heroAnimation: cms.theme?.animations?.heroAnimation ?? undefined,
        contactSuccessAnimation: cms.theme?.animations?.contactSuccessAnimation ?? undefined,
      },
    },
    nav: {
      services: pick(cms.nav, 'services', l) ?? fallback.nav.services,
      projects: pick(cms.nav, 'projects', l) ?? fallback.nav.projects,
      about: pick(cms.nav, 'about', l) ?? fallback.nav.about,
      technology: pick(cms.nav, 'technology', l) ?? fallback.nav.technology,
      contact: pick(cms.nav, 'contact', l) ?? fallback.nav.contact,
      getInTouch: pick(cms.nav, 'getInTouch', l) ?? fallback.nav.getInTouch,
    },
    hero: {
      tagline: pick(cms.hero, 'tagline', l) ?? fallback.hero.tagline,
      headlineLine1: cms.hero?.[`headlineLine1_${l}`]
        ? cms.hero[`headlineLine1_${l}`].split(' ').filter(Boolean)
        : fallback.hero.headlineLine1,
      headlineLine2: cms.hero?.[`headlineLine2_${l}`]
        ? cms.hero[`headlineLine2_${l}`].split(' ').filter(Boolean)
        : fallback.hero.headlineLine2,
      description: pick(cms.hero, 'description', l) ?? fallback.hero.description,
      exploreSolutions: pick(cms.hero, 'exploreSolutions', l) ?? fallback.hero.exploreSolutions,
      getInTouch: pick(cms.hero, 'getInTouch', l) ?? fallback.hero.getInTouch,
      trustedBy: pick(cms.hero, 'trustedBy', l) ?? fallback.hero.trustedBy,
      statsProjects: pick(cms.hero, 'statsProjects', l) ?? fallback.hero.statsProjects,
      statsUptime: pick(cms.hero, 'statsUptime', l) ?? fallback.hero.statsUptime,
      statsSupport: pick(cms.hero, 'statsSupport', l) ?? fallback.hero.statsSupport,
      next: pick(cms.hero, 'next', l) ?? fallback.hero.next,
    },
    about: {
      label: pick(cms.about, 'label', l) ?? fallback.about.label,
      headingLine1: pick(cms.about, 'headingLine1', l) ?? fallback.about.headingLine1,
      headingWord1: pick(cms.about, 'headingWord1', l) ?? fallback.about.headingWord1,
      headingLine2: pick(cms.about, 'headingLine2', l) ?? fallback.about.headingLine2,
      headingWord2: pick(cms.about, 'headingWord2', l) ?? fallback.about.headingWord2,
      paragraph1: pick(cms.about, 'paragraph1', l) ?? fallback.about.paragraph1,
      paragraph2: pick(cms.about, 'paragraph2', l) ?? fallback.about.paragraph2,
      stats: cms.about?.stats?.length
        ? cms.about.stats.map((s: { target: number; suffix: string; label_en?: string; label_ar?: string }) => ({
            target: s.target,
            suffix: s.suffix,
            label: (l === 'ar' ? s.label_ar : s.label_en) ?? s.label_en ?? '',
          }))
        : fallback.about.stats,
    },
    offer: {
      label: pick(cms.offer, 'label', l) ?? fallback.offer.label,
      heading: pick(cms.offer, 'heading', l) ?? fallback.offer.heading,
      headingAccent: pick(cms.offer, 'headingAccent', l) ?? fallback.offer.headingAccent,
      description: pick(cms.offer, 'description', l) ?? fallback.offer.description,
      items: fallback.offer.items,
    },
    services: {
      label: pick(cms.services, 'label', l) ?? fallback.services.label,
      heading: pick(cms.services, 'heading', l) ?? fallback.services.heading,
      headingAccent: pick(cms.services, 'headingAccent', l) ?? fallback.services.headingAccent,
      description: pick(cms.services, 'description', l) ?? fallback.services.description,
      learnMore: pick(cms.services, 'learnMore', l) ?? fallback.services.learnMore,
      items: fallback.services.items,
    },
    projects: {
      label: pick(cms.projects, 'label', l) ?? fallback.projects.label,
      heading: pick(cms.projects, 'heading', l) ?? fallback.projects.heading,
      headingAccent: pick(cms.projects, 'headingAccent', l) ?? fallback.projects.headingAccent,
      description: pick(cms.projects, 'description', l) ?? fallback.projects.description,
      viewCaseStudy: pick(cms.projects, 'viewCaseStudy', l) ?? fallback.projects.viewCaseStudy,
      items: fallback.projects.items,
    },
    technology: {
      label: pick(cms.technology, 'label', l) ?? fallback.technology.label,
      heading: pick(cms.technology, 'heading', l) ?? fallback.technology.heading,
      headingAccent: pick(cms.technology, 'headingAccent', l) ?? fallback.technology.headingAccent,
      description: pick(cms.technology, 'description', l) ?? fallback.technology.description,
    },
    contact: {
      label: pick(cms.contact, 'label', l) ?? fallback.contact.label,
      heading: pick(cms.contact, 'heading', l) ?? fallback.contact.heading,
      headingAccent: pick(cms.contact, 'headingAccent', l) ?? fallback.contact.headingAccent,
      description: pick(cms.contact, 'description', l) ?? fallback.contact.description,
      features: cms.contact?.features?.length
        ? cms.contact.features.map((f: { text_en?: string; text_ar?: string }) =>
            (l === 'ar' ? f.text_ar : f.text_en) ?? f.text_en ?? ''
          )
        : fallback.contact.features,
      form: {
        name: pick(cms.contact?.form, 'name', l) ?? fallback.contact.form.name,
        namePlaceholder: pick(cms.contact?.form, 'namePlaceholder', l) ?? fallback.contact.form.namePlaceholder,
        email: pick(cms.contact?.form, 'email', l) ?? fallback.contact.form.email,
        emailPlaceholder: pick(cms.contact?.form, 'emailPlaceholder', l) ?? fallback.contact.form.emailPlaceholder,
        message: pick(cms.contact?.form, 'message', l) ?? fallback.contact.form.message,
        messagePlaceholder: pick(cms.contact?.form, 'messagePlaceholder', l) ?? fallback.contact.form.messagePlaceholder,
        send: pick(cms.contact?.form, 'send', l) ?? fallback.contact.form.send,
        successTitle: pick(cms.contact?.form, 'successTitle', l) ?? fallback.contact.form.successTitle,
        successMessage: pick(cms.contact?.form, 'successMessage', l) ?? fallback.contact.form.successMessage,
      },
    },
    branding: {
      siteName: cms.branding?.siteName ?? fallback.branding?.siteName ?? "InST",
      siteFullName: cms.branding?.siteFullName ?? fallback.branding?.siteFullName,
      siteDescription: pick(cms.branding, 'siteDescription', l) ?? fallback.branding?.siteDescription,
      logoText: cms.branding?.logoText ?? fallback.branding?.logoText ?? "In",
      contactEmail: cms.branding?.contactEmail ?? fallback.branding?.contactEmail,
    },
    social: {
      linkedinUrl: cms.social?.linkedinUrl ?? fallback.social?.linkedinUrl,
      twitterUrl: cms.social?.twitterUrl ?? fallback.social?.twitterUrl,
      githubUrl: cms.social?.githubUrl ?? fallback.social?.githubUrl,
      instagramUrl: cms.social?.instagramUrl,
      youtubeUrl: cms.social?.youtubeUrl,
    },
    footer: {
      copyright: pick(cms.footer, 'copyright', l) ?? fallback.footer.copyright,
      company: {
        about: pick(cms.footer?.company, 'about', l) ?? fallback.footer.company.about,
        services: pick(cms.footer?.company, 'services', l) ?? fallback.footer.company.services,
        projects: pick(cms.footer?.company, 'projects', l) ?? fallback.footer.company.projects,
      },
      connect: {
        linkedin: pick(cms.footer?.connect, 'linkedin', l) ?? fallback.footer.connect.linkedin,
        twitter: pick(cms.footer?.connect, 'twitter', l) ?? fallback.footer.connect.twitter,
        github: pick(cms.footer?.connect, 'github', l) ?? fallback.footer.connect.github,
      },
    },
    slides: {
      names: cms.slides?.names?.length
        ? cms.slides.names.map((n: { name_en?: string; name_ar?: string }) =>
            (l === 'ar' ? n.name_ar : n.name_en) ?? n.name_en ?? ''
          )
        : fallback.slides.names,
    },
  };
}

interface LanguageProviderProps {
  children: ReactNode;
  // Now receives a single CMS object (not per-locale, since fields contain both languages)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  siteContent?: any;
}

export function LanguageProvider({ children, siteContent }: LanguageProviderProps) {
  const [locale, setLocaleState] = useState<Locale>("en");

  useEffect(() => {
    const saved = localStorage.getItem("inst-locale") as Locale | null;
    if (saved && locales[saved]) {
      setLocaleState(saved);
    }
  }, []);

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

  const fallback = locales[locale];
  // siteContent can be the old format { en, ar } or the new single object
  const cmsData = siteContent?.en ? siteContent[locale] : siteContent;
  const t = buildTranslations(cmsData, locale, fallback);

  return (
    <LanguageContext.Provider value={{ locale, t, setLocale, dir, isRTL }}>
      {children}
    </LanguageContext.Provider>
  );
}
