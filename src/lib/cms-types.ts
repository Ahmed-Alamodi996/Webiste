// Types for CMS data passed from server to client components

export interface CMSMedia {
  id: string
  url: string
  filename: string
  mimeType: string
  width?: number
  height?: number
  alt?: string
}

// Raw CMS types — bilingual fields with _en/_ar suffixes
export interface CMSProjectRaw {
  id: string
  title_en?: string
  title_ar?: string
  slug: string
  category_en?: string
  category_ar?: string
  description_en?: string
  description_ar?: string
  stat: string
  statLabel_en?: string
  statLabel_ar?: string
  gradient: string
  accentColor: string
  order: number
  coverImage?: CMSMedia | string
  gallery?: { image: CMSMedia | string }[]
  content_en?: Record<string, unknown>
  content_ar?: Record<string, unknown>
  techStack?: { name: string; color?: string }[]
  video?: { url?: string; provider?: 'youtube' | 'vimeo' | 'direct' }
  liveUrl?: string
}

export interface CMSOfferingRaw {
  id: string
  title_en?: string
  title_ar?: string
  description_en?: string
  description_ar?: string
  icon: 'brain' | 'cloud' | 'shield' | 'zap' | 'globe' | 'barChart3'
  accentColor: string
  order: number
}

export interface CMSServiceRaw {
  id: string
  title_en?: string
  title_ar?: string
  overview_en?: string
  overview_ar?: string
  technologies: { name: string }[]
  accentColor: string
  order: number
}

// Resolved types — single language, used by components
export interface CMSProject {
  id: string
  title: string
  slug: string
  category: string
  description: string
  stat: string
  statLabel: string
  gradient: string
  accentColor: string
  order: number
  coverImage?: CMSMedia | string
  gallery?: { image: CMSMedia | string }[]
  content?: Record<string, unknown>
  techStack?: { name: string; color?: string }[]
  video?: { url?: string; provider?: 'youtube' | 'vimeo' | 'direct' }
  liveUrl?: string
}

export interface CMSOffering {
  id: string
  title: string
  description: string
  icon: 'brain' | 'cloud' | 'shield' | 'zap' | 'globe' | 'barChart3'
  accentColor: string
  order: number
}

export interface CMSService {
  id: string
  title: string
  overview: string
  technologies: { name: string }[]
  accentColor: string
  order: number
}

// Resolve bilingual → single language
export function resolveProject(raw: CMSProjectRaw, locale: string): CMSProject {
  const l = locale === 'ar' ? 'ar' : 'en'
  return {
    ...raw,
    title: raw[`title_${l}`] || raw.title_en || '',
    category: raw[`category_${l}`] || raw.category_en || '',
    description: raw[`description_${l}`] || raw.description_en || '',
    statLabel: raw[`statLabel_${l}`] || raw.statLabel_en || '',
    content: raw[`content_${l}`] || raw.content_en,
  }
}

export function resolveOffering(raw: CMSOfferingRaw, locale: string): CMSOffering {
  const l = locale === 'ar' ? 'ar' : 'en'
  return {
    ...raw,
    title: raw[`title_${l}`] || raw.title_en || '',
    description: raw[`description_${l}`] || raw.description_en || '',
  }
}

export function resolveService(raw: CMSServiceRaw, locale: string): CMSService {
  const l = locale === 'ar' ? 'ar' : 'en'
  return {
    ...raw,
    title: raw[`title_${l}`] || raw.title_en || '',
    overview: raw[`overview_${l}`] || raw.overview_en || '',
  }
}

export interface CMSTechnology {
  id: string
  name: string
  color: string
  row: '1' | '2' | '3'
  order: number
}

export interface CMSThemeSettings {
  brandPrimary?: string
  brandSecondary?: string
  gradientAngle?: number
  defaultTheme?: 'dark' | 'light'
  defaultViewMode?: 'slides' | 'scroll'
  animationSpeed?: 'fast' | 'normal' | 'slow'
  enableParticles?: boolean
  enableAurora?: boolean
  enableFloatingOrbs?: boolean
  enableNoiseTexture?: boolean
  enableCustomCursor?: boolean
  enableGradientMesh?: boolean
  sectionAccents?: { color: string }[]
  preset?: 'default' | 'neon' | 'corporate' | 'minimal' | 'sunset' | 'ocean' | 'royal' | 'custom'
  customCSS?: string
  animations?: {
    preloaderAnimation?: string
    heroAnimation?: string
    contactSuccessAnimation?: string
  }
}

export interface CMSSiteContent {
  theme?: CMSThemeSettings
  nav: {
    services: string
    projects: string
    about: string
    technology: string
    contact: string
    getInTouch: string
  }
  hero: {
    tagline: string
    headlineLine1: { word: string }[]
    headlineLine2: { word: string }[]
    description: string
    exploreSolutions: string
    getInTouch: string
    trustedBy: string
    statsProjects: string
    statsUptime: string
    statsSupport: string
    next: string
  }
  about: {
    label: string
    headingLine1: string
    headingWord1: string
    headingLine2: string
    headingWord2: string
    paragraph1: string
    paragraph2: string
    stats: { target: number; suffix: string; label: string }[]
  }
  offer: {
    label: string
    heading: string
    headingAccent: string
    description: string
  }
  services: {
    label: string
    heading: string
    headingAccent: string
    description: string
    learnMore: string
  }
  projects: {
    label: string
    heading: string
    headingAccent: string
    description: string
    viewCaseStudy: string
  }
  technology: {
    label: string
    heading: string
    headingAccent: string
    description: string
  }
  contact: {
    label: string
    heading: string
    headingAccent: string
    description: string
    features: { text: string }[]
    form: {
      name: string
      namePlaceholder: string
      email: string
      emailPlaceholder: string
      message: string
      messagePlaceholder: string
      send: string
      successTitle: string
      successMessage: string
    }
  }
  branding?: {
    siteName?: string
    siteFullName?: string
    siteDescription?: string
    logoText?: string
    logo?: CMSMedia | string
    favicon?: CMSMedia | string
    contactEmail?: string
  }
  social?: {
    linkedinUrl?: string
    twitterUrl?: string
    githubUrl?: string
    instagramUrl?: string
    youtubeUrl?: string
  }
  footer: {
    copyright: string
    company: {
      about: string
      services: string
      projects: string
    }
    connect: {
      linkedin: string
      twitter: string
      github: string
    }
  }
  slides: {
    names: { name: string }[]
  }
}

// ──────────────────────────────────────────
// Page Builder types
// ──────────────────────────────────────────

export interface HeroBlockData {
  blockType: 'hero'
  id?: string
  heading: string
  headingAccent?: string
  description?: string
  backgroundImage?: CMSMedia | string
  ctas?: { label: string; href: string; variant?: 'primary' | 'secondary' }[]
}

export interface RichTextBlockData {
  blockType: 'richText'
  id?: string
  content: Record<string, unknown>
  maxWidth?: 'prose' | '3xl' | 'full'
}

export interface FeaturedProjectsBlockData {
  blockType: 'featuredProjects'
  id?: string
  label?: string
  heading?: string
  headingAccent?: string
  maxItems?: number
}

export interface ServicesBlockData {
  blockType: 'services'
  id?: string
  label?: string
  heading?: string
  headingAccent?: string
  description?: string
}

export interface OfferingsBlockData {
  blockType: 'offerings'
  id?: string
  label?: string
  heading?: string
  headingAccent?: string
  description?: string
}

export interface TechnologyBlockData {
  blockType: 'technology'
  id?: string
  label?: string
  heading?: string
  headingAccent?: string
  description?: string
}

export interface ContactFormBlockData {
  blockType: 'contactForm'
  id?: string
  heading?: string
  headingAccent?: string
  description?: string
}

export interface CTABlockData {
  blockType: 'cta'
  id?: string
  heading: string
  description?: string
  buttonLabel: string
  buttonHref: string
  style?: 'gradient' | 'glass'
}

export interface ImageBlockData {
  blockType: 'image'
  id?: string
  image: CMSMedia | string
  caption?: string
  size?: 'small' | 'medium' | 'full'
}

export interface SpacerBlockData {
  blockType: 'spacer'
  id?: string
  size: 'sm' | 'md' | 'lg' | 'xl'
}

export type PageBlock =
  | HeroBlockData
  | RichTextBlockData
  | FeaturedProjectsBlockData
  | ServicesBlockData
  | OfferingsBlockData
  | TechnologyBlockData
  | ContactFormBlockData
  | CTABlockData
  | ImageBlockData
  | SpacerBlockData

export interface CMSPage {
  id: string
  title: string
  slug: string
  status: 'draft' | 'published'
  layout: PageBlock[]
  meta?: {
    metaTitle?: string
    metaDescription?: string
    ogImage?: CMSMedia | string
  }
  publishedAt?: string
  createdAt: string
  updatedAt: string
}
