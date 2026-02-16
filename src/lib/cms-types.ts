// Types for CMS data passed from server to client components

export interface CMSProject {
  id: string
  title: string
  category: string
  description: string
  stat: string
  statLabel: string
  gradient: string
  accentColor: string
  order: number
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
