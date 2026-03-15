import type { Block } from 'payload'

export const ServicesBlock: Block = {
  slug: 'services',
  labels: { singular: 'Services', plural: 'Services' },
  fields: [
    { name: 'label', type: 'text', localized: true },
    { name: 'heading', type: 'text', localized: true },
    { name: 'headingAccent', type: 'text', localized: true },
    { name: 'description', type: 'textarea', localized: true },
  ],
}
