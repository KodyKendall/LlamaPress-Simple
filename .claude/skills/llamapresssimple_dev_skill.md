# LlamaPress Simple Development Guide

## Project Architecture

This uses Dockerfile and docker-compose.yml to run. To deploy, we use a docker image build and push.

This is the overlay repo and a standardized template for many Ruby on Rails projects, where they use this base image, and then overlay their own app, tests, config, and db folder over this repo. So this is an extremely important repo for downstream users.

**IMPORTANT: All commands MUST be run through Docker containers. We never run Rails on bare metal.**

---

## Testing Framework Overview

This project uses a **dual testing approach** for comprehensive coverage without requiring browser automation:

### 1. **RSpec** - Backend & Request Testing
- Tests Rails controllers, models, and request specs
- System tests are **excluded by default** (no Chromium/Playwright needed)
- Uses DatabaseCleaner with truncation strategy
- Configured in: `spec/rails_helper.rb`, `.rspec`

### 2. **Vitest** - JavaScript & Stimulus Testing
- Tests Stimulus controllers and JavaScript behavior
- Uses happy-dom for fast DOM simulation (no browser needed)
- Can optionally test against live Rails server for E2E scenarios
- Configured in: `vitest.config.js`, `test/setup.js`

---

## Running Tests

### RSpec Tests (Backend/Request Tests)

Run all RSpec tests (excludes system tests by default):
```bash
docker compose exec llamapress bundle exec rspec
```

Run specific test file:
```bash
docker compose exec llamapress bundle exec rspec spec/requests/users_spec.rb
```

Run specific test by line number:
```bash
docker compose exec llamapress bundle exec rspec spec/requests/users_spec.rb:22
```

Run with verbose output:
```bash
docker compose exec llamapress bundle exec rspec --format documentation
```

**Note:** System tests are excluded by default via `.rspec` configuration. To run them explicitly (requires Chromium setup):
```bash
docker compose exec llamapress bundle exec rspec spec/system
```

### Vitest Tests (JavaScript/Stimulus Tests)

Run all JavaScript tests (single run, CI mode):
```bash
docker compose exec llamapress npm test
```

Run tests in watch mode (re-runs on file changes):
```bash
docker compose exec llamapress npm run test:watch
```

Run tests with coverage report:
```bash
docker compose exec llamapress npm run test:coverage
```

Run tests with interactive UI:
```bash
docker compose exec llamapress npm run test:ui
```

---

## Test File Locations

All tests are located in the `spec/` directory:

### RSpec Tests (Backend)
- **Request specs:** `spec/requests/` - Test HTTP requests/responses
- **Model specs:** `spec/models/` - Test ActiveRecord models
- **System specs:** `spec/system/` - Browser-based E2E (excluded by default)
- **Helpers:** `spec/rails_helper.rb`, `spec/spec_helper.rb`

### Vitest Tests (JavaScript)
- **Stimulus controller tests:** `spec/javascript/controllers/*.test.js`
- **Test helpers:** `spec/javascript/helpers/` - Utilities like `rails_server.js` for E2E
- **Setup:** `spec/javascript/setup.js` - Global test configuration

---

## Writing Tests

### Writing RSpec Tests

Example request spec:
```ruby
require 'rails_helper'

RSpec.describe "/users", type: :request do
  let(:user) { create(:user) }

  describe "GET /show" do
    it "renders a successful response" do
      get user_url(user)
      expect(response).to be_successful
    end
  end
end
```

### Writing Vitest Tests

Example Stimulus controller test:
```javascript
import { describe, it, expect } from 'vitest'
import { Controller } from '@hotwired/stimulus'

describe('MyController', () => {
  it('should connect and initialize', async () => {
    class MyController extends Controller {
      connect() {
        this.element.textContent = 'Connected!'
      }
    }

    registerController('my', MyController)
    document.body.innerHTML = '<div data-controller="my"></div>'

    // Wait for Stimulus to connect
    await new Promise(resolve => setTimeout(resolve, 0))

    const element = document.querySelector('[data-controller="my"]')
    expect(element.textContent).toBe('Connected!')
  })
})
```

### E2E Testing with Rails Server

For testing Stimulus controllers against real Rails HTML:
```javascript
import { fetchAndLoadHTML } from '../../javascript/helpers/rails_server.js'

it('should load and test against real Rails HTML', async () => {
  // Fetch HTML from running Rails server
  const container = await fetchAndLoadHTML('/users')

  // Test your Stimulus controllers as they work in production
  const elements = container.querySelectorAll('[data-controller]')
  expect(elements.length).toBeGreaterThan(0)

  container.remove() // Cleanup
})
```

---

## Test Helpers & Utilities

### RSpec Helpers
- `create(:user)` - FactoryBot for creating test data
- `sign_in user` - Devise test helper for authentication
- DatabaseCleaner handles transaction cleanup automatically

### Vitest Helpers (Global)
- `registerController(name, controllerClass)` - Register Stimulus controller
- `loadStimulus()` - Force Stimulus to scan for controllers
- `global.stimulusApp` - Access to Stimulus Application instance

### Rails Server Helpers (for E2E)
Located in `spec/javascript/helpers/rails_server.js`:
- `fetchAndLoadHTML(path)` - Fetch and load Rails HTML into DOM
- `fetchJSON(path)` - Make JSON API requests to Rails
- `submitForm(formElement)` - Submit forms to Rails
- `waitForServer()` - Wait for Rails server to be ready

---

## Running Rails Commands

All Rails commands must be run through Docker:

```bash
# Rails console
docker compose exec llamapress bin/rails console

# Database migrations
docker compose exec llamapress bin/rails db:migrate

# Database reset
docker compose exec llamapress bin/rails db:reset

# Generate scaffold
docker compose exec llamapress bin/rails generate scaffold Post title:string

# Routes
docker compose exec llamapress bin/rails routes
```

---

## Test Configuration Files

- `.rspec` - RSpec configuration, excludes system tests
- `spec/rails_helper.rb` - RSpec Rails setup, Capybara/Cuprite config
- `spec/spec_helper.rb` - RSpec core configuration
- `vitest.config.js` - Vitest configuration and coverage settings
- `spec/javascript/setup.js` - Global Vitest setup and helpers

---

## Coverage Reports

### RSpec Coverage
Generated automatically in `coverage/` directory after running tests.
View: `coverage/index.html`

### Vitest Coverage
Generate with:
```bash
docker compose exec llamapress npm run test:coverage
```
View: `coverage/index.html`

---

## Troubleshooting

### RSpec Tests Failing
1. Ensure database is migrated: `docker compose exec llamapress bin/rails db:test:prepare`
2. Check FactoryBot factories in `spec/factories/`
3. Review `spec/rails_helper.rb` for configuration issues

### Vitest Tests Failing
1. Ensure npm packages are installed: `docker compose exec llamapress npm install`
2. Check Stimulus controller syntax and imports
3. Verify controllers are properly registered before testing
4. Wait for Stimulus connection: `await new Promise(resolve => setTimeout(resolve, 0))`

### System Tests (if enabled)
System tests require Chromium and proper browser path configuration in `spec/rails_helper.rb`. These are excluded by default to avoid Docker/Chromium complications.

---

## Quick Reference

| Task | Command |
|------|---------|
| Run all RSpec tests | `docker compose exec llamapress bundle exec rspec` |
| Run all JS tests | `docker compose exec llamapress npm test` |
| Watch mode (Vitest) | `docker compose exec llamapress npm run test:watch` |
| Coverage (RSpec) | Automatic, see `coverage/index.html` |
| Coverage (Vitest) | `docker compose exec llamapress npm run test:coverage` |
| Rails console | `docker compose exec llamapress bin/rails console` |
| Database migrate | `docker compose exec llamapress bin/rails db:migrate` |
| Start server | `docker compose up` |
| View logs | `docker compose logs -f llamapress` |