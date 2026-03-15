import type { Block } from 'payload'

export const RichTextBlock: Block = {
  slug: 'richText',
  labels: { singular: 'Rich Text', plural: 'Rich Text' },
  fields: [
    {
      name: 'content',
      type: 'richText',
      required: true,
      localized: true,
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
