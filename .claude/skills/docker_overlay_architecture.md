# Docker Base/Overlay Architecture

## Overview

LlamaPress uses a **Docker base image + overlay** architecture that enables:
- **Shared infrastructure** across multiple client projects
- **Hot-reloading** for client-specific code during development
- **Consistent dependencies** (gems, npm packages) across all deployments
- **Easy updates** by pushing new base image versions

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Base Image                         │
│              kody06/llamapress-simple:X.X.X                 │
│                                                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │
│  │  Gemfile    │ │ package.json│ │  Base Rails App     │    │
│  │  (gems)     │ │ (npm deps)  │ │  (views, helpers)   │    │
│  └─────────────┘ └─────────────┘ └─────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ docker compose volumes
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Client Overlay (RSB-Tender)                 │
│                                                              │
│  Mounted directories override base image paths:             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  ./rails/   │ │  ./rails/   │ │  ./rails/   │           │
│  │    app/     │ │    db/      │ │   spec/     │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

### Base Image: LlamaPress-Simple

Location: `/Users/kodykendall/SoftEngineering/LLMPress/LlamaPress-Simple`

This is the **standardized Rails template** that all client projects inherit from.

**Contains:**
- `Gemfile` / `Gemfile.lock` - All Ruby gem dependencies
- `package.json` - All npm/JavaScript dependencies
- `vendor/` - Vendored gems (e.g., RailsPlanetarium)
- Base Rails application code (layouts, helpers, initializers)
- Docker configuration (`Dockerfile`)
- Testing infrastructure (RSpec, Vitest setup)

**Key Files:**
| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the base image with all dependencies |
| `Gemfile` | Ruby dependencies (roo, devise, etc.) |
| `package.json` | JavaScript dependencies (Stimulus, Vitest) |
| `docker-compose.yml` | Local development setup |

### Client Overlay Projects

Location: `/Users/kodykendall/SoftEngineering/LLMPress/clients/<project-name>`

Each client project contains **only project-specific code** that overlays onto the base image.

**Example Clients:**
- `RSB-Tender` - Bill of Quantities (BOQ) parsing application
- `History-Education-Foundation` - Historical education platform
- `opto` - Optimization platform

**Typical Client Structure:**
```
clients/RSB-Tender/
├── docker-compose.yml      # Uses base image + mounts overlays
├── .env                    # Client-specific secrets
├── rails/
│   ├── app/               # Controllers, models, views, services
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── services/      # e.g., SpreadsheetParser
│   │   └── views/
│   ├── config/
│   │   ├── routes.rb      # Client-specific routes
│   │   ├── database.yml   # Client database config
│   │   └── environments/
│   ├── db/                # Migrations, seeds
│   └── spec/              # Client-specific tests
└── langgraph/             # LangGraph agent configurations
```

---

## How the Overlay Works

### Volume Mounts in docker-compose.yml

Client projects mount specific directories that **override** the base image paths:

```yaml
# From RSB-Tender/docker-compose.yml
services:
  llamapress:
    image: kody06/llamapress-simple:0.2.7    # Base image
    volumes:
      # These paths OVERRIDE what's in the base image
      - ./rails/app:/rails/app:delegated           # Client controllers, models, views
      - ./rails/db:/rails/db:delegated             # Client migrations
      - ./rails/spec:/rails/spec:delegated         # Client tests
      - ./rails/config/routes.rb:/rails/config/routes.rb:delegated
      - ./rails/config/database.yml:/rails/config/database.yml
```

### What Gets Overlaid vs. Inherited

| Category | Source | Notes |
|----------|--------|-------|
| **Ruby Gems** | Base Image | `bundle install` runs during image build |
| **NPM Packages** | Base Image | `npm install` runs during image build |
| **Controllers** | Client Overlay | `./rails/app/controllers/` |
| **Models** | Client Overlay | `./rails/app/models/` |
| **Views** | Client Overlay | `./rails/app/views/` |
| **Services** | Client Overlay | `./rails/app/services/` |
| **Routes** | Client Overlay | `./rails/config/routes.rb` |
| **Database Schema** | Client Overlay | `./rails/db/` |
| **Tests** | Client Overlay | `./rails/spec/` |
| **Base Layouts** | Base Image | Unless overridden in client |
| **Helpers** | Base Image | Unless overridden in client |
| **Initializers** | Base Image | Unless overridden in client |

---

## Adding Dependencies

### Adding a Ruby Gem

**IMPORTANT:** Gems must be added to the **base image**, not the client project.

1. Edit `LlamaPress-Simple/Gemfile`:
   ```ruby
   gem "roo", "~> 2.10"
   ```

2. Rebuild and push the base image:
   ```bash
   cd /Users/kodykendall/SoftEngineering/LLMPress/LlamaPress-Simple
   docker buildx build --file Dockerfile \
     --platform linux/amd64,linux/arm64 \
     --tag kody06/llamapress-simple:0.2.8 --push .
   ```

3. Update client `docker-compose.yml` to use new image version:
   ```yaml
   image: kody06/llamapress-simple:0.2.8
   ```

4. Restart client containers:
   ```bash
   cd /Users/kodykendall/SoftEngineering/LLMPress/clients/RSB-Tender
   docker compose down && docker compose up -d
   ```

### Adding an NPM Package

Same process as gems - add to base image's `package.json`, rebuild, and push.

---

## Creating a New Client Project

1. Create the client directory structure:
   ```bash
   mkdir -p clients/NewProject/rails/{app,config,db,spec}
   mkdir -p clients/NewProject/rails/app/{controllers,models,views,services}
   ```

2. Create `docker-compose.yml`:
   ```yaml
   services:
     llamapress:
       image: kody06/llamapress-simple:0.2.8
       env_file: .env
       volumes:
         - ./rails/app:/rails/app:delegated
         - ./rails/config/routes.rb:/rails/config/routes.rb:delegated
         - ./rails/db:/rails/db:delegated
         - ./rails/spec:/rails/spec:delegated
       ports:
         - "3000:3000"
       depends_on:
         - db
         - redis
       networks:
         - llama-network

     db:
       image: postgres:16
       environment:
         POSTGRES_DB: newproject_development
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
       volumes:
         - postgres_data:/var/lib/postgresql/data
       networks:
         - llama-network

     redis:
       image: redis:7-alpine
       networks:
         - llama-network

   volumes:
     postgres_data:

   networks:
     llama-network:
       name: llama-network
   ```

3. Create client-specific routes file (`rails/config/routes.rb`)

4. Add models, controllers, views as needed

---

## Running Commands in Client Projects

All Rails/bundle/npm commands must be run through Docker:

```bash
# Change to client directory
cd /Users/kodykendall/SoftEngineering/LLMPress/clients/RSB-Tender

# Run RSpec tests
docker compose exec llamapress bundle exec rspec

# Run specific test file
docker compose exec llamapress bundle exec rspec spec/services/spreadsheet_parser_spec.rb

# Rails console
docker compose exec llamapress bin/rails console

# Database migrations
docker compose exec llamapress bin/rails db:migrate

# View logs
docker compose logs -f llamapress
```

---

## Versioning Strategy

### Base Image Versioning

Use semantic versioning for the base image:
- **Major (X.0.0):** Breaking changes to base Rails app structure
- **Minor (0.X.0):** New gems, npm packages, or base features
- **Patch (0.0.X):** Bug fixes, dependency updates

Example: `kody06/llamapress-simple:0.2.8`

### Client Version Independence

Client projects track their own versions independently. Update the base image reference in `docker-compose.yml` when needed.

---

## Troubleshooting

### "Gem not found" errors

The gem is missing from the base image. Add it to `LlamaPress-Simple/Gemfile`, rebuild, and push.

### Changes not appearing

1. Check you're in the correct client directory
2. Verify the file is within a mounted volume path
3. Restart the container: `docker compose restart llamapress`

### Database schema mismatch

Run migrations in the container:
```bash
docker compose exec llamapress bin/rails db:migrate
```

### Base image not pulling latest

Force pull the latest image:
```bash
docker compose pull llamapress
docker compose up -d
```

---

## File Locations Reference

| What | Base Image | Client Overlay |
|------|-----------|----------------|
| Gemfile | `LlamaPress-Simple/Gemfile` | N/A (use base) |
| package.json | `LlamaPress-Simple/package.json` | N/A (use base) |
| Controllers | `LlamaPress-Simple/app/controllers/` | `clients/X/rails/app/controllers/` |
| Models | `LlamaPress-Simple/app/models/` | `clients/X/rails/app/models/` |
| Services | `LlamaPress-Simple/app/services/` | `clients/X/rails/app/services/` |
| Views | `LlamaPress-Simple/app/views/` | `clients/X/rails/app/views/` |
| Routes | `LlamaPress-Simple/config/routes.rb` | `clients/X/rails/config/routes.rb` |
| Migrations | `LlamaPress-Simple/db/migrate/` | `clients/X/rails/db/migrate/` |
| Tests | `LlamaPress-Simple/spec/` | `clients/X/rails/spec/` |
| Docker config | `LlamaPress-Simple/Dockerfile` | `clients/X/docker-compose.yml` |

---

## Quick Reference

| Task | Command/Location |
|------|------------------|
| Build base image | `cd LlamaPress-Simple && docker buildx build ...` |
| Add Ruby gem | Edit `LlamaPress-Simple/Gemfile`, rebuild image |
| Add npm package | Edit `LlamaPress-Simple/package.json`, rebuild image |
| Run client tests | `cd clients/X && docker compose exec llamapress bundle exec rspec` |
| Update base image | Change `image:` in client's `docker-compose.yml` |
| View container logs | `docker compose logs -f llamapress` |
| Rails console | `docker compose exec llamapress bin/rails console` |
| Check running services | `docker compose ps` |
