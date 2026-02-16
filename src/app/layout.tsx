import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "InST — Innovative Solutions Tech | Engineering the Future",
  description:
    "We architect cutting-edge technology platforms that redefine what's possible. AI-powered systems, scalable cloud infrastructure, and intelligent solutions for forward-thinking organizations.",
  keywords: [
    "AI",
    "Machine Learning",
    "Cloud Infrastructure",
    "Software Engineering",
    "Technology Consulting",
    "Innovative Solutions Tech",
    "InST",
  ],
  openGraph: {
    title: "InST — Engineering the Future of Intelligent Solutions",
    description:
      "Cutting-edge technology platforms that redefine what's possible.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "InST — Engineering the Future of Intelligent Solutions",
    description:
      "Cutting-edge technology platforms that redefine what's possible.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
