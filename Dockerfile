# ---------- Base Stage ----------
FROM node:22-alpine AS base

# Set working directory
WORKDIR /app

# Install build tools for native deps (if any)
RUN apk add --no-cache python3 make g++ git

# Pre-cache dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Build static site
RUN yarn build


# ---------- Production Stage ----------
FROM nginx:alpine AS prod

# Remove default nginx HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy built Docusaurus site
COPY --from=base /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
