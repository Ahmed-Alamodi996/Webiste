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
  // Rich detail fields (optional)
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

export interface CMSTechnology {
  id: string
  name: string
  color: string
  row: '1' | '2' | '3'
  order: number
}

export interface CMSSiteContent {
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
