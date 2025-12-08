# Test Execution Guide for AI Agents

## Overview

This project uses a **dual testing framework** running entirely within Docker containers:
- **RSpec** for Rails backend/request tests
- **Vitest** for JavaScript/Stimulus frontend tests

**CRITICAL:** All test commands MUST be executed through `docker compose exec llamapress`. Never run tests on bare metal.

---

## Test Execution Commands

### Primary Test Commands

#### Run All RSpec Tests
```bash
docker compose exec llamapress bundle exec rspec
```
**What it does:** Runs all RSpec tests (models, requests, etc.) excluding system tests.
**When to use:** After making backend changes, before committing code.

#### Run All Vitest Tests
```bash
docker compose exec llamapress npm test
```
**What it does:** Runs all JavaScript/Stimulus tests in CI mode (single run).
**When to use:** After making frontend JavaScript changes, before committing code.

---

## Detailed Test Execution Options

### RSpec (Backend Tests)

#### Run specific test file
```bash
docker compose exec llamapress bundle exec rspec spec/requests/users_spec.rb
```

#### Run specific test by line number
```bash
docker compose exec llamapress bundle exec rspec spec/requests/users_spec.rb:22
```

#### Run with verbose documentation format
```bash
docker compose exec llamapress bundle exec rspec --format documentation
```

#### Run only failing tests
```bash
docker compose exec llamapress bundle exec rspec --only-failures
```

#### Run tests matching a pattern
```bash
docker compose exec llamapress bundle exec rspec --example "creates a user"
```

#### Run system tests (browser-based, excluded by default)
```bash
docker compose exec llamapress bundle exec rspec spec/system
```
**Note:** Requires Chromium configuration. Not recommended in Docker environment.

---

### Vitest (JavaScript Tests)

#### Run tests in watch mode (re-run on file changes)
```bash
docker compose exec llamapress npm run test:watch
```
**When to use:** During active development for immediate feedback.

#### Run with coverage report
```bash
docker compose exec llamapress npm run test:coverage
```
**What it generates:** Coverage report in `coverage/index.html`

#### Run with interactive UI
```bash
docker compose exec llamapress npm run test:ui
```
**What it does:** Opens visual test runner interface.

#### Run specific test file
```bash
docker compose exec llamapress npm test -- test/controllers/example_controller.test.js
```

#### Run tests matching a pattern
```bash
docker compose exec llamapress npm test -- --grep "should mount"
```

---

## Test Workflow for AI Agents

### When Writing New Features
1. Write test first (TDD approach)
2. Run specific test file to verify it fails
3. Implement feature
4. Run test again to verify it passes
5. Run full test suite before committing

### After Making Backend Changes
```bash
# Run affected tests first
docker compose exec llamapress bundle exec rspec spec/requests/users_spec.rb

# If passing, run full suite
docker compose exec llamapress bundle exec rspec
```

### After Making Frontend Changes
```bash
# Run JavaScript tests
docker compose exec llamapress npm test

# Optionally check coverage
docker compose exec llamapress npm run test:coverage
```

### Before Committing Code
Run BOTH test suites to ensure nothing broke:
```bash
# Run RSpec tests
docker compose exec llamapress bundle exec rspec

# Run Vitest tests
docker compose exec llamapress npm test
```

---

## Test Structure

### Test Locations (All in `spec/`)

#### RSpec Tests
- `spec/requests/` - Request specs (API/controller tests)
- `spec/models/` - Model specs (ActiveRecord tests)
- `spec/system/` - System specs (browser E2E, excluded by default)
- `spec/factories/` - FactoryBot test data factories

#### Vitest Tests
- `spec/javascript/controllers/` - Stimulus controller tests
- `spec/javascript/helpers/` - Test utilities (e.g., `rails_server.js`)
- `spec/javascript/setup.js` - Global test configuration

---

## Understanding Test Output

### RSpec Output
```
Users
  DELETE /destroy
    destroys the requested user ✓
    redirects to the users list ✓

Finished in 4.8 seconds
8 examples, 0 failures
```

- **Green dots (✓):** Tests passed
- **Red F:** Test failed
- **Yellow *:** Pending test

### Vitest Output
```
✓ test/controllers/example_controller.test.js (3 tests)
  ✓ should mount and connect a controller
  ✓ should handle controller targets
  ✓ should handle controller values

Test Files  1 passed (1)
Tests  3 passed (3)
```

- **✓:** Test passed
- **✗:** Test failed
- **⊗:** Test errored

---

## Common Test Failures & Solutions

### RSpec Failures

#### Database not migrated
**Error:** `PG::UndefinedTable: ERROR: relation "users" does not exist`
**Solution:**
```bash
docker compose exec llamapress bin/rails db:test:prepare
```

#### Factory not found
**Error:** `FactoryBot::UnregisteredFactoryError`
**Solution:** Check `spec/factories/` for factory definition.

#### Devise authentication required
**Error:** `redirect to login`
**Solution:** Add `sign_in user` in test setup.

### Vitest Failures

#### Module not found
**Error:** `Cannot find module '@hotwired/stimulus'`
**Solution:**
```bash
docker compose exec llamapress npm install
```

#### Stimulus controller not connecting
**Error:** `expected 'Connected!' but got ''`
**Solution:** Add `await new Promise(resolve => setTimeout(resolve, 0))` after setting HTML.

#### Global function not defined
**Error:** `registerController is not defined`
**Solution:** Ensure test imports from 'vitest' and global helpers are loaded via `spec/javascript/setup.js`.

---

## Test Configuration Files

- `.rspec` - RSpec CLI options, excludes system tests
- `spec/rails_helper.rb` - RSpec Rails integration setup
- `spec/spec_helper.rb` - Core RSpec configuration
- `vitest.config.js` - Vitest test runner configuration
- `spec/javascript/setup.js` - Global Vitest setup (Stimulus initialization)
- `package.json` - NPM test scripts

---

## Coverage Reports

### RSpec Coverage
**Location:** `coverage/index.html`
**Generated:** Automatically after running RSpec tests
**View:** Open in browser or read `coverage/index.html`

### Vitest Coverage
**Location:** `coverage/index.html`
**Generated:** Run `npm run test:coverage`
**View:** Open in browser

---

## Docker Container Context

All tests run inside the `llamapress` Docker container:
- **Container name:** `llamapress-simple-llamapress-1`
- **Database:** Separate `db` container (PostgreSQL)
- **Redis:** Separate `redis` container (for caching/jobs)

**Networking:** Containers communicate via Docker network `llama-network`.

**Data persistence:** Database data persisted in Docker volumes.

---

## Test Environment Variables

Tests run in `RAILS_ENV=test` by default.

Override test host for E2E tests:
```bash
docker compose exec -e RAILS_TEST_HOST=http://localhost:3000 llamapress npm test
```

---

## Quick Command Reference

| Action | Command |
|--------|---------|
| Run all backend tests | `docker compose exec llamapress bundle exec rspec` |
| Run all frontend tests | `docker compose exec llamapress npm test` |
| Watch frontend tests | `docker compose exec llamapress npm run test:watch` |
| Backend coverage | Auto-generated in `coverage/` |
| Frontend coverage | `docker compose exec llamapress npm run test:coverage` |
| Specific RSpec file | `docker compose exec llamapress bundle exec rspec spec/path/file_spec.rb` |
| Specific Vitest file | `docker compose exec llamapress npm test -- spec/javascript/path/file.test.js` |
| Database prepare | `docker compose exec llamapress bin/rails db:test:prepare` |
| Install JS deps | `docker compose exec llamapress npm install` |

---

## CI/CD Integration

For continuous integration pipelines:

```bash
# Ensure containers are running
docker compose up -d

# Wait for services to be ready
docker compose exec llamapress bin/rails db:test:prepare

# Run both test suites
docker compose exec llamapress bundle exec rspec
docker compose exec llamapress npm test

# Check exit codes and fail if tests fail
```

---

## Best Practices for AI Agents

1. **Always run tests through Docker** - Never execute bare `rspec` or `npm test`
2. **Run specific tests first** - Target the file/spec you're working on
3. **Run full suite before finalizing** - Ensure no regressions
4. **Check coverage** - Aim for high test coverage on new code
5. **Fix failing tests immediately** - Don't commit with failing tests
6. **Use watch mode during development** - Get instant feedback
7. **Read error messages carefully** - They contain solutions
8. **Ensure DB is migrated** - Run `db:test:prepare` if seeing schema errors

---

## Debugging Tests

### Enable verbose output (RSpec)
```bash
docker compose exec llamapress bundle exec rspec --format documentation --backtrace
```

### Debug with pry (RSpec)
Add `binding.pry` in test code, then run:
```bash
docker compose exec -it llamapress bundle exec rspec spec/path/file_spec.rb
```

### Debug with console.log (Vitest)
Vitest outputs console.log statements. Use liberally in tests.

### Run single test in isolation
```bash
# RSpec
docker compose exec llamapress bundle exec rspec spec/path/file_spec.rb:42

# Vitest
docker compose exec llamapress npm test -- spec/javascript/path/file.test.js --grep "specific test name"
```
