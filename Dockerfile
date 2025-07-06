# Stage 1: Build the application
FROM node:18-alpine AS builder

# The 'canvas' package requires system dependencies for drawing
RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev

WORKDIR /usr/src/app

COPY package*.json ./

# Install all dependencies to run the build script
RUN npm install

COPY . .

# Build the TypeScript code into JavaScript
RUN npm run build

# Remove development-only packages for a smaller final image
RUN npm prune --production

# ---

# Stage 2: Create the final, lean production image
FROM node:18-alpine

# Install only the runtime system dependencies needed for canvas
RUN apk add --no-cache cairo jpeg pango giflib

WORKDIR /usr/src/app

# Copy the essential parts from the 'builder' stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package.json ./package.json

# Expose the port the app runs on
EXPOSE 3000

# The command to run the final application
CMD [ "node", "dist/index.js" ]
