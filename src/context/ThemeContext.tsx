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

const SPEED_MAP: Record<string, number> = {
  fast: 0.6,
  normal: 1,
  slow: 1.6,
};

// ─── Preset Theme Definitions ─────────────────────
const PRESETS: Record<string, { primary: string; secondary: string; angle: number }> = {
  default:   { primary: "#00C896", secondary: "#2563EB", angle: 135 },
  neon:      { primary: "#00FFFF", secondary: "#FF00FF", angle: 135 },
  corporate: { primary: "#2563EB", secondary: "#475569", angle: 180 },
  minimal:   { primary: "#6B7280", secondary: "#374151", angle: 135 },
  sunset:    { primary: "#F97316", secondary: "#9333EA", angle: 135 },
  ocean:     { primary: "#14B8A6", secondary: "#1E3A5F", angle: 180 },
  royal:     { primary: "#EAB308", secondary: "#6D28D9", angle: 135 },
};

export function ThemeProvider({ children }: { children: ReactNode }) {
  const { t } = useLanguage();
  const themeSettings = t.theme;
  const defaultTheme = themeSettings?.defaultTheme ?? "dark";

  const [theme, setThemeState] = useState<Theme>(defaultTheme);

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

  // Apply theme + preset + brand colors + custom CSS
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

    // Resolve preset → then allow individual overrides
    const presetName = themeSettings?.preset || "default";
    const preset = PRESETS[presetName] || PRESETS.default;

    // Individual settings override preset if set
    const primary = (presetName === "custom" || themeSettings?.brandPrimary)
      ? (themeSettings?.brandPrimary || preset.primary)
      : preset.primary;
    const secondary = (presetName === "custom" || themeSettings?.brandSecondary)
      ? (themeSettings?.brandSecondary || preset.secondary)
      : preset.secondary;
    const angle = themeSettings?.gradientAngle ?? preset.angle;
    const speed = SPEED_MAP[themeSettings?.animationSpeed ?? "normal"];

    // Apply CSS variables
    html.style.setProperty("--brand-green", primary);
    html.style.setProperty("--brand-green-light", adjustBrightness(primary, 20));
    html.style.setProperty("--gradient-accent", `linear-gradient(${angle}deg, ${primary} 0%, ${secondary} 100%)`);
    html.style.setProperty("--animation-speed", String(speed));
    html.style.setProperty("--particle-color", hexToRgb(primary));
    html.style.setProperty("--border-glow", `${primary}33`);
    html.style.setProperty("--border-glow-hover", `${primary}66`);
    html.style.setProperty("--selection-bg", `${primary}4D`);

    // Noise toggle
    if (!themeSettings?.enableNoiseTexture) {
      html.classList.add("no-noise");
    } else {
      html.classList.remove("no-noise");
    }

    // ─── Inject Custom CSS ─────────────────────────
    const existingStyle = document.getElementById("cms-custom-css");
    if (existingStyle) existingStyle.remove();

    if (themeSettings?.customCSS) {
      const style = document.createElement("style");
      style.id = "cms-custom-css";
      style.textContent = themeSettings.customCSS;
      document.head.appendChild(style);
    }

    return () => {
      const el = document.getElementById("cms-custom-css");
      if (el) el.remove();
    };
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

function hexToRgb(hex: string): string {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return isNaN(r) ? "0, 200, 150" : `${r}, ${g}, ${b}`;
}

function adjustBrightness(hex: string, amount: number): string {
  const h = hex.replace("#", "");
  const r = Math.min(255, Math.max(0, parseInt(h.substring(0, 2), 16) + amount));
  const g = Math.min(255, Math.max(0, parseInt(h.substring(2, 4), 16) + amount));
  const b = Math.min(255, Math.max(0, parseInt(h.substring(4, 6), 16) + amount));
  if (isNaN(r)) return hex;
  return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
}
