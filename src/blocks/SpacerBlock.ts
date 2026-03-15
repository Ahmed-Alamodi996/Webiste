import type { Block } from 'payload'

export const SpacerBlock: Block = {
  slug: 'spacer',
  labels: { singular: 'Spacer', plural: 'Spacers' },
  fields: [
    {
      name: 'size',
      type: 'select',
      defaultValue: 'md',
      required: true,
      options: [
        { label: 'Small (2rem)', value: 'sm' },
        { label: 'Medium (4rem)', value: 'md' },
        { label: 'Large (6rem)', value: 'lg' },
        { label: 'Extra Large (10rem)', value: 'xl' },
      ],
    },
  ],
}
