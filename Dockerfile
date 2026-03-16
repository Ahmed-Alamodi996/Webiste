# ============================================
# Multi-stage production Dockerfile
# ============================================

# --- Stage 1: Install dependencies ---
FROM node:20-alpine AS deps
WORKDIR /app

# Increase Node.js memory for heavy installs
ENV NODE_OPTIONS="--max-old-space-size=2048"

COPY package.json package-lock.json* ./
RUN npm ci

# --- Stage 2: Build the app ---
FROM node:20-alpine AS builder
WORKDIR /app

ENV NODE_OPTIONS="--max-old-space-size=2048"
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# --- Stage 3: Production runner ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy only what's needed
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Create media directory with correct permissions
RUN mkdir -p /app/media && chown -R nextjs:nodejs /app/media

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
