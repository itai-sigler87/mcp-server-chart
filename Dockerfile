# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install system dependencies for the 'canvas' package
RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev

WORKDIR /usr/src/app

COPY package*.json ./

# Install dependencies, ignoring scripts like husky
RUN npm install --ignore-scripts

COPY . .

# Manually run the build script
RUN npm run build

# Remove development-only packages
RUN npm prune --production

# ---

# Stage 2: Create the final, lean production image
FROM node:18-alpine

# Install only the runtime system dependencies
RUN apk add --no-cache cairo jpeg pango giflib

WORKDIR /usr/src/app

# Copy the essential parts from the 'builder' stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/build ./build
COPY --from=builder /usr/src/app/package.json ./package.json

# Expose the port the app runs on
EXPOSE 3000

# The command to run the final application from the 'build' folder
CMD [ "node", "build/index.js" ]
