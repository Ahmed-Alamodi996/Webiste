import type { CollectionConfig } from 'payload'

export const Technologies: CollectionConfig = {
  slug: 'technologies',
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
