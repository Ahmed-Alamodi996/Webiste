import type { CollectionConfig } from 'payload'

export const Projects: CollectionConfig = {
  slug: 'projects',
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
      name: 'category',
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
      name: 'stat',
      type: 'text',
      required: true,
      admin: {
        description: 'e.g. "50M+", "$2B+", "99.99%"',
      },
    },
    {
      name: 'statLabel',
      type: 'text',
      required: true,
      localized: true,
      admin: {
        description: 'e.g. "predictions/day"',
      },
    },
    {
      name: 'gradient',
      type: 'text',
      required: true,
      admin: {
        description: 'Tailwind gradient classes, e.g. "from-emerald-500/20 to-cyan-500/20"',
      },
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
