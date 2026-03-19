import type { CollectionConfig } from 'payload'

export const EmailAccounts: CollectionConfig = {
  slug: 'email-accounts',
  labels: { singular: 'Email Account', plural: 'Email Accounts' },
  admin: {
    useAsTitle: 'email',
    group: 'System',
    defaultColumns: ['email', 'domain', 'status', 'createdAt'],
    description: 'Manage email accounts for your domains. Create/delete accounts here.',
  },
  access: {
    read: ({ req: { user } }) => Boolean(user),
    create: ({ req: { user } }) => Boolean(user),
    update: ({ req: { user } }) => Boolean(user),
    delete: ({ req: { user } }) => Boolean(user),
  },
  hooks: {
    beforeValidate: [
      ({ data }) => {
        if (data?.username && data?.domain) {
          data.email = `${data.username}@${data.domain}`
        }
        return data
      },
    ],
    afterRead: [
      ({ doc }) => {
        if (doc.email) {
          const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://inst-sa.com'
          doc.setupLinks = {
            setupPage: `${baseUrl}/api/email-setup?email=${doc.email}&type=page`,
            iosProfile: `${baseUrl}/api/email-setup?email=${doc.email}&type=ios`,
          }
        }
        return doc
      },
    ],
    afterChange: [
      async ({ doc, operation, previousDoc }) => {
        const { exec } = await import('child_process')
        const { promisify } = await import('util')
        const execAsync = promisify(exec)

        if (operation === 'create' && doc.status === 'active') {
          try {
            await execAsync(
              `docker exec inst-mail setup email add ${doc.email} '${doc.initialPassword}'`,
              { timeout: 15000 }
            )
            console.log(`Email account created: ${doc.email}`)
          } catch (err) {
            console.error(`Failed to create email account ${doc.email}:`, err)
          }
        }

        if (operation === 'update' && doc.changePassword) {
          try {
            await execAsync(
              `docker exec inst-mail setup email update ${doc.email} '${doc.changePassword}'`,
              { timeout: 15000 }
            )
            console.log(`Password changed for: ${doc.email}`)
          } catch (err) {
            console.error(`Failed to change password for ${doc.email}:`, err)
          }
        }

        if (operation === 'update' && previousDoc?.status !== doc.status) {
          if (doc.status === 'disabled') {
            try {
              await execAsync(`docker exec inst-mail setup email restrict add send ${doc.email}`, { timeout: 15000 })
              await execAsync(`docker exec inst-mail setup email restrict add receive ${doc.email}`, { timeout: 15000 })
              console.log(`Email account disabled: ${doc.email}`)
            } catch (err) {
              console.error(`Failed to disable ${doc.email}:`, err)
            }
          } else if (doc.status === 'active') {
            try {
              await execAsync(`docker exec inst-mail setup email restrict del send ${doc.email}`, { timeout: 15000 })
              await execAsync(`docker exec inst-mail setup email restrict del receive ${doc.email}`, { timeout: 15000 })
              console.log(`Email account enabled: ${doc.email}`)
            } catch (err) {
              console.error(`Failed to enable ${doc.email}:`, err)
            }
          }
        }
      },
    ],
    afterDelete: [
      async ({ doc }) => {
        try {
          const { exec } = await import('child_process')
          const { promisify } = await import('util')
          const execAsync = promisify(exec)
          await execAsync(
            `docker exec inst-mail setup email del ${doc.email}`,
            { timeout: 15000 }
          )
          console.log(`Email account deleted: ${doc.email}`)
        } catch (err) {
          console.error(`Failed to delete email account ${doc.email}:`, err)
        }
      },
    ],
  },
  fields: [
    {
      type: 'row',
      fields: [
        { name: 'username', type: 'text', required: true, admin: { width: '40%', description: 'e.g. "info", "admin", "support"' } },
        { name: 'domain', type: 'select', required: true, defaultValue: 'inst.sa', options: [{ label: 'inst.sa', value: 'inst.sa' }, { label: 'inst-sa.com', value: 'inst-sa.com' }], admin: { width: '30%' } },
        { name: 'status', type: 'select', defaultValue: 'active', options: [{ label: 'Active', value: 'active' }, { label: 'Disabled', value: 'disabled' }], admin: { width: '30%' } },
      ],
    },
    { name: 'email', type: 'text', unique: true, admin: { description: 'Full email address (auto-filled from username + domain)' } },
    { name: 'initialPassword', type: 'text', required: true, admin: { description: 'Password for the email account.' } },
    { name: 'changePassword', type: 'text', admin: { description: 'Enter new password and save to change. Leave empty to keep current.' } },
    {
      name: 'mailServerSettings',
      type: 'group',
      label: 'Connection Settings',
      admin: { description: 'Use these settings in Outlook, Thunderbird, Gmail app, etc.' },
      fields: [
        { name: 'imapServer', type: 'text', defaultValue: 'mail.inst.sa', admin: { readOnly: true, description: 'IMAP Server' } },
        { name: 'imapPort', type: 'text', defaultValue: '993', admin: { readOnly: true, description: 'IMAP Port (SSL/TLS)' } },
        { name: 'smtpServer', type: 'text', defaultValue: 'mail.inst.sa', admin: { readOnly: true, description: 'SMTP Server' } },
        { name: 'smtpPort', type: 'text', defaultValue: '465', admin: { readOnly: true, description: 'SMTP Port (SSL/TLS)' } },
      ],
    },
    {
      name: 'setupLinks',
      type: 'group',
      label: 'Quick Setup Links (share with users)',
      admin: { description: 'Send these links to users — iOS auto-installs, others show instructions' },
      fields: [
        { name: 'setupPage', type: 'text', admin: { readOnly: true, description: 'Setup instructions page' } },
        { name: 'iosProfile', type: 'text', admin: { readOnly: true, description: 'iOS auto-install profile download' } },
      ],
    },
  ],
}
