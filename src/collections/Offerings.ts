import type { CollectionConfig } from 'payload'

export const Offerings: CollectionConfig = {
  slug: 'offerings',
  admin: {
    useAsTitle: 'title',
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      required: true,
      localized: true,
    },
    {
      name: 'description',
      type: 'textarea',
      required: true,
      localized: true,
    },
    {
      name: 'icon',
      type: 'select',
      required: true,
      options: [
        { label: 'Brain', value: 'brain' },
        { label: 'Cloud', value: 'cloud' },
        { label: 'Shield', value: 'shield' },
        { label: 'Zap', value: 'zap' },
        { label: 'Globe', value: 'globe' },
        { label: 'BarChart3', value: 'barChart3' },
      ],
    },
    {
      name: 'accentColor',
      type: 'text',
      required: true,
      admin: {
        description: 'Hex color, e.g. "#00C896"',
      },
    },
    {
      name: 'order',
      type: 'number',
      required: true,
      defaultValue: 0,
    },
  ],
}
