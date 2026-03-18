import type { Block } from 'payload'

export const HeroBlock: Block = {
  slug: 'hero',
  labels: { singular: 'Hero', plural: 'Heroes' },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'heading_en', label: 'Heading (EN)', type: 'text', required: true, admin: { width: '50%' } },
        { name: 'heading_ar', label: 'Heading (AR)', type: 'text', required: true, admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'headingAccent_en', label: 'Heading Accent (EN)', type: 'text', admin: { width: '50%', description: 'Gradient-highlighted portion of the heading' } },
        { name: 'headingAccent_ar', label: 'Heading Accent (AR)', type: 'text', admin: { width: '50%', description: 'Gradient-highlighted portion of the heading' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'description_en', label: 'Description (EN)', type: 'textarea', admin: { width: '50%' } },
        { name: 'description_ar', label: 'Description (AR)', type: 'textarea', admin: { width: '50%' } },
      ],
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
        {
          type: 'row',
          fields: [
            { name: 'label_en', label: 'Label (EN)', type: 'text', required: true, admin: { width: '50%' } },
            { name: 'label_ar', label: 'Label (AR)', type: 'text', required: true, admin: { width: '50%' } },
          ],
        },
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
