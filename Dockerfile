# Stage 1: Install dependencies
FROM node:22-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --omit=dev

# Stage 2: minimal and clean base. Distroless runtime (no npm, no shell, minimal CVE surface)
FROM gcr.io/distroless/nodejs22-debian12
WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY app.js ./

# Distroless provides a built-in 'nonroot' user
USER nonroot

ENV PORT=8080
EXPOSE 8080

# Note: Distroless sets ENTRYPOINT to ["/nodejs/bin/node"], so CMD takes only the script path
CMD ["app.js"]