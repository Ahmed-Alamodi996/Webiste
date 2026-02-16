import type { Metadata } from "next";
import { Inter, JetBrains_Mono, Tajawal } from "next/font/google";
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

export const metadata: Metadata = {
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
  openGraph: {
    title: "InST — Innovative Solutions Tech",
    description:
      "Engineering the future of intelligent solutions. Premium technology for visionary companies.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "InST — Innovative Solutions Tech",
    description:
      "Engineering the future of intelligent solutions. Premium technology for visionary companies.",
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
  return (
    <html
      lang="en"
      data-theme="dark"
      className={`dark ${inter.variable} ${jetbrainsMono.variable} ${tajawal.variable}`}
      suppressHydrationWarning
    >
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}
