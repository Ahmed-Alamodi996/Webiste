import type { Block } from 'payload'

export const ContactFormBlock: Block = {
  slug: 'contactForm',
  labels: { singular: 'Contact Form', plural: 'Contact Forms' },
  fields: [
    { name: 'heading', type: 'text', localized: true },
    { name: 'headingAccent', type: 'text', localized: true },
    { name: 'description', type: 'textarea', localized: true },
  ],
}
