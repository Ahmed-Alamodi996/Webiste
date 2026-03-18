import type { Block } from 'payload'

export const ImageBlock: Block = {
  slug: 'image',
  labels: { singular: 'Image', plural: 'Images' },
  fields: [
    {
      name: 'image',
      type: 'upload',
      relationTo: 'media',
      required: true,
    },
    {
      type: 'row',
      fields: [
        { name: 'caption_en', label: 'Caption (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'caption_ar', label: 'Caption (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      name: 'size',
      type: 'select',
      defaultValue: 'medium',
      options: [
        { label: 'Small (max-w-2xl)', value: 'small' },
        { label: 'Medium (max-w-5xl)', value: 'medium' },
        { label: 'Full Width', value: 'full' },
      ],
    },
  ],
}
