import type { Block } from 'payload'

export const CTABlock: Block = {
  slug: 'cta',
  labels: { singular: 'CTA', plural: 'CTAs' },
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
        { name: 'description_en', label: 'Description (EN)', type: 'textarea', admin: { width: '50%' } },
        { name: 'description_ar', label: 'Description (AR)', type: 'textarea', admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'buttonLabel_en', label: 'Button Label (EN)', type: 'text', required: true, admin: { width: '50%' } },
        { name: 'buttonLabel_ar', label: 'Button Label (AR)', type: 'text', required: true, admin: { width: '50%' } },
      ],
    },
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
