FROM node:20-alpine AS builder
RUN npm install -g pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile
COPY . .
ARG POSTGRES_URL
ARG POSTGRES_PRISMA_URL
ARG POSTGRES_URL_NON_POOLING

ENV POSTGRES_URL=$POSTGRES_URL
ENV POSTGRES_PRISMA_URL=$POSTGRES_PRISMA_URL
ENV POSTGRES_URL_NON_POOLING=$POSTGRES_URL_NON_POOLING

RUN pnpm build

FROM node:20-alpine AS runner


WORKDIR /app

RUN addgroup --system nodejs && \
    adduser --system nextjs -G nodejs

ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

CMD ["/usr/local/bin/node", "server.js"]
