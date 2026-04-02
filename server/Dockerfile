FROM node:18-alpine

WORKDIR /app

# Copy package files first for layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy source
COPY . .

# Create uploads directory
RUN mkdir -p src/uploads

EXPOSE 3000

CMD ["node", "server.js"]
