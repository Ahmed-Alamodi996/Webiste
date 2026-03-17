"use client";

import {
  createContext,
  useContext,
  useState,
  useCallback,
  useEffect,
  type ReactNode,
} from "react";
import { useLanguage } from "@/context/LanguageContext";

type Theme = "dark" | "light";

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
  setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useTheme must be used within ThemeProvider");
  return ctx;
}

const SPEED_MAP = {
  fast: 0.6,
  normal: 1,
  slow: 1.6,
};

export function ThemeProvider({ children }: { children: ReactNode }) {
  const { t } = useLanguage();
  const themeSettings = t.theme;
  const defaultTheme = themeSettings?.defaultTheme ?? "dark";

  const [theme, setThemeState] = useState<Theme>(defaultTheme);

  // Load saved theme or use CMS default
  useEffect(() => {
    const saved = localStorage.getItem("inst-theme") as Theme | null;
    if (saved === "light" || saved === "dark") {
      setThemeState(saved);
    } else if (defaultTheme) {
      setThemeState(defaultTheme);
    } else if (window.matchMedia("(prefers-color-scheme: light)").matches) {
      setThemeState("light");
    }
  }, [defaultTheme]);

  // Apply data-theme + CMS brand colors as CSS variables
  useEffect(() => {
    const html = document.documentElement;
    html.setAttribute("data-theme", theme);
    if (theme === "dark") {
      html.classList.add("dark");
      html.classList.remove("light");
    } else {
      html.classList.add("light");
      html.classList.remove("dark");
    }

    // Apply CMS brand colors
    const primary = themeSettings?.brandPrimary || "#00C896";
    const secondary = themeSettings?.brandSecondary || "#2563EB";
    const angle = themeSettings?.gradientAngle ?? 135;
    const speed = SPEED_MAP[themeSettings?.animationSpeed ?? "normal"];

    html.style.setProperty("--brand-green", primary);
    html.style.setProperty("--brand-green-light", adjustBrightness(primary, 20));
    html.style.setProperty("--gradient-accent", `linear-gradient(${angle}deg, ${primary} 0%, ${secondary} 100%)`);
    html.style.setProperty("--animation-speed", String(speed));
    html.style.setProperty("--particle-color", hexToRgb(primary));

    // Apply glow colors based on brand
    html.style.setProperty("--border-glow", `${primary}33`);
    html.style.setProperty("--border-glow-hover", `${primary}66`);
    html.style.setProperty("--selection-bg", `${primary}4D`);

    // Toggle noise overlay
    if (!themeSettings?.enableNoiseTexture) {
      html.classList.add("no-noise");
    } else {
      html.classList.remove("no-noise");
    }
  }, [theme, themeSettings]);

  const setTheme = useCallback((newTheme: Theme) => {
    setThemeState(newTheme);
    localStorage.setItem("inst-theme", newTheme);
  }, []);

  const toggleTheme = useCallback(() => {
    setTheme(theme === "dark" ? "light" : "dark");
  }, [theme, setTheme]);

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Utility: hex to "r, g, b" string
function hexToRgb(hex: string): string {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return `${r}, ${g}, ${b}`;
}

// Utility: lighten/darken hex color
function adjustBrightness(hex: string, amount: number): string {
  const h = hex.replace("#", "");
  const r = Math.min(255, Math.max(0, parseInt(h.substring(0, 2), 16) + amount));
  const g = Math.min(255, Math.max(0, parseInt(h.substring(2, 4), 16) + amount));
  const b = Math.min(255, Math.max(0, parseInt(h.substring(4, 6), 16) + amount));
  return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
}
