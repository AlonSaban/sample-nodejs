FROM node:22-alpine

WORKDIR /usr/src/app

# Copy dependency manifests first for Docker layer caching
COPY package*.json ./

# 1. Patch Alpine OS packages (fixes OpenSSL/libssl3 CVEs)
# 2. Install production dependencies only
# 3. Strip npm/yarn/corepack from runtime image (fixes bundled npm CLI CVEs)
RUN apk update && apk upgrade --no-cache && \
    npm install --omit=dev && \
    rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/bin/corepack \
           /opt/yarn*

# Copy application source
COPY app.js ./

# Built-in 'node' user in node:22-alpine is UID 1000 (matches K8s runAsUser: 1000)
USER node

ENV PORT=8080
EXPOSE 8080

CMD ["node", "app.js"]