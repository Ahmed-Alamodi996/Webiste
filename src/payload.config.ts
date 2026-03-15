import { buildConfig } from 'payload'
import { mongooseAdapter } from '@payloadcms/db-mongodb'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import path from 'path'
import { fileURLToPath } from 'url'

import { Users } from './collections/Users'
import { Projects } from './collections/Projects'
import { Offerings } from './collections/Offerings'
import { Services } from './collections/Services'
import { Technologies } from './collections/Technologies'
import { FormSubmissions } from './collections/FormSubmissions'
import { Media } from './collections/Media'
import { Pages } from './collections/Pages'
import { SiteContent } from './globals/SiteContent'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  secret: (() => {
    const secret = process.env.PAYLOAD_SECRET
    if (!secret) throw new Error('PAYLOAD_SECRET environment variable is required')
    return secret
  })(),
  db: mongooseAdapter({
    url: process.env.MONGODB_URI || 'mongodb://localhost:27017/inst-website',
  }),
  editor: lexicalEditor(),
  localization: {
    locales: [
      { label: 'English', code: 'en' },
      { label: 'Arabic', code: 'ar' },
    ],
    defaultLocale: 'en',
  },
  collections: [Users, Media, Projects, Offerings, Services, Technologies, FormSubmissions, Pages],
  globals: [SiteContent],
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  admin: {
    user: 'users',
  },
})
