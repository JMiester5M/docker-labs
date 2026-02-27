# Multi-stage Dockerfile for Next.js

# -----------------------------
# Builder stage
# -----------------------------
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the source code and build the app
COPY . .

# Generate Prisma Client based on prisma/schema.prisma
RUN npx prisma generate

RUN npm run build

# -----------------------------
# Production stage
# -----------------------------
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

# Copy only the standalone build artifacts and static assets
# Assumes Next.js is configured with `output: 'standalone'` so that
# `.next/standalone/server.js` exists.
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/server ./.next/server
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

# Expose the application port
EXPOSE 3000

# Run the standalone server
CMD ["node", "server.js"]
