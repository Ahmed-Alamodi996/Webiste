import type { Block } from 'payload'

export const FeaturedProjectsBlock: Block = {
  slug: 'featuredProjects',
  labels: { singular: 'Featured Projects', plural: 'Featured Projects' },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'label_en', label: 'Label (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'label_ar', label: 'Label (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'heading_en', label: 'Heading (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'heading_ar', label: 'Heading (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      type: 'row',
      fields: [
        { name: 'headingAccent_en', label: 'Heading Accent (EN)', type: 'text', admin: { width: '50%' } },
        { name: 'headingAccent_ar', label: 'Heading Accent (AR)', type: 'text', admin: { width: '50%' } },
      ],
    },
    {
      name: 'maxItems',
      type: 'number',
      defaultValue: 4,
      admin: { description: 'Maximum number of projects to show' },
    },
  ],
}
