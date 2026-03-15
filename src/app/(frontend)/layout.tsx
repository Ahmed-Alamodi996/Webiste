import type { Metadata } from "next";
import { Inter, JetBrains_Mono, Tajawal, Syne } from "next/font/google";
import "../globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  display: "swap",
});

const tajawal = Tajawal({
  subsets: ["arabic"],
  weight: ["400", "500", "700"],
  variable: "--font-tajawal",
  display: "swap",
});

const syne = Syne({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  variable: "--font-display",
  display: "swap",
});

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://inst.tech";

export const metadata: Metadata = {
  metadataBase: new URL(BASE_URL),
  title: "InST — Innovative Solutions Tech | Engineering the Future",
  description:
    "Premium software engineering and AI solutions for forward-thinking companies. We architect enterprise-grade digital products that define industries.",
  keywords: [
    "AI",
    "machine learning",
    "cloud architecture",
    "software engineering",
    "cybersecurity",
    "data analytics",
    "enterprise software",
  ],
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: "InST — Innovative Solutions Tech",
    description:
      "Engineering the future of intelligent solutions. Premium technology for visionary companies.",
    type: "website",
    locale: "en_US",
    url: BASE_URL,
    siteName: "InST — Innovative Solutions Tech",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "InST — Innovative Solutions Tech",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "InST — Innovative Solutions Tech",
    description:
      "Engineering the future of intelligent solutions. Premium technology for visionary companies.",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function FrontendLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: "InST - Innovative Solutions Tech",
        url: BASE_URL,
        logo: `${BASE_URL}/og-image.png`,
        description:
          "Premium software engineering and AI solutions for forward-thinking companies.",
        contactPoint: {
          "@type": "ContactPoint",
          contactType: "sales",
          availableLanguage: ["English", "Arabic"],
        },
      },
      {
        "@type": "WebSite",
        name: "InST — Innovative Solutions Tech",
        url: BASE_URL,
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
