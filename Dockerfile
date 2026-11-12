FROM node:22-alpine

# Create non-root user for security best practices
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create work dir
WORKDIR /usr/src/app

# Copy dependency manifests first
COPY package*.json ./

# Install production dependencies only
RUN npm install --omit=dev

# Copy application source
COPY app.js ./

# Switch to non-root user
USER appuser

# Set default listening port (overridable at runtime via -e PORT or K8s env/ConfigMap)
ENV PORT=8080
EXPOSE 8080

CMD ["node", "app.js"]