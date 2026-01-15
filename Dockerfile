# syntax=docker/dockerfile:1.4
ARG TARGETPLATFORM

# Use standard ruby image
# When building locally: builds for native arch
# When pushing with buildx --platform: builds for specified platforms
FROM ruby:3.3-bookworm

# Use standard Debian repos (MUCH faster than snapshot.debian.org)
# This is the biggest speed improvement - snapshot repos are extremely slow
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      pkg-config \
      curl \
      postgresql-client \
      nodejs \
      watchman \
      npm \
      chromium \
      chromium-driver \
      libgbm1 \
      libasound2 \
      libatk-bridge2.0-0 \
      libatk1.0-0 \
      libatspi2.0-0 \
      libcups2 \
      libdbus-1-3 \
      libdrm2 \
      libglib2.0-0 \
      libnspr4 \
      libnss3 \
      libwayland-client0 \
      libx11-6 \
      libxcb1 \
      libxcomposite1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxkbcommon0 \
      libxrandr2 \
      xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure npm
RUN npm config set fund false --global

# Tell Puppeteer to use system Chromium instead of downloading its own
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /rails

# Set ENV for bundler
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BOOTSNAP_CACHE_DIR="/rails/tmp/cache/bootsnap"

# Copy Gemfiles and vendor gems for better caching
COPY Gemfile Gemfile.lock ./
COPY vendor/ vendor/

# Install gems with cache mount (speeds up rebuilds significantly)
RUN --mount=type=cache,id=bundler,target=/usr/local/bundle/cache \
    bundle install && \
    bundle clean --force

# Copy package files for Node.js dependencies
COPY package.json package*.json ./

# Install npm packages with cache mount
RUN --mount=type=cache,id=npm,target=/root/.npm \
    npm ci 2>/dev/null || npm install

# Create directories that might be needed
RUN mkdir -p tmp/cache/bootsnap tmp/pids log

# Copy application code (this should be LAST to maximize cache hits)
COPY . .

# Expose port 3000
EXPOSE 3000

# Prepare database and start the Rails server
CMD ["sh", "-c", "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"]

#   docker buildx build --file Dockerfile --platform linux/amd64,linux/arm64 --tag kody06/llamapress-simple:0.2.7 --push .
# 

