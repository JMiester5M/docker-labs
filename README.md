# BrightPath Tutoring – Docker Labs App

## Project Overview

> Placeholder: Add your detailed product description here (target users, learning goals, and how Docker labs fit into the BrightPath Tutoring experience).

---

## Quick Start

The app is fully containerized. Once you have Docker installed and running, you can build and start the app with these commands from the project root:

```bash
# 1. Build the Docker image
docker build -t brightpath-app .

# 2. Run the container on port 3000
docker run --rm -p 3000:3000 brightpath-app
```

Then open your browser at:

- http://localhost:3000

These are copy-paste friendly commands suitable for students on Windows, macOS, or Linux (as long as Docker Desktop or a compatible Docker engine is installed).

---

### Using Docker Compose (App + Database)

The Quick Start commands run only the application container. To start the full stack (app + PostgreSQL database) defined in `docker-compose.yml`, use:

```bash
docker compose up --build
```

Once both services are up, apply any pending Prisma migrations from inside the running app container:

```bash
docker compose exec app npx prisma migrate deploy
```

- `docker build` / `docker run` (Quick Start) → build and run a single image (`brightpath-app`) by itself.
- `docker compose up --build` → build and start all services together (your `app` container and the `db` Postgres container) using shared configuration from `docker-compose.yml` and `.env`, then `docker compose exec app npx prisma migrate deploy` keeps the database schema up to date.

Then open your browser at:

- http://localhost:3000

---

## Architecture

### High-Level Design

- **Frontend Framework:** Next.js application (React-based) in the `app` directory.
- **Runtime Environment:** Node.js 20 on Alpine Linux, packaged in a Docker container.
- **Build Strategy:** Multi-stage Dockerfile that produces a **standalone** Next.js build for a small, efficient runtime image.

### Docker Setup

This project uses a two-stage Docker build defined in `Dockerfile`:

1. **Builder Stage (`node:20-alpine`):**
	 - Installs Node.js dependencies with `npm install`.
	 - Runs `npm run build` to create a Next.js standalone build (via `output: 'standalone'` in `next.config.mjs`).
	 - Produces a minimal `server.js` and only the runtime dependencies required by the app.

2. **Production Stage (`node:20-alpine`):**
	 - Copies only the standalone build output and static assets from the builder image:
		 - `.next/standalone` (includes `server.js` and required Node modules)
		 - `.next/static` (compiled JS/CSS assets)
		 - `public` (static user assets)
	 - Sets `NODE_ENV=production` for optimized runtime behavior.
	 - Exposes port **3000**.
	 - Starts the app with:

		 ```bash
		 node server.js
		 ```

### Containers in This Project

- **Application Container (brightpath-app):**
	- Image built from this repository using the multi-stage Dockerfile.
	- Runs the Next.js server and serves the BrightPath Tutoring UI on port 3000.

> Future extensions: You can add additional containers (e.g., a database, Redis, or a separate API service) and orchestrate them via Docker Compose, while keeping the same containerization principles used here.

---

## Business Value of Docker for BrightPath

For a student-facing educational app like BrightPath Tutoring, Docker provides several key benefits:

- **Eliminates “works on my machine” issues:**
	- Every student and instructor runs the *same* container image, with the same Node.js version, OS base image, and dependencies.
	- Environment drift (different Node versions, missing packages, OS differences) is removed as a source of bugs.

- **Simple onboarding for students:**
	- Instead of installing Node.js, npm, and other tooling, students only need Docker.
	- One or two copy-paste commands (`docker build`, `docker run`) are enough to see the app running.

- **Reliable demos and labs:**
	- Instructors can be confident that lab instructions produce consistent results across classroom machines, home laptops, and lab environments.
	- Updates are shipped as new container images, not as long setup guides.

- **Scalable and production-ready:**
	- The same container used in class can be deployed to staging or production without changes.
	- Operations teams can reuse standard Docker tooling (CI/CD, registries, orchestrators) without special cases for the student app.

In the context of educational technology, this consistency and ease of setup are critical—students can focus on learning concepts instead of debugging environment issues.

---

## Tech Stack

- **Frontend Framework:** Next.js (React)
- **Runtime:** Node.js 20 (Alpine Linux base image)
- **Containerization:** Docker multi-stage build
- **Package Manager:** npm
- **Language:** JavaScript / TypeScript-ready configuration

You can see the core configuration in:

- `next.config.mjs` – enables `output: 'standalone'` for minimal server output.
- `Dockerfile` – defines the builder and production stages.

---

## Requirements & Prerequisites

- **Docker:**
	- Docker Desktop (Windows/macOS) or Docker Engine (Linux).
- **Optional (for local non-Docker development):**
	- Node.js 20+
	- npm

With Docker installed, the commands in the **Quick Start** section are all that students need to run the project.

---

## Git Branches & Workflow

This repo uses a simple branching model:

- **main** – production-ready, stable code.
- **develop** – integration branch for in-progress work.
- **hotfix/*** – short-lived emergency fix branches created from `main` and deleted after merge.

Long-lived branches are limited to `main`, `develop`, and (optionally) a current `hotfix` branch.

See BRANCHING-STRATEGY.MD for details.

---

## Next Steps (For Maintainers)

- Customize the **Project Overview** section with your specific BrightPath Tutoring goals and learning outcomes.
- Extend the **Architecture** section if you introduce additional services (e.g., database, API gateway, or analytics).
- Document any environment variables, lab configurations, or feature flags that students or instructors may need.

