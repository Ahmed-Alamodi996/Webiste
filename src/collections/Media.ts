import type { CollectionConfig } from 'payload'

export const Media: CollectionConfig = {
  slug: 'media',
  access: {
    read: () => true,
    create: ({ req: { user } }) => Boolean(user),
    update: ({ req: { user } }) => Boolean(user),
    delete: ({ req: { user } }) => Boolean(user),
  },
  upload: {
    staticDir: 'media',
    mimeTypes: [
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/avif',
      'image/gif',
      'video/mp4',
      'video/webm',
    ],
    // Prevent excessively large uploads
    filesRequiredOnCreate: false,
  },
  hooks: {
    beforeChange: [
      ({ data, req }) => {
        // Reject files larger than 10MB
        if (req.file && req.file.size > 10 * 1024 * 1024) {
          throw new Error('File size must be under 10MB')
        }
        return data
      },
    ],
  },
  fields: [
    {
      name: 'alt',
      type: 'text',
      localized: true,
      admin: {
        description: 'Descriptive alt text for accessibility',
      },
    },
  ],
}
