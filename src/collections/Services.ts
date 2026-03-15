import type { CollectionConfig } from 'payload'

export const Services: CollectionConfig = {
  slug: 'services',
  access: {
    read: () => true,
    create: ({ req: { user } }) => Boolean(user),
    update: ({ req: { user } }) => Boolean(user),
    delete: ({ req: { user } }) => Boolean(user),
  },
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
      name: 'overview',
      type: 'textarea',
      required: true,
      localized: true,
    },
    {
      name: 'technologies',
      type: 'array',
      fields: [
        {
          name: 'name',
          type: 'text',
          required: true,
        },
      ],
    },
    {
      name: 'accentColor',
      type: 'text',
      required: true,
      validate: (value: string | undefined | null) => {
        if (!value) return 'Accent color is required'
        if (!/^#[0-9A-Fa-f]{6}$/.test(value)) {
          return 'Must be a valid hex color (e.g. #00C896)'
        }
        return true
      },
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
