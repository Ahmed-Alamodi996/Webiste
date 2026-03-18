import type { GlobalConfig, Field } from 'payload'

// Helper: creates a row with EN and AR text fields side by side
function bilingualText(name: string, label: string, opts?: { required?: boolean; type?: 'text' | 'textarea' }): Field {
  const fieldType = opts?.type || 'text'
  return {
    type: 'row',
    fields: [
      {
        name: `${name}_en`,
        label: `${label} (EN)`,
        type: fieldType,
        required: opts?.required,
        admin: { width: '50%' },
      } as Field,
      {
        name: `${name}_ar`,
        label: `${label} (AR)`,
        type: fieldType,
        required: opts?.required,
        admin: { width: '50%' },
      } as Field,
    ],
  }
}

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
      admin: { description: 'Control colors, animations, and visual effects across the entire site' },
      fields: [
        {
          name: 'preset',
          type: 'select',
          defaultValue: 'default',
          admin: { description: 'Quick-apply a preset theme' },
          options: [
            { label: 'Default (Green/Blue)', value: 'default' },
            { label: 'Neon (Cyan/Pink)', value: 'neon' },
            { label: 'Corporate (Blue/Slate)', value: 'corporate' },
            { label: 'Minimal (Gray/Black)', value: 'minimal' },
            { label: 'Sunset (Orange/Purple)', value: 'sunset' },
            { label: 'Ocean (Teal/Navy)', value: 'ocean' },
            { label: 'Royal (Gold/Deep Purple)', value: 'royal' },
            { label: 'Custom (use settings below)', value: 'custom' },
          ],
        },
        {
          type: 'row',
          fields: [
            { name: 'brandPrimary', type: 'text', defaultValue: '#00C896', admin: { width: '33%', description: 'Primary color (hex)' } },
            { name: 'brandSecondary', type: 'text', defaultValue: '#2563EB', admin: { width: '33%', description: 'Secondary color (hex)' } },
            { name: 'gradientAngle', type: 'number', defaultValue: 135, admin: { width: '33%', description: 'Gradient angle (deg)' } },
          ],
        },
        {
          type: 'row',
          fields: [
            { name: 'defaultTheme', type: 'select', defaultValue: 'dark', options: [{ label: 'Dark', value: 'dark' }, { label: 'Light', value: 'light' }], admin: { width: '33%', description: 'Default theme' } },
            { name: 'defaultViewMode', type: 'select', defaultValue: 'slides', options: [{ label: 'Slides', value: 'slides' }, { label: 'Scroll', value: 'scroll' }], admin: { width: '33%', description: 'Default view mode' } },
            { name: 'animationSpeed', type: 'select', defaultValue: 'normal', options: [{ label: 'Fast', value: 'fast' }, { label: 'Normal', value: 'normal' }, { label: 'Slow', value: 'slow' }], admin: { width: '33%', description: 'Animation speed' } },
          ],
        },
        {
          type: 'row',
          fields: [
            { name: 'enableParticles', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
            { name: 'enableAurora', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
            { name: 'enableFloatingOrbs', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
            { name: 'enableNoiseTexture', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
            { name: 'enableCustomCursor', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
            { name: 'enableGradientMesh', type: 'checkbox', defaultValue: true, admin: { width: '16%' } },
          ],
        },
        { name: 'sectionAccents', type: 'array', admin: { description: 'Accent color per section' }, fields: [{ name: 'color', type: 'text', required: true }] },
        { name: 'customCSS', type: 'textarea', admin: { description: 'Custom CSS overrides' } },
        {
          name: 'animations',
          type: 'group',
          label: 'Lottie Animations',
          fields: [
            { name: 'preloaderAnimation', type: 'textarea', admin: { description: 'Lottie JSON for preloader' } },
            { name: 'heroAnimation', type: 'textarea', admin: { description: 'Lottie JSON for hero background' } },
            { name: 'contactSuccessAnimation', type: 'textarea', admin: { description: 'Lottie JSON for form success' } },
          ],
        },
      ],
    },

    // ─── Nav ────────────────────────────────────────────
    {
      name: 'nav',
      type: 'group',
      label: 'Navigation',
      fields: [
        bilingualText('services', 'Services', { required: true }),
        bilingualText('projects', 'Projects', { required: true }),
        bilingualText('about', 'About', { required: true }),
        bilingualText('technology', 'Technology', { required: true }),
        bilingualText('contact', 'Contact', { required: true }),
        bilingualText('getInTouch', 'Get in Touch', { required: true }),
      ],
    },

    // ─── Hero ───────────────────────────────────────────
    {
      name: 'hero',
      type: 'group',
      label: 'Hero Section',
      fields: [
        bilingualText('tagline', 'Tagline', { required: true }),
        {
          type: 'row',
          fields: [
            { name: 'headlineLine1_en', label: 'Headline Line 1 (EN)', type: 'text', required: true, admin: { width: '50%', description: 'Words separated by spaces' } },
            { name: 'headlineLine1_ar', label: 'Headline Line 1 (AR)', type: 'text', required: true, admin: { width: '50%', description: 'Words separated by spaces' } },
          ],
        },
        {
          type: 'row',
          fields: [
            { name: 'headlineLine2_en', label: 'Headline Line 2 — gradient (EN)', type: 'text', required: true, admin: { width: '50%' } },
            { name: 'headlineLine2_ar', label: 'Headline Line 2 — gradient (AR)', type: 'text', required: true, admin: { width: '50%' } },
          ],
        },
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
        bilingualText('exploreSolutions', 'CTA: Explore Solutions', { required: true }),
        bilingualText('getInTouch', 'CTA: Get in Touch', { required: true }),
        bilingualText('trustedBy', 'Trusted By label', { required: true }),
        {
          name: 'stats',
          type: 'array',
          label: 'Hero Stats',
          admin: { description: 'Stats displayed below the hero CTA (e.g. "50+" / "Projects Delivered")' },
          fields: [
            { name: 'value', type: 'text', required: true, admin: { description: 'e.g. "50+", "99.9%", "24/7"' } },
            bilingualText('label', 'Label', { required: true }),
          ],
        },
        bilingualText('next', 'Next button label', { required: true }),
      ],
    },

    // ─── About ──────────────────────────────────────────
    {
      name: 'about',
      type: 'group',
      label: 'About Us Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('headingLine1', 'Heading Line 1', { required: true }),
        bilingualText('headingWord1', 'Heading Accent Word 1', { required: true }),
        bilingualText('headingLine2', 'Heading Line 2', { required: true }),
        bilingualText('headingWord2', 'Heading Accent Word 2', { required: true }),
        bilingualText('paragraph1', 'Paragraph 1', { required: true, type: 'textarea' }),
        bilingualText('paragraph2', 'Paragraph 2', { required: true, type: 'textarea' }),
        {
          name: 'stats',
          type: 'array',
          label: 'Statistics',
          fields: [
            { name: 'target', type: 'number', required: true, admin: { description: 'Number value' } },
            { name: 'suffix', type: 'text', required: true, admin: { description: 'e.g. "+", "%", "K+"' } },
            bilingualText('label', 'Label', { required: true }),
          ],
        },
      ],
    },

    // ─── Offer ──────────────────────────────────────────
    {
      name: 'offer',
      type: 'group',
      label: 'What We Offer Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('heading', 'Heading', { required: true }),
        bilingualText('headingAccent', 'Heading Accent', { required: true }),
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
      ],
    },

    // ─── Services ───────────────────────────────────────
    {
      name: 'services',
      type: 'group',
      label: 'Services Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('heading', 'Heading', { required: true }),
        bilingualText('headingAccent', 'Heading Accent', { required: true }),
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
        bilingualText('learnMore', 'Learn More text', { required: true }),
      ],
    },

    // ─── Projects ───────────────────────────────────────
    {
      name: 'projects',
      type: 'group',
      label: 'Projects Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('heading', 'Heading', { required: true }),
        bilingualText('headingAccent', 'Heading Accent', { required: true }),
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
        bilingualText('viewCaseStudy', 'View Case Study text', { required: true }),
      ],
    },

    // ─── Technology ─────────────────────────────────────
    {
      name: 'technology',
      type: 'group',
      label: 'Technology Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('heading', 'Heading', { required: true }),
        bilingualText('headingAccent', 'Heading Accent', { required: true }),
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
      ],
    },

    // ─── Contact ────────────────────────────────────────
    {
      name: 'contact',
      type: 'group',
      label: 'Contact Section',
      fields: [
        bilingualText('label', 'Section Label', { required: true }),
        bilingualText('heading', 'Heading', { required: true }),
        bilingualText('headingAccent', 'Heading Accent', { required: true }),
        bilingualText('description', 'Description', { required: true, type: 'textarea' }),
        {
          name: 'features',
          type: 'array',
          label: 'Feature Lines',
          fields: [
            bilingualText('text', 'Feature text', { required: true }),
          ],
        },
        {
          name: 'form',
          type: 'group',
          label: 'Form Labels',
          fields: [
            bilingualText('name', 'Name label', { required: true }),
            bilingualText('namePlaceholder', 'Name placeholder', { required: true }),
            bilingualText('email', 'Email label', { required: true }),
            bilingualText('emailPlaceholder', 'Email placeholder', { required: true }),
            bilingualText('message', 'Message label', { required: true }),
            bilingualText('messagePlaceholder', 'Message placeholder', { required: true }),
            bilingualText('send', 'Send button', { required: true }),
            bilingualText('successTitle', 'Success title', { required: true }),
            bilingualText('successMessage', 'Success message', { required: true }),
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
        { name: 'siteName', type: 'text', required: true, defaultValue: 'InST', admin: { description: 'Short site name' } },
        { name: 'siteFullName', type: 'text', required: true, defaultValue: 'Innovative Solutions Tech', admin: { description: 'Full company name' } },
        bilingualText('siteDescription', 'SEO Description', { required: true, type: 'textarea' }),
        { name: 'logoText', type: 'text', required: true, defaultValue: 'In', admin: { description: 'Logo square text' } },
        { name: 'logo', type: 'upload', relationTo: 'media', admin: { description: 'Logo image (replaces text)' } },
        { name: 'favicon', type: 'upload', relationTo: 'media', admin: { description: 'Favicon' } },
        { name: 'contactEmail', type: 'email', required: true, defaultValue: 'info@inst-sa.com' },
      ],
    },

    // ─── Social Media ───────────────────────────────────
    {
      name: 'social',
      type: 'group',
      label: 'Social Media',
      fields: [
        { name: 'linkedinUrl', type: 'text', defaultValue: 'https://linkedin.com/company/inst-tech' },
        { name: 'twitterUrl', type: 'text', defaultValue: 'https://x.com/inst_tech' },
        { name: 'githubUrl', type: 'text', defaultValue: 'https://github.com/inst-tech' },
        { name: 'instagramUrl', type: 'text' },
        { name: 'youtubeUrl', type: 'text' },
      ],
    },

    // ─── Footer ─────────────────────────────────────────
    {
      name: 'footer',
      type: 'group',
      label: 'Footer',
      fields: [
        bilingualText('copyright', 'Copyright text', { required: true }),
        {
          name: 'company',
          type: 'group',
          label: 'Company Links',
          fields: [
            bilingualText('about', 'About link', { required: true }),
            bilingualText('services', 'Services link', { required: true }),
            bilingualText('projects', 'Projects link', { required: true }),
          ],
        },
        {
          name: 'connect',
          type: 'group',
          label: 'Connect Links',
          fields: [
            bilingualText('linkedin', 'LinkedIn label', { required: true }),
            bilingualText('twitter', 'Twitter label', { required: true }),
            bilingualText('github', 'GitHub label', { required: true }),
          ],
        },
      ],
    },

    // ─── Slides ─────────────────────────────────────────
    {
      name: 'slides',
      type: 'group',
      label: 'Slide Names',
      fields: [
        {
          name: 'names',
          type: 'array',
          fields: [
            bilingualText('name', 'Slide Name', { required: true }),
          ],
        },
      ],
    },
  ],
}
