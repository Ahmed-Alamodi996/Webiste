import type { Block } from 'payload'

export const FeaturedProjectsBlock: Block = {
  slug: 'featuredProjects',
  labels: { singular: 'Featured Projects', plural: 'Featured Projects' },
  fields: [
    { name: 'label', type: 'text', localized: true },
    { name: 'heading', type: 'text', localized: true },
    { name: 'headingAccent', type: 'text', localized: true },
    {
      name: 'maxItems',
      type: 'number',
      defaultValue: 4,
      admin: { description: 'Maximum number of projects to show' },
    },
  ],
}
