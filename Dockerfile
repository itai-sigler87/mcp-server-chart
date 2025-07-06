# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install system dependencies for the 'canvas' package
RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev

WORKDIR /usr/src/app

COPY package*.json ./

# Install dependencies, but IGNORE scripts (like husky) that fail in a non-git environment
RUN npm install --ignore-scripts

COPY . .

# Now, manually run the build script that was skipped
RUN npm run build

# Remove development-only packages
RUN npm prune --production

# ---

# Stage 2: Create the final production image
FROM node:18-alpine

# Install only the runtime system dependencies
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
