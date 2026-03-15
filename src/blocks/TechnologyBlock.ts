import type { Block } from 'payload'

export const TechnologyBlock: Block = {
  slug: 'technology',
  labels: { singular: 'Technology', plural: 'Technology' },
  fields: [
    { name: 'label', type: 'text', localized: true },
    { name: 'heading', type: 'text', localized: true },
    { name: 'headingAccent', type: 'text', localized: true },
    { name: 'description', type: 'textarea', localized: true },
  ],
}
