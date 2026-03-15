import type { CollectionConfig } from 'payload'

export const Technologies: CollectionConfig = {
  slug: 'technologies',
  access: {
    read: () => true,
    create: ({ req: { user } }) => Boolean(user),
    update: ({ req: { user } }) => Boolean(user),
    delete: ({ req: { user } }) => Boolean(user),
  },
  admin: {
    useAsTitle: 'name',
  },
  fields: [
    {
      name: 'name',
      type: 'text',
      required: true,
    },
    {
      name: 'color',
      type: 'text',
      required: true,
      validate: (value: string | undefined | null) => {
        if (!value) return 'Color is required'
        if (!/^#[0-9A-Fa-f]{6}$/.test(value)) {
          return 'Must be a valid hex color (e.g. #61DAFB)'
        }
        return true
      },
      admin: {
        description: 'Hex color, e.g. "#61DAFB"',
      },
    },
    {
      name: 'row',
      type: 'select',
      required: true,
      options: [
        { label: 'Row 1', value: '1' },
        { label: 'Row 2', value: '2' },
        { label: 'Row 3', value: '3' },
      ],
    },
    {
      name: 'order',
      type: 'number',
      required: true,
      defaultValue: 0,
    },
  ],
}
