# LlamaPress-Simple

This is the **base Docker image** for all LlamaPress/Leonardo projects. It contains the Rails framework skeleton, Gemfile, npm packages, and vendored gems.

## Architecture Overview

```
LlamaPress-Simple (this repo - Base Image)
       │
       │ builds → kody06/llamapress-simple:X.X.X
       │
       ▼
┌──────────────────────────────────────────┐
│  Client Projects (Overlays)              │
│  - Leonardo (development template)       │
│  - RSB-Tender                            │
│  - clients/History-Education-Foundation  │
│  - clients/opto                          │
└──────────────────────────────────────────┘
       │
       │ volume mounts override: app/, db/, config/, spec/
       ▼
   Client-specific code runs on top of base image
```

## What Lives Here vs Client Projects

| This Repo (Baked into Image) | Client Projects (Mounted) |
|------------------------------|---------------------------|
| Gemfile / Gemfile.lock | app/controllers, models, views |
| package.json / npm deps | config/routes.rb |
| vendor/ gems (llama_bot_rails, etc.) | db/migrations |
| Base Rails framework | spec/ tests |
| Dockerfile | docker-compose.yml |

## Vendored Gems as Submodules

`llama_bot_rails` is a **git submodule** at `vendor/llama_bot_rails`:

```bash
# Initialize after cloning
git submodule update --init --recursive

# The submodule repo
https://github.com/KodyKendall/llama_bot_rails.git
```

**Important:** The Dockerfile removes `.git` files from submodules during build because they point to paths outside the Docker build context.

## Building the Docker Image

**IMPORTANT:** Full builds take ~20 minutes. Always preserve the cache when possible.

```bash
# Local build (single platform) - uses cache
docker build -t kody06/llamapress-simple:0.3.1 .

# Multi-platform build and push - uses cache
docker buildx build --file Dockerfile \
  --platform linux/amd64,linux/arm64 \
  --tag kody06/llamapress-simple:0.3.1 --push .
```

### Rebuilding After Changes (from Leonardo directory)

When you change files in `vendor/` (like `llama_bot_rails`), Docker may reuse an existing image instead of rebuilding. To force a rebuild while **preserving cache**:

```bash
cd /path/to/Leonardo

# Step 1: Stop the container (required before removing image)
docker compose -f docker-compose-dev.yml down llamapress

# Step 2: Remove the old image (this preserves layer cache!)
docker rmi leonardo-llamapress

# Step 3: Rebuild and start (uses cached layers, ~2-3 seconds if no gem changes)
docker compose -f docker-compose-dev.yml up -d --build llamapress
```

**Note:** If you get "container is using its referenced image" error on `docker rmi`, make sure you ran `docker compose down` first (not just `docker compose stop`).

**AVOID these unless absolutely necessary:**
```bash
# BAD: --no-cache rebuilds everything from scratch (~20 min)
docker compose -f docker-compose-dev.yml build --no-cache llamapress
```

The layer cache is stored separately from the image, so removing the image (`docker rmi`) still preserves cached layers for `apt-get`, `bundle install`, and `npm install`. You'll see "CACHED" for most steps in the build output.

## How Client Projects Use This

**Option 1: Pre-built image (production/deployment)**
```yaml
# docker-compose.yml
services:
  llamapress:
    image: kody06/llamapress-simple:0.3.1
    volumes:
      - ./rails/app:/rails/app
      - ./rails/db:/rails/db
```

**Option 2: Local build (development)**
```yaml
# docker-compose-dev.yml
services:
  llamapress:
    build: ../LlamaPress-Simple
    volumes:
      - ./rails/app:/rails/app
      - ./rails/db:/rails/db
```

## Adding a New Gem

1. Edit `Gemfile` in this repo
2. Run `bundle lock` (or build the image to generate lock)
3. Build and push new image version
4. Update client `docker-compose.yml` to use new image tag

## Local Ruby Access

To access ruby locally (outside Docker):
```bash
source ~/.zshrc  # mise should activate
```

## Running Tests

All tests run through Docker:
```bash
docker compose exec llamapress bundle exec rspec
docker compose exec llamapress npm test
```

See `.claude/skills/test_execution.md` for detailed test documentation.

## Related Projects

- **Leonardo**: `/LLMPress/Leonardo` - Development template project
- **llama_bot_rails**: `vendor/llama_bot_rails` (submodule) - Rails engine for LlamaBot integration
- **LlamaBot**: `/LLMPress/LlamaBot` - Python LangGraph service
- **Clients**: `/LLMPress/clients/` - Production client projects

## Symlink for Cross-Project Development

A symlink exists at `/LLMPress/llama_bot_rails_symlink` pointing to `LlamaPress-Simple/vendor/llama_bot_rails` for legacy compatibility with other projects that reference the gem.
