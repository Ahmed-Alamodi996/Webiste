const en = {
  // Theme & Design defaults
  theme: {
    brandPrimary: "#00C896",
    brandSecondary: "#2563EB",
    gradientAngle: 135,
    defaultTheme: "dark" as const,
    defaultViewMode: "slides" as const,
    animationSpeed: "normal" as const,
    enableParticles: true,
    enableAurora: true,
    enableFloatingOrbs: true,
    enableNoiseTexture: true,
    enableCustomCursor: true,
    enableGradientMesh: true,
    sectionAccents: [
      { color: "#00C896" }, // Hero
      { color: "#00C896" }, // Offer
      { color: "#2563EB" }, // Projects
      { color: "#7C3AED" }, // About
      { color: "#F59E0B" }, // Services
      { color: "#EC4899" }, // Technology
      { color: "#00C896" }, // Contact
    ],
  },

  // Navbar
  nav: {
    services: "Services",
    projects: "Projects",
    about: "About",
    technology: "Technology",
    contact: "Contact",
    getInTouch: "Get in Touch",
  },

  // Hero
  hero: {
    tagline: "Next-generation technology solutions",
    headlineLine1: ["Engineering", "the", "Future", "of"],
    headlineLine2: ["Intelligent", "Solutions"],
    description:
      "We architect and deliver enterprise-grade digital products that define industries. From AI-powered platforms to scalable cloud infrastructure — built for the companies shaping tomorrow.",
    exploreSolutions: "Explore Solutions",
    getInTouch: "Get in Touch",
    trustedBy: "Trusted by industry leaders",
    statsProjects: "Projects Delivered",
    statsUptime: "Uptime SLA",
    statsSupport: "Support",
    next: "Next",
  },

  // About
  about: {
    label: "About Us",
    headingLine1: "We don't just build",
    headingWord1: "software",
    headingLine2: "— we engineer",
    headingWord2: "futures.",
    paragraph1:
      "Innovative Solutions Tech was founded on a singular conviction: that the right technology, architected with precision and purpose, can reshape entire industries. We are a team of engineers, designers, and strategists who obsess over the details others overlook.",
    paragraph2:
      "From early-stage startups to Fortune 500 enterprises, we partner with visionary leaders to transform ambitious ideas into resilient, production-grade systems that scale — and that last. Our work spans AI, cloud infrastructure, cybersecurity, and beyond.",
    stats: [
      { target: 12, suffix: "+", label: "Years of Excellence" },
      { target: 200, suffix: "+", label: "Projects Delivered" },
      { target: 85, suffix: "+", label: "Enterprise Clients" },
      { target: 99, suffix: "%", label: "Client Retention" },
    ],
  },

  // What We Offer
  offer: {
    label: "What We Offer",
    heading: "Solutions built for the",
    headingAccent: "next era",
    description:
      "We deliver end-to-end technology solutions that solve complex challenges with elegance, precision, and scale.",
    items: [
      {
        title: "AI & Machine Learning",
        description:
          "Custom AI models, NLP engines, and intelligent automation that transform raw data into strategic advantage.",
      },
      {
        title: "Cloud Architecture",
        description:
          "Scalable, resilient cloud infrastructure on AWS, GCP, and Azure — engineered for 99.99% uptime.",
      },
      {
        title: "Cybersecurity",
        description:
          "Enterprise-grade security frameworks, penetration testing, and zero-trust architecture implementation.",
      },
      {
        title: "Performance Engineering",
        description:
          "Sub-second load times, optimized APIs, and real-time data pipelines built for scale.",
      },
      {
        title: "Web & Mobile Platforms",
        description:
          "Full-stack digital products with pixel-perfect interfaces and seamless cross-platform experiences.",
      },
      {
        title: "Data Analytics",
        description:
          "Real-time dashboards, predictive analytics, and business intelligence solutions that drive decisions.",
      },
    ],
  },

  // Our Services
  services: {
    label: "Our Services",
    heading: "Comprehensive",
    headingAccent: "capabilities",
    description:
      "Full-spectrum technology services, delivered with the rigor and craft that enterprise-grade systems demand.",
    learnMore: "Learn more",
    items: [
      {
        title: "Artificial Intelligence & ML",
        overview:
          "We design and deploy production-grade AI systems — from custom LLMs and computer vision to recommendation engines and autonomous agents. Our models are built for accuracy, speed, and real-world reliability.",
      },
      {
        title: "Cloud & Infrastructure",
        overview:
          "We architect multi-cloud environments optimized for cost, performance, and resilience. From Kubernetes orchestration to serverless computing, we build infrastructure that scales with your ambition.",
      },
      {
        title: "Product Engineering",
        overview:
          "End-to-end product development from ideation to launch. We build web and mobile applications with obsessive attention to performance, accessibility, and user experience.",
      },
      {
        title: "Security & Compliance",
        overview:
          "Enterprise security audits, penetration testing, and compliance frameworks. We implement zero-trust architectures and ensure your systems meet SOC 2, HIPAA, and GDPR standards.",
      },
      {
        title: "Data Engineering & Analytics",
        overview:
          "We build modern data stacks — real-time pipelines, data lakes, and analytics platforms that turn your data into your most powerful competitive advantage.",
      },
    ],
  },

  // Featured Projects
  projects: {
    label: "Featured Projects",
    heading: "Work that",
    headingAccent: "speaks volumes",
    description:
      "A showcase of transformative projects delivered for industry leaders.",
    viewCaseStudy: "View Case Study",
    items: [
      {
        title: "NeuralFlow Platform",
        category: "AI / Machine Learning",
        description:
          "Enterprise AI platform processing 50M+ predictions daily with custom transformer models and real-time inference pipelines.",
        statLabel: "predictions/day",
      },
      {
        title: "CloudVault Infrastructure",
        category: "Cloud / DevOps",
        description:
          "Multi-region cloud architecture serving 100K+ concurrent users with automated scaling and 99.99% uptime guarantee.",
        statLabel: "uptime",
      },
      {
        title: "SecureEdge Framework",
        category: "Cybersecurity",
        description:
          "Zero-trust security framework protecting $2B+ in digital assets with real-time threat detection and response.",
        statLabel: "assets protected",
      },
      {
        title: "DataPulse Analytics",
        category: "Data / Analytics",
        description:
          "Real-time analytics engine processing 1TB+ daily data streams with sub-second query performance and predictive insights.",
        statLabel: "daily data",
      },
    ],
  },

  // Technology
  technology: {
    label: "Technology Stack",
    heading: "Powered by",
    headingAccent: "modern technology",
    description:
      "We leverage the industry's most powerful and proven technologies to build systems that perform at scale.",
  },

  // Contact
  contact: {
    label: "Get in Touch",
    heading: "Let's build something",
    headingAccent: "extraordinary",
    description:
      "Whether you have a clear vision or need help defining the path forward, our team is ready to listen, strategize, and deliver.",
    features: [
      "Free technical consultation",
      "Response within 24 hours",
      "NDA-protected discussions",
    ],
    form: {
      name: "Name",
      namePlaceholder: "Your name",
      email: "Email",
      emailPlaceholder: "you@company.com",
      message: "Message",
      messagePlaceholder: "Tell us about your project...",
      send: "Send Message",
      successTitle: "Message sent!",
      successMessage: "We'll get back to you within 24 hours.",
    },
  },

  // Branding
  branding: {
    siteName: "InST",
    siteFullName: "Innovative Solutions Tech",
    siteDescription: "Premium software engineering and AI solutions for forward-thinking companies.",
    logoText: "In",
    contactEmail: "info@inst-sa.com",
  },

  // Social Media
  social: {
    linkedinUrl: "https://linkedin.com/company/inst-tech",
    twitterUrl: "https://x.com/inst_tech",
    githubUrl: "https://github.com/inst-tech",
  },

  // Footer (merged in Contact)
  footer: {
    copyright: "Innovative Solutions Tech",
    company: {
      about: "About",
      services: "Services",
      projects: "Projects",
    },
    connect: {
      linkedin: "LinkedIn",
      twitter: "Twitter / X",
      github: "GitHub",
    },
  },

  // Slide Indicator
  slides: {
    names: [
      "Home",
      "What We Offer",
      "Projects",
      "About",
      "Services",
      "Technology",
      "Contact",
    ],
  },
};

export type Translations = {
  nav: { services: string; projects: string; about: string; technology: string; contact: string; getInTouch: string };
  hero: { tagline: string; headlineLine1: string[]; headlineLine2: string[]; description: string; exploreSolutions: string; getInTouch: string; trustedBy: string; statsProjects: string; statsUptime: string; statsSupport: string; next: string };
  about: { label: string; headingLine1: string; headingWord1: string; headingLine2: string; headingWord2: string; paragraph1: string; paragraph2: string; stats: { target: number; suffix: string; label: string }[] };
  offer: { label: string; heading: string; headingAccent: string; description: string; items: { title: string; description: string }[] };
  services: { label: string; heading: string; headingAccent: string; description: string; learnMore: string; items: { title: string; overview: string }[] };
  projects: { label: string; heading: string; headingAccent: string; description: string; viewCaseStudy: string; items: { title: string; category: string; description: string; statLabel: string }[] };
  technology: { label: string; heading: string; headingAccent: string; description: string };
  contact: { label: string; heading: string; headingAccent: string; description: string; features: string[]; form: { name: string; namePlaceholder: string; email: string; emailPlaceholder: string; message: string; messagePlaceholder: string; send: string; successTitle: string; successMessage: string } };
  theme?: { brandPrimary?: string; brandSecondary?: string; gradientAngle?: number; defaultTheme?: 'dark' | 'light'; defaultViewMode?: 'slides' | 'scroll'; animationSpeed?: 'fast' | 'normal' | 'slow'; enableParticles?: boolean; enableAurora?: boolean; enableFloatingOrbs?: boolean; enableNoiseTexture?: boolean; enableCustomCursor?: boolean; enableGradientMesh?: boolean; sectionAccents?: { color: string }[]; preset?: string; customCSS?: string; animations?: { preloaderAnimation?: string; heroAnimation?: string; contactSuccessAnimation?: string } };
  branding?: { siteName?: string; siteFullName?: string; siteDescription?: string; logoText?: string; contactEmail?: string };
  social?: { linkedinUrl?: string; twitterUrl?: string; githubUrl?: string; instagramUrl?: string; youtubeUrl?: string };
  footer: { copyright: string; company: { about: string; services: string; projects: string }; connect: { linkedin: string; twitter: string; github: string } };
  slides: { names: string[] };
};

export default en as Translations;
