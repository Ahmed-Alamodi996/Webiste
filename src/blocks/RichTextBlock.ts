import type { Block } from 'payload'

export const RichTextBlock: Block = {
  slug: 'richText',
  labels: { singular: 'Rich Text', plural: 'Rich Text' },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'content_en', label: 'Content (EN)', type: 'richText', required: true, admin: { width: '50%' } },
        { name: 'content_ar', label: 'Content (AR)', type: 'richText', required: true, admin: { width: '50%' } },
      ],
    },
    {
      name: 'maxWidth',
      type: 'select',
      defaultValue: 'prose',
      options: [
        { label: 'Prose (65ch)', value: 'prose' },
        { label: '3XL (768px)', value: '3xl' },
        { label: 'Full Width', value: 'full' },
      ],
    },
  ],
}
