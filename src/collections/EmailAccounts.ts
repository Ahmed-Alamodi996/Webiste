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

        // Handle password change
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

        // Handle disable/enable
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
        {
          name: 'username',
          type: 'text',
          required: true,
          admin: { width: '40%', description: 'e.g. "info", "admin", "support"' },
        },
        {
          name: 'domain',
          type: 'select',
          required: true,
          defaultValue: 'inst.sa',
          options: [
            { label: 'inst.sa', value: 'inst.sa' },
            { label: 'inst-sa.com', value: 'inst-sa.com' },
          ],
          admin: { width: '30%' },
        },
        {
          name: 'status',
          type: 'select',
          defaultValue: 'active',
          options: [
            { label: 'Active', value: 'active' },
            { label: 'Disabled', value: 'disabled' },
          ],
          admin: { width: '30%' },
        },
      ],
    },
    {
      name: 'email',
      type: 'text',
      unique: true,
      admin: {
        description: 'Full email address (auto-filled from username + domain)',
      },
    },
    {
      name: 'initialPassword',
      type: 'text',
      required: true,
      admin: {
        description: 'Password for the email account. Use a strong password.',
      },
    },
    {
      name: 'changePassword',
      type: 'text',
      admin: {
        description: 'Enter a new password here and save to change the email account password. Leave empty to keep current.',
      },
    },
    {
      name: 'mailServerSettings',
      type: 'group',
      label: 'Connection Settings (for email clients)',
      admin: {
        readOnly: true,
        description: 'Use these settings in Outlook, Thunderbird, Gmail app, etc.',
      },
      fields: [
        { name: 'imapServer', type: 'text', defaultValue: 'mail.inst.sa', admin: { readOnly: true, description: 'IMAP Server' } },
        { name: 'imapPort', type: 'text', defaultValue: '993', admin: { readOnly: true, description: 'IMAP Port (SSL)' } },
        { name: 'smtpServer', type: 'text', defaultValue: 'mail.inst.sa', admin: { readOnly: true, description: 'SMTP Server' } },
        { name: 'smtpPort', type: 'text', defaultValue: '587', admin: { readOnly: true, description: 'SMTP Port (STARTTLS)' } },
      ],
    },
  ],
}
