import en, { type Translations } from "./en";
import ar from "./ar";

export type Locale = "en" | "ar";

export const locales: Record<Locale, Translations> = { en, ar };

export const rtlLocales: Locale[] = ["ar"];

export function isRTL(locale: Locale): boolean {
  return rtlLocales.includes(locale);
}

export type { Translations };
