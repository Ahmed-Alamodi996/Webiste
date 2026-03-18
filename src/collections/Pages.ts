import type { CollectionConfig } from 'payload'
import {
  HeroBlock,
  RichTextBlock,
  FeaturedProjectsBlock,
  ServicesBlock,
  OfferingsBlock,
  TechnologyBlock,
  ContactFormBlock,
  CTABlock,
  ImageBlock,
  SpacerBlock,
} from '../blocks'

const RESERVED_PREFIXES = ['projects', 'api', 'admin']

export const Pages: CollectionConfig = {
  slug: 'pages',
  labels: { singular: 'Page', plural: 'Pages' },
  access: {
    read: () => true,
    create: ({ req: { user } }) => Boolean(user),
    update: ({ req: { user } }) => Boolean(user),
    delete: ({ req: { user } }) => Boolean(user),
  },
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'slug', 'status', 'updatedAt'],
  },
  versions: { drafts: true },
  hooks: {
    beforeValidate: [
      ({ data }) => {
        if (data?.slug) {
          // Sanitize: lowercase, replace spaces/special chars with hyphens
          data.slug = data.slug
            .toLowerCase()
            .replace(/[^a-z0-9/\-]/g, '-')
            .replace(/-+/g, '-')
            .replace(/^-|-$/g, '')
        }
        return data
      },
    ],
  },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'title_en', label: 'Title (EN)', type: 'text', required: true, admin: { width: '50%' } },
        { name: 'title_ar', label: 'Title (AR)', type: 'text', required: true, admin: { width: '50%' } },
      ],
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      index: true,
      admin: {
        description: 'URL path for the page (e.g. "about" → /about)',
      },
      validate: (value: string | undefined | null) => {
        if (!value) return 'Slug is required'
        const first = value.split('/')[0]
        if (RESERVED_PREFIXES.includes(first)) {
          return `Slug cannot start with reserved prefix: ${first}`
        }
        return true
      },
    },
    {
      name: 'layout',
      type: 'blocks',
      label: 'Page Builder',
      blocks: [
        HeroBlock,
        RichTextBlock,
        FeaturedProjectsBlock,
        ServicesBlock,
        OfferingsBlock,
        TechnologyBlock,
        ContactFormBlock,
        CTABlock,
        ImageBlock,
        SpacerBlock,
      ],
    },
    {
      name: 'status',
      type: 'select',
      defaultValue: 'draft',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Published', value: 'published' },
      ],
      admin: { position: 'sidebar' },
    },
    {
      name: 'publishedAt',
      type: 'date',
      admin: { position: 'sidebar' },
    },
    // SEO tab
    {
      name: 'meta',
      type: 'group',
      label: 'SEO',
      admin: { description: 'Search engine optimization fields' },
      fields: [
        {
          type: 'row',
          fields: [
            { name: 'metaTitle_en', label: 'Meta Title (EN)', type: 'text', admin: { width: '50%' } },
            { name: 'metaTitle_ar', label: 'Meta Title (AR)', type: 'text', admin: { width: '50%' } },
          ],
        },
        {
          type: 'row',
          fields: [
            { name: 'metaDescription_en', label: 'Meta Description (EN)', type: 'textarea', admin: { width: '50%' } },
            { name: 'metaDescription_ar', label: 'Meta Description (AR)', type: 'textarea', admin: { width: '50%' } },
          ],
        },
        { name: 'ogImage', type: 'upload', relationTo: 'media' },
      ],
    },
  ],
}
