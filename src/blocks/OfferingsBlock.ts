import type { Block } from 'payload'

export const OfferingsBlock: Block = {
  slug: 'offerings',
  labels: { singular: 'Offerings', plural: 'Offerings' },
  fields: [
    { name: 'label', type: 'text', localized: true },
    { name: 'heading', type: 'text', localized: true },
    { name: 'headingAccent', type: 'text', localized: true },
    { name: 'description', type: 'textarea', localized: true },
  ],
}
