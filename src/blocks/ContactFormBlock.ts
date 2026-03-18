import type { Block } from 'payload'

export const ContactFormBlock: Block = {
  slug: 'contactForm',
  labels: { singular: 'Contact Form', plural: 'Contact Forms' },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'heading_en', label: 'Heading (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'heading_ar', label: 'Heading (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'headingAccent_en', label: 'Heading Accent (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'headingAccent_ar', label: 'Heading Accent (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'description_en', label: 'Description (EN)', type: 'textarea', admin: { width: '50%' } },
        { name: 'description_ar', label: 'Description (AR)', type: 'textarea', admin: { width: '50%' } },
      ],
    },
  ],
}
