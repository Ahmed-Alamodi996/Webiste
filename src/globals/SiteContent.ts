import type { GlobalConfig } from 'payload'

export const SiteContent: GlobalConfig = {
  slug: 'site-content',
  label: 'Site Content',
  admin: {
    group: 'Content',
  },
  fields: [
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
