import type { CollectionConfig } from 'payload'

export const Projects: CollectionConfig = {
  slug: 'projects',
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
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      admin: {
        description: 'URL-safe slug, e.g. "neuralflow-platform"',
      },
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
      type: 'select',
      required: true,
      options: [
        { label: 'Emerald to Cyan', value: 'from-emerald-500/20 to-cyan-500/20' },
        { label: 'Blue to Violet', value: 'from-blue-500/20 to-violet-500/20' },
        { label: 'Violet to Pink', value: 'from-violet-500/20 to-pink-500/20' },
        { label: 'Amber to Orange', value: 'from-amber-500/20 to-orange-500/20' },
        { label: 'Rose to Red', value: 'from-rose-500/20 to-red-500/20' },
        { label: 'Cyan to Blue', value: 'from-cyan-500/20 to-blue-500/20' },
        { label: 'Green to Emerald', value: 'from-green-500/20 to-emerald-500/20' },
        { label: 'Purple to Indigo', value: 'from-purple-500/20 to-indigo-500/20' },
      ],
      admin: {
        description: 'Gradient color scheme for the project card',
      },
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
    // --- Rich detail fields (all optional) ---
    {
      name: 'coverImage',
      type: 'upload',
      relationTo: 'media',
      admin: {
        description: 'Hero image displayed at the top of the project detail page',
      },
    },
    {
      name: 'gallery',
      type: 'array',
      admin: {
        description: 'Screenshot gallery for the project',
      },
      fields: [
        {
          name: 'image',
          type: 'upload',
          relationTo: 'media',
          required: true,
        },
      ],
    },
    {
      name: 'content',
      type: 'richText',
      localized: true,
      admin: {
        description: 'Long-form project description / case study',
      },
    },
    {
      name: 'techStack',
      type: 'array',
      admin: {
        description: 'Technologies used in this project',
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
          validate: (value: string | undefined | null) => {
            if (!value) return true
            if (!/^#[0-9A-Fa-f]{6}$/.test(value)) {
              return 'Must be a valid hex color (e.g. #61DAFB)'
            }
            return true
          },
          admin: {
            description: 'Hex color for the badge, e.g. "#61DAFB"',
          },
        },
      ],
    },
    {
      name: 'video',
      type: 'group',
      admin: {
        description: 'Optional video embed',
      },
      fields: [
        {
          name: 'url',
          type: 'text',
          validate: (value: string | undefined | null) => {
            if (!value) return true
            try {
              const url = new URL(value)
              if (!['http:', 'https:'].includes(url.protocol)) {
                return 'URL must use http or https protocol'
              }
              return true
            } catch {
              return 'Must be a valid URL'
            }
          },
          admin: {
            description: 'YouTube/Vimeo URL or direct video URL',
          },
        },
        {
          name: 'provider',
          type: 'select',
          options: [
            { label: 'YouTube', value: 'youtube' },
            { label: 'Vimeo', value: 'vimeo' },
            { label: 'Direct', value: 'direct' },
          ],
          defaultValue: 'youtube',
        },
      ],
    },
    {
      name: 'liveUrl',
      type: 'text',
      validate: (value: string | undefined | null) => {
        if (!value) return true
        try {
          const url = new URL(value)
          if (!['http:', 'https:'].includes(url.protocol)) {
            return 'URL must use http or https protocol'
          }
          return true
        } catch {
          return 'Must be a valid URL (e.g. https://example.com)'
        }
      },
      admin: {
        description: 'Link to the live project (e.g. https://example.com)',
      },
    },
  ],
}
