"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Sun, Moon, Globe } from "lucide-react";
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";
import { useTheme } from "@/context/ThemeContext";

export default function Navbar() {
  const [isMobileOpen, setIsMobileOpen] = useState(false);
  const { goToSlide } = useSlide();
  const { t, locale, setLocale, isRTL } = useLanguage();
  const { theme, toggleTheme } = useTheme();

  const navLinks = [
    { label: t.nav.services, slideIndex: 4 },
    { label: t.nav.projects, slideIndex: 2 },
    { label: t.nav.about, slideIndex: 3 },
    { label: t.nav.technology, slideIndex: 5 },
    { label: t.nav.contact, slideIndex: 6 },
  ];

  const handleNav = (slideIndex: number) => {
    setIsMobileOpen(false);
    goToSlide(slideIndex);
  };

  const toggleLanguage = () => {
    setLocale(locale === "en" ? "ar" : "en");
  };

  return (
    <>
      <motion.nav
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
        className="fixed top-0 left-0 right-0 z-[100] glass-strong py-3"
      >
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          {/* Logo */}
          <button
            onClick={() => goToSlide(0)}
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
          </button>

          {/* Desktop Links */}
          <div className={`hidden md:flex items-center gap-8 ${isRTL ? "flex-row-reverse" : ""}`}>
            {navLinks.map((link) => (
              <button
                key={link.label}
                onClick={() => handleNav(link.slideIndex)}
                data-cursor-hover
                className="relative text-sm transition-colors duration-300 group"
                style={{ color: "var(--text-secondary)" }}
                onMouseEnter={(e) => (e.currentTarget.style.color = "var(--text-primary)")}
                onMouseLeave={(e) => (e.currentTarget.style.color = "var(--text-secondary)")}
              >
                {link.label}
                <span className="absolute -bottom-1 left-0 w-0 h-[1.5px] bg-gradient-accent group-hover:w-full transition-all duration-300 ease-out-expo" />
              </button>
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
              title={locale === "en" ? "العربية" : "English"}
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
              title={theme === "dark" ? "Light mode" : "Dark mode"}
            >
              {theme === "dark" ? <Sun size={16} /> : <Moon size={16} />}
            </button>

            {/* CTA Button */}
            <button
              onClick={() => handleNav(6)}
              data-cursor-hover
              className="px-5 py-2.5 rounded-full text-sm font-medium bg-gradient-accent text-white hover:shadow-glow transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]"
            >
              {t.nav.getInTouch}
            </button>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex md:hidden items-center gap-2">
            {/* Mobile language toggle */}
            <button
              onClick={toggleLanguage}
              data-cursor-hover
              className="p-2 text-sm font-medium"
              style={{ color: "var(--text-secondary)" }}
            >
              {locale === "en" ? "AR" : "EN"}
            </button>

            {/* Mobile theme toggle */}
            <button
              onClick={toggleTheme}
              data-cursor-hover
              className="p-2"
              style={{ color: "var(--text-secondary)" }}
            >
              {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
            </button>

            <button
              className="p-2"
              style={{ color: "var(--text-primary)" }}
              onClick={() => setIsMobileOpen(!isMobileOpen)}
              data-cursor-hover
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
            className="fixed inset-0 z-[99] backdrop-blur-xl pt-24 px-6 md:hidden"
            style={{ backgroundColor: "var(--mobile-menu-bg)" }}
          >
            <div className={`flex flex-col gap-6 ${isRTL ? "items-end" : "items-start"}`}>
              {navLinks.map((link, i) => (
                <motion.button
                  key={link.label}
                  initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.08, duration: 0.4 }}
                  onClick={() => handleNav(link.slideIndex)}
                  className="text-2xl font-semibold hover:text-brand-green transition-colors"
                  style={{ color: "var(--text-primary)" }}
                >
                  {link.label}
                </motion.button>
              ))}
              <motion.button
                initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: navLinks.length * 0.08, duration: 0.4 }}
                onClick={() => handleNav(6)}
                className="mt-4 px-6 py-3 rounded-full text-lg font-medium bg-gradient-accent text-white w-fit"
              >
                {t.nav.getInTouch}
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
