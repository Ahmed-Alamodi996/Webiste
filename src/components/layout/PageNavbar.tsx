"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Sun, Moon, Globe } from "lucide-react";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";
import { useTheme } from "@/context/ThemeContext";

export default function PageNavbar() {
  const [isMobileOpen, setIsMobileOpen] = useState(false);
  const [hoveredLink, setHoveredLink] = useState<number | null>(null);
  const { t, locale, setLocale, isRTL } = useLanguage();
  const { theme, toggleTheme } = useTheme();

  const navLinks = [
    { label: t.nav.services, href: "/#services" },
    { label: t.nav.projects, href: "/#projects" },
    { label: t.nav.about, href: "/#about" },
    { label: t.nav.technology, href: "/#technology" },
    { label: t.nav.contact, href: "/#contact" },
  ];

  const toggleLanguage = () => {
    setLocale(locale === "en" ? "ar" : "en");
  };

  return (
    <>
      <motion.nav
        aria-label="Main navigation"
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
        className="fixed top-0 left-0 right-0 z-[100] glass-strong py-3"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 flex items-center justify-between">
          {/* Logo */}
          <Link
            href="/"
            className="flex items-center gap-2 group"
            data-cursor-hover
          >
            <div className="w-9 h-9 rounded-xl bg-gradient-accent flex items-center justify-center font-bold text-sm text-white">
              In
            </div>
            <span
              className="text-lg font-semibold tracking-tight group-hover:text-brand-green transition-colors duration-300"
              style={{ color: "var(--text-primary)" }}
            >
              InST
            </span>
          </Link>

          {/* Desktop Links */}
          <div
            className={`hidden md:flex items-center gap-8 ${isRTL ? "flex-row-reverse" : ""}`}
            onMouseLeave={() => setHoveredLink(null)}
          >
            {navLinks.map((link, i) => (
              <Link
                key={link.label}
                href={link.href}
                onMouseEnter={() => setHoveredLink(i)}
                data-cursor-hover
                className="relative text-sm transition-colors duration-300 py-1"
                style={{
                  color:
                    hoveredLink === i
                      ? "var(--text-primary)"
                      : "var(--text-secondary)",
                }}
              >
                {link.label}
                {hoveredLink === i && (
                  <motion.div
                    layoutId="page-nav-underline"
                    className="absolute -bottom-0.5 left-0 right-0 h-[2px] rounded-full"
                    style={{ background: "var(--gradient-accent)" }}
                    transition={{
                      type: "spring",
                      stiffness: 350,
                      damping: 25,
                      mass: 0.5,
                    }}
                  />
                )}
              </Link>
            ))}
          </div>

          {/* Right controls */}
          <div className="hidden md:flex items-center gap-3">
            {/* Language toggle */}
            <button
              onClick={toggleLanguage}
              data-cursor-hover
              className="flex items-center gap-1.5 px-3 py-2 rounded-full text-xs font-medium transition-all duration-300"
              style={{
                color: "var(--text-secondary)",
                border: "1px solid var(--border-color)",
              }}
              aria-label={locale === "en" ? "Switch to Arabic" : "Switch to English"}
            >
              <Globe size={14} />
              <span>{locale === "en" ? "AR" : "EN"}</span>
            </button>

            {/* Theme toggle */}
            <button
              onClick={toggleTheme}
              data-cursor-hover
              className="flex items-center justify-center w-9 h-9 rounded-full transition-all duration-300"
              style={{
                color: "var(--text-secondary)",
                border: "1px solid var(--border-color)",
              }}
              aria-label={theme === "dark" ? "Switch to light mode" : "Switch to dark mode"}
            >
              {theme === "dark" ? <Sun size={16} /> : <Moon size={16} />}
            </button>

            {/* CTA Button */}
            <Link
              href="/#contact"
              data-cursor-hover
              className="px-5 py-2.5 rounded-full text-sm font-medium bg-gradient-accent text-white hover:shadow-glow transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]"
            >
              {t.nav.getInTouch}
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex md:hidden items-center gap-0 sm:gap-1">
            <button
              onClick={toggleLanguage}
              data-cursor-hover
              className="min-w-[44px] min-h-[44px] flex items-center justify-center text-sm font-medium"
              style={{ color: "var(--text-secondary)" }}
              aria-label={locale === "en" ? "Switch to Arabic" : "Switch to English"}
            >
              {locale === "en" ? "AR" : "EN"}
            </button>

            <button
              onClick={toggleTheme}
              data-cursor-hover
              className="min-w-[44px] min-h-[44px] flex items-center justify-center"
              style={{ color: "var(--text-secondary)" }}
              aria-label={theme === "dark" ? "Switch to light mode" : "Switch to dark mode"}
            >
              {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
            </button>

            <button
              className="min-w-[44px] min-h-[44px] flex items-center justify-center"
              style={{ color: "var(--text-primary)" }}
              onClick={() => setIsMobileOpen(!isMobileOpen)}
              data-cursor-hover
              aria-label={isMobileOpen ? "Close menu" : "Open menu"}
              aria-expanded={isMobileOpen}
            >
              {isMobileOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>
      </motion.nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 z-[99] backdrop-blur-xl pt-24 px-6 md:hidden overflow-y-auto"
            style={{ backgroundColor: "var(--mobile-menu-bg)" }}
          >
            <div
              className={`flex flex-col gap-6 ${isRTL ? "items-end" : "items-start"}`}
            >
              {navLinks.map((link, i) => (
                <motion.div
                  key={link.label}
                  initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.08, duration: 0.4 }}
                >
                  <Link
                    href={link.href}
                    onClick={() => setIsMobileOpen(false)}
                    className="text-2xl font-semibold hover:text-brand-green transition-colors"
                    style={{ color: "var(--text-primary)" }}
                  >
                    {link.label}
                  </Link>
                </motion.div>
              ))}
              <motion.div
                initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: navLinks.length * 0.08, duration: 0.4 }}
              >
                <Link
                  href="/#contact"
                  onClick={() => setIsMobileOpen(false)}
                  className="mt-4 px-6 py-3 rounded-full text-lg font-medium bg-gradient-accent text-white w-fit inline-block"
                >
                  {t.nav.getInTouch}
                </Link>
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
