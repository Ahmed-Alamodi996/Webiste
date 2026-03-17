import type { GlobalConfig } from 'payload'

export const SiteContent: GlobalConfig = {
  slug: 'site-content',
  label: 'Site Content',
  admin: {
    group: 'Content',
  },
  fields: [
    // ─── Theme & Design ───────────────────────────────
    {
      name: 'theme',
      type: 'group',
      label: 'Theme & Design',
      admin: {
        description: 'Control colors, animations, and visual effects across the entire site',
      },
      fields: [
        // Colors
        {
          name: 'brandPrimary',
          type: 'text',
          defaultValue: '#00C896',
          admin: { description: 'Primary brand color (hex). Used for accents, buttons, glows. Default: #00C896' },
        },
        {
          name: 'brandSecondary',
          type: 'text',
          defaultValue: '#2563EB',
          admin: { description: 'Secondary brand color (hex). Used in gradients. Default: #2563EB' },
        },
        {
          name: 'gradientAngle',
          type: 'number',
          defaultValue: 135,
          admin: { description: 'Gradient angle in degrees. Default: 135' },
        },
        // Theme defaults
        {
          name: 'defaultTheme',
          type: 'select',
          defaultValue: 'dark',
          options: [
            { label: 'Dark', value: 'dark' },
            { label: 'Light', value: 'light' },
          ],
          admin: { description: 'Default color theme for new visitors' },
        },
        {
          name: 'defaultViewMode',
          type: 'select',
          defaultValue: 'slides',
          options: [
            { label: 'Slides (presentation)', value: 'slides' },
            { label: 'Scroll (traditional)', value: 'scroll' },
          ],
          admin: { description: 'Default navigation mode' },
        },
        // Animation & transitions
        {
          name: 'animationSpeed',
          type: 'select',
          defaultValue: 'normal',
          options: [
            { label: 'Fast', value: 'fast' },
            { label: 'Normal', value: 'normal' },
            { label: 'Slow (cinematic)', value: 'slow' },
          ],
          admin: { description: 'Global animation speed for transitions' },
        },
        // Visual effects toggles
        {
          name: 'enableParticles',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show particle grid on hero section' },
        },
        {
          name: 'enableAurora',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show aurora beam effects on hero' },
        },
        {
          name: 'enableFloatingOrbs',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show animated background orbs' },
        },
        {
          name: 'enableNoiseTexture',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show subtle noise texture overlay' },
        },
        {
          name: 'enableCustomCursor',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show custom cursor with glow trail (desktop only)' },
        },
        {
          name: 'enableGradientMesh',
          type: 'checkbox',
          defaultValue: true,
          admin: { description: 'Show animated gradient mesh backgrounds on sections' },
        },
        // Section accent colors
        {
          name: 'sectionAccents',
          type: 'array',
          admin: { description: 'Accent color for each section (Hero, Offer, Projects, About, Services, Tech, Contact)' },
          fields: [
            { name: 'color', type: 'text', required: true, admin: { description: 'Hex color e.g. #00C896' } },
          ],
        },
      ],
    },

    // ─── Nav ────────────────────────────────────────────
    {
      name: 'nav',
      type: 'group',
      fields: [
        { name: 'services', type: 'text', required: true, localized: true },
        { name: 'projects', type: 'text', required: true, localized: true },
        { name: 'about', type: 'text', required: true, localized: true },
        { name: 'technology', type: 'text', required: true, localized: true },
        { name: 'contact', type: 'text', required: true, localized: true },
        { name: 'getInTouch', type: 'text', required: true, localized: true },
      ],
    },

    // ─── Hero ───────────────────────────────────────────
    {
      name: 'hero',
      type: 'group',
      fields: [
        { name: 'tagline', type: 'text', required: true, localized: true },
        {
          name: 'headlineLine1',
          type: 'array',
          localized: true,
          fields: [{ name: 'word', type: 'text', required: true }],
        },
        {
          name: 'headlineLine2',
          type: 'array',
          localized: true,
          fields: [{ name: 'word', type: 'text', required: true }],
        },
        { name: 'description', type: 'textarea', required: true, localized: true },
        { name: 'exploreSolutions', type: 'text', required: true, localized: true },
        { name: 'getInTouch', type: 'text', required: true, localized: true },
        { name: 'trustedBy', type: 'text', required: true, localized: true },
        { name: 'statsProjects', type: 'text', localized: true, defaultValue: 'Projects Delivered' },
        { name: 'statsUptime', type: 'text', localized: true, defaultValue: 'Uptime SLA' },
        { name: 'statsSupport', type: 'text', localized: true, defaultValue: 'Support' },
        { name: 'next', type: 'text', required: true, localized: true },
      ],
    },

    // ─── About ──────────────────────────────────────────
    {
      name: 'about',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'headingLine1', type: 'text', required: true, localized: true },
        { name: 'headingWord1', type: 'text', required: true, localized: true },
        { name: 'headingLine2', type: 'text', required: true, localized: true },
        { name: 'headingWord2', type: 'text', required: true, localized: true },
        { name: 'paragraph1', type: 'textarea', required: true, localized: true },
        { name: 'paragraph2', type: 'textarea', required: true, localized: true },
        {
          name: 'stats',
          type: 'array',
          fields: [
            { name: 'target', type: 'number', required: true },
            { name: 'suffix', type: 'text', required: true },
            { name: 'label', type: 'text', required: true, localized: true },
          ],
        },
      ],
    },

    // ─── Offer ──────────────────────────────────────────
    {
      name: 'offer',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'heading', type: 'text', required: true, localized: true },
        { name: 'headingAccent', type: 'text', required: true, localized: true },
        { name: 'description', type: 'textarea', required: true, localized: true },
      ],
    },

    // ─── Services ───────────────────────────────────────
    {
      name: 'services',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'heading', type: 'text', required: true, localized: true },
        { name: 'headingAccent', type: 'text', required: true, localized: true },
        { name: 'description', type: 'textarea', required: true, localized: true },
        { name: 'learnMore', type: 'text', required: true, localized: true },
      ],
    },

    // ─── Projects ───────────────────────────────────────
    {
      name: 'projects',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'heading', type: 'text', required: true, localized: true },
        { name: 'headingAccent', type: 'text', required: true, localized: true },
        { name: 'description', type: 'textarea', required: true, localized: true },
        { name: 'viewCaseStudy', type: 'text', required: true, localized: true },
      ],
    },

    // ─── Technology ─────────────────────────────────────
    {
      name: 'technology',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'heading', type: 'text', required: true, localized: true },
        { name: 'headingAccent', type: 'text', required: true, localized: true },
        { name: 'description', type: 'textarea', required: true, localized: true },
      ],
    },

    // ─── Contact ────────────────────────────────────────
    {
      name: 'contact',
      type: 'group',
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'heading', type: 'text', required: true, localized: true },
        { name: 'headingAccent', type: 'text', required: true, localized: true },
        { name: 'description', type: 'textarea', required: true, localized: true },
        {
          name: 'features',
          type: 'array',
          localized: true,
          fields: [{ name: 'text', type: 'text', required: true }],
        },
        {
          name: 'form',
          type: 'group',
          fields: [
            { name: 'name', type: 'text', required: true, localized: true },
            { name: 'namePlaceholder', type: 'text', required: true, localized: true },
            { name: 'email', type: 'text', required: true, localized: true },
            { name: 'emailPlaceholder', type: 'text', required: true, localized: true },
            { name: 'message', type: 'text', required: true, localized: true },
            { name: 'messagePlaceholder', type: 'text', required: true, localized: true },
            { name: 'send', type: 'text', required: true, localized: true },
            { name: 'successTitle', type: 'text', required: true, localized: true },
            { name: 'successMessage', type: 'text', required: true, localized: true },
          ],
        },
      ],
    },

    // ─── Branding ──────────────────────────────────────
    {
      name: 'branding',
      type: 'group',
      label: 'Branding & SEO',
      fields: [
        { name: 'siteName', type: 'text', required: true, defaultValue: 'InST', admin: { description: 'Short site name shown in navbar and footer' } },
        { name: 'siteFullName', type: 'text', required: true, defaultValue: 'Innovative Solutions Tech', admin: { description: 'Full company name for SEO' } },
        { name: 'siteDescription', type: 'textarea', required: true, localized: true, admin: { description: 'Meta description for SEO' } },
        { name: 'logoText', type: 'text', required: true, defaultValue: 'In', admin: { description: 'Text inside the logo square (e.g. "In")' } },
        { name: 'logo', type: 'upload', relationTo: 'media', admin: { description: 'Logo image (replaces text logo if set)' } },
        { name: 'favicon', type: 'upload', relationTo: 'media', admin: { description: 'Favicon / browser tab icon' } },
        { name: 'contactEmail', type: 'email', required: true, defaultValue: 'info@inst-sa.com', admin: { description: 'Email that receives contact form submissions' } },
      ],
    },

    // ─── Social Media Links ───────────────────────────
    {
      name: 'social',
      type: 'group',
      label: 'Social Media',
      fields: [
        { name: 'linkedinUrl', type: 'text', defaultValue: 'https://linkedin.com/company/inst-tech', admin: { description: 'LinkedIn company page URL' } },
        { name: 'twitterUrl', type: 'text', defaultValue: 'https://x.com/inst_tech', admin: { description: 'Twitter/X profile URL' } },
        { name: 'githubUrl', type: 'text', defaultValue: 'https://github.com/inst-tech', admin: { description: 'GitHub organization URL' } },
        { name: 'instagramUrl', type: 'text', admin: { description: 'Instagram profile URL (optional)' } },
        { name: 'youtubeUrl', type: 'text', admin: { description: 'YouTube channel URL (optional)' } },
      ],
    },

    // ─── Footer ─────────────────────────────────────────
    {
      name: 'footer',
      type: 'group',
      fields: [
        { name: 'copyright', type: 'text', required: true, localized: true },
        {
          name: 'company',
          type: 'group',
          fields: [
            { name: 'about', type: 'text', required: true, localized: true },
            { name: 'services', type: 'text', required: true, localized: true },
            { name: 'projects', type: 'text', required: true, localized: true },
          ],
        },
        {
          name: 'connect',
          type: 'group',
          fields: [
            { name: 'linkedin', type: 'text', required: true, localized: true },
            { name: 'twitter', type: 'text', required: true, localized: true },
            { name: 'github', type: 'text', required: true, localized: true },
          ],
        },
      ],
    },

    // ─── Slides ─────────────────────────────────────────
    {
      name: 'slides',
      type: 'group',
      fields: [
        {
          name: 'names',
          type: 'array',
          localized: true,
          fields: [{ name: 'name', type: 'text', required: true }],
        },
      ],
    },
  ],
}
