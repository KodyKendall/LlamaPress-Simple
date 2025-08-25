# LlamaPress-Simple

**LlamaPress-Simple** is a minimal Rails 7.2 starter application designed to be the foundation for building Rails apps with **[LlamaBot](https://github.com/kodykendall/LlamaBot)**, the AI Coding Agent that builds and modifies Rails applications at your request.

Out of the box, it comes with:

* **User model** and authentication via [Devise](https://github.com/heartcombo/devise)
* **PostgreSQL** database support
* **TailwindCSS** styling
* **Turbo/Stimulus (Hotwire)** for modern interactivity
* **LlamaBot integration**: Includes the configuration required for LlamaBot to safely and effectively make changes to your app (e.g. iframe support, debug data sharing, etc.).

This repo is meant to be the simplest Rails app template you can use to start coding with an AI agent.

---

## 🚀 Quickstart with Docker

The fastest way to get started is by running the prebuilt Docker image:

```bash
# Pull the image from Docker Hub
docker pull kody06/llamapress-simple:0.1.17

# Run the container
docker run --rm -it -p 3000:3000 kody06/llamapress-simple:0.1.17
```

This will:

* Boot a fresh Rails 7.2 app with Devise, Tailwind, Hotwire, and LlamaBot integration.
* Expose it on [http://localhost:3000](http://localhost:3000).
* Automatically prepare the database on first run.

---

## 🛠️ Local Development (Manual Setup)

If you prefer to run from source instead of Docker:

### Prerequisites

* Ruby 3.3+
* PostgreSQL 13+
* Node.js & Yarn (optional, for asset building if you switch away from importmaps)

### Setup

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/llamapress-simple.git
cd llamapress-simple

# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate

# Start server
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000) to confirm the app is running.

---

## 🧑‍💻 Using with LlamaBot

Once LlamaPress-Simple is running (via Docker or locally), you can connect it with **LlamaBot** to begin agent-driven Rails development.

LlamaBot can:

* Generate models, controllers, and views
* Update routes
* Modify Tailwind-based UIs
* Debug and explain errors
* Extend the app with custom features

⚠️ **Security Note**: In development, LlamaBot has broad powers to modify your app. For production, you should whitelist allowed actions and routes using the `llama_bot_rails` gem configuration.

---

## 📦 Docker Build (for maintainers)

If you want to build and push the image yourself:

```bash
docker buildx build \
  --file Dockerfile \
  --platform linux/amd64,linux/arm64 \
  --tag kody06/llamapress-simple:0.1.17 \
  --push .
```

---

## 📋 Roadmap

* [ ] Example LlamaBot workflow included (generate a scaffold, modify a page)
* [ ] Demo video of LlamaBot + LlamaPress-Simple in action
* [ ] Additional deployment templates (Fly.io, Render, etc.)

---

## 📜 License

LlamaPress-Simple is released under the [MIT License](LICENSE).
