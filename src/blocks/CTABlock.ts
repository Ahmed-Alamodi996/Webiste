import type { Block } from 'payload'

export const CTABlock: Block = {
  slug: 'cta',
  labels: { singular: 'CTA', plural: 'CTAs' },
  fields: [
    { name: 'heading', type: 'text', required: true, localized: true },
    { name: 'description', type: 'textarea', localized: true },
    { name: 'buttonLabel', type: 'text', required: true, localized: true },
    { name: 'buttonHref', type: 'text', required: true },
    {
      name: 'style',
      type: 'select',
      defaultValue: 'gradient',
      options: [
        { label: 'Gradient', value: 'gradient' },
        { label: 'Glass', value: 'glass' },
      ],
    },
  ],
}
