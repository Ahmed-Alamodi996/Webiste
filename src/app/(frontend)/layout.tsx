import type { Metadata } from "next";
import { Inter, JetBrains_Mono, Tajawal, Syne } from "next/font/google";
import { getPayload } from "payload";
import config from "@payload-config";
import "../globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter", display: "swap" });
const jetbrainsMono = JetBrains_Mono({ subsets: ["latin"], variable: "--font-mono", display: "swap" });
const tajawal = Tajawal({ subsets: ["arabic"], weight: ["400", "500", "700"], variable: "--font-tajawal", display: "swap" });
const syne = Syne({ subsets: ["latin"], weight: ["400", "500", "600", "700", "800"], variable: "--font-display", display: "swap" });

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://inst-sa.com";

// Default SEO fallback
const DEFAULT_TITLE = "InST — Innovative Solutions Tech | انوفيتيف سلوشنز تيك";
const DEFAULT_DESC = "Innovative Solutions Tech (InST) — شركة انوفيتيف سلوشنز تيك | Premium software engineering, AI solutions, cloud architecture, and cybersecurity. حلول هندسة البرمجيات والذكاء الاصطناعي المتميزة للشركات.";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function getCMSSeo(): Promise<any> {
  try {
    const payload = await getPayload({ config });
    const siteContent = await payload.findGlobal({ slug: "site-content" });
    return siteContent;
  } catch {
    return null;
  }
}

export async function generateMetadata(): Promise<Metadata> {
  const cms = await getCMSSeo();
  const seo = cms?.seo;
  const branding = cms?.branding;

  const title = seo?.metaTitle_en
    ? `${seo.metaTitle_en}${seo.metaTitle_ar ? ` | ${seo.metaTitle_ar}` : ""}`
    : DEFAULT_TITLE;
  const description = seo?.metaDescription_en
    ? `${seo.metaDescription_en} ${seo.metaDescription_ar || ""}`
    : DEFAULT_DESC;

  const keywords = seo?.keywords?.length
    ? seo.keywords.map((k: { keyword: string }) => k.keyword)
    : ["Innovative Solutions Tech", "InST", "انوفيتيف سلوشنز تيك", "AI solutions", "حلول تقنية", "هندسة برمجيات"];

  const ogImageUrl = seo?.ogImage?.url || "/og-image.png";

  return {
    metadataBase: new URL(BASE_URL),
    title,
    description,
    keywords,
    alternates: {
      canonical: "/",
      languages: {
        en: "https://inst-sa.com",
        ar: "https://inst.sa",
      },
    },
    verification: {
      google: seo?.googleVerification || undefined,
      other: seo?.bingVerification ? { "msvalidate.01": seo.bingVerification } : undefined,
    },
    openGraph: {
      title,
      description,
      type: "website",
      locale: "en_US",
      alternateLocale: "ar_SA",
      url: BASE_URL,
      siteName: branding?.siteFullName || "Innovative Solutions Tech",
      images: [{ url: ogImageUrl, width: 1200, height: 630, alt: title }],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [ogImageUrl],
    },
    robots: { index: true, follow: true },
  };
}

export default async function FrontendLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  const cms = await getCMSSeo();
  const branding = cms?.branding;
  const social = cms?.social;

  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: branding?.siteFullName || "Innovative Solutions Tech",
        alternateName: [branding?.siteName || "InST", "انوفيتيف سلوشنز تيك"],
        url: BASE_URL,
        logo: `${BASE_URL}/og-image.png`,
        description: "Premium software engineering, AI solutions, cloud architecture, and cybersecurity for enterprise companies.",
        contactPoint: {
          "@type": "ContactPoint",
          contactType: "sales",
          email: branding?.contactEmail || "info@inst.sa",
          availableLanguage: ["English", "Arabic"],
        },
        sameAs: [
          "https://inst.sa",
          "https://inst-sa.com",
          social?.linkedinUrl,
          social?.twitterUrl,
          social?.githubUrl,
          social?.instagramUrl,
          social?.youtubeUrl,
        ].filter(Boolean),
      },
      {
        "@type": "WebSite",
        name: `${branding?.siteName || "InST"} — ${branding?.siteFullName || "Innovative Solutions Tech"}`,
        url: BASE_URL,
        inLanguage: ["en", "ar"],
      },
    ],
  };

  return (
    <html
      lang="en"
      data-theme="dark"
      className={`dark ${inter.variable} ${jetbrainsMono.variable} ${tajawal.variable} ${syne.variable}`}
      suppressHydrationWarning
    >
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className={inter.className}>
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:absolute focus:z-[10001] focus:top-4 focus:left-4 focus:px-4 focus:py-2 focus:bg-brand-green focus:text-white focus:rounded-lg focus:text-sm focus:font-medium"
        >
          Skip to main content
        </a>
        {children}
      </body>
    </html>
  );
}
