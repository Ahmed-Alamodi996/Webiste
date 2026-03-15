import type { Block } from 'payload'

export const HeroBlock: Block = {
  slug: 'hero',
  labels: { singular: 'Hero', plural: 'Heroes' },
  fields: [
    {
      name: 'heading',
      type: 'text',
      required: true,
      localized: true,
    },
    {
      name: 'headingAccent',
      type: 'text',
      localized: true,
      admin: { description: 'Gradient-highlighted portion of the heading' },
    },
    {
      name: 'description',
      type: 'textarea',
      localized: true,
    },
    {
      name: 'backgroundImage',
      type: 'upload',
      relationTo: 'media',
    },
    {
      name: 'ctas',
      type: 'array',
      label: 'Call-to-Action Buttons',
      maxRows: 3,
      fields: [
        { name: 'label', type: 'text', required: true, localized: true },
        { name: 'href', type: 'text', required: true },
        {
          name: 'variant',
          type: 'select',
          defaultValue: 'primary',
          options: [
            { label: 'Primary (Gradient)', value: 'primary' },
            { label: 'Secondary (Glass)', value: 'secondary' },
          ],
        },
      ],
    },
  ],
}
