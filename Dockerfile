# syntax=docker/dockerfile:1.4
# ARG TARGETPLATFORM=linux/amd64
FROM --platform=${TARGETPLATFORM} ruby@sha256:bceec7582aaa80630bb51a04e2df3af658e64c0640c174371776928ad3bd57b4

# freeze snapshot
RUN rm -f /etc/apt/sources.list /etc/apt/sources.list.d/* \
 && echo "deb [trusted=yes] https://snapshot.debian.org/archive/debian/20240701T000000Z bookworm main contrib non-free" \
    > /etc/apt/sources.list

# anti-cache hack for Mac apple silicon
RUN printf 'Acquire::http::Pipeline-Depth "0";\nAcquire::http::No-Cache "true";\nAcquire::BrokenProxy "true";\n' \
    > /etc/apt/apt.conf.d/99fixbadproxy

# clean slate
RUN rm -rf /var/lib/apt/lists/* \
 && apt-get clean \
 && apt-get update -o Acquire::CompressionTypes::Order::=gz

# build dependencies with cache mounts
RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt \
    --mount=type=cache,id=apt-lists,target=/var/lib/apt/lists \
    apt-get update -qq && \
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
      xdg-utils \
      --fix-missing && \
    apt-get clean

# Configure npm
RUN npm config set fund false --global

WORKDIR /rails

# Set ENV for bundler
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BOOTSNAP_CACHE_DIR="/rails/tmp/cache/bootsnap"

# Copy Gemfiles and vendor gems for better caching
COPY Gemfile Gemfile.lock ./
COPY vendor/ vendor/

# Install gems directly into the image
RUN bundle install && \
    bundle clean --force

# Copy package files for Node.js dependencies
COPY package.json package*.json ./
RUN npm ci 2>/dev/null || npm install

# Create directories that might be needed
RUN mkdir -p tmp/cache/bootsnap tmp/pids log

# Copy application code (this should be LAST to maximize cache hits)
COPY . .

# Expose port 3000
EXPOSE 3000

# Prepare database and start the Rails server
CMD ["sh", "-c", "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"]

#   docker buildx build --file Dockerfile --platform linux/amd64,linux/arm64 --tag kody06/llamapress-simple:0.2.4 --push .
# 
