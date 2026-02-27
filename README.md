# BrightPath Tutoring – Docker Labs App

## Project Overview

> Placeholder: Add your detailed product description here (target users, learning goals, and how Docker labs fit into the BrightPath Tutoring experience).

---

## Architecture

### Two-Container Orchestration

BrightPath Tutoring runs as a complete application stack using **Docker Compose** with two tightly integrated services:

#### **Application Container (app)**
- **Image:** Built from the multi-stage Dockerfile in this repository
- **Stack:** Next.js (React) frontend + Node.js 20 on Alpine Linux
- **Port:** 3000 (HTTP access)
- **Role:** Serves the BrightPath Tutoring UI and handles student/instructor interactions
- **Build Strategy:** Multi-stage Dockerfile that:
  - **Builder stage:** Installs dependencies and compiles Next.js standalone output
  - **Production stage:** Copies only runtime artifacts (server.js, static assets) for a minimal, efficient image

#### **Database Container (db)**
- **Image:** PostgreSQL 15 on Alpine Linux
- **Port:** 5432 (internal only; not exposed to students)
- **Role:** Persists student data, progress, and configuration
- **Data Persistence:** PostgreSQL data volume (`pgdata`) ensures data survives container restarts
- **Prisma Integration:** Managed via Prisma ORM for safe schema migration and type-safe queries

### How They Communicate

```
┌──────────────────────────────────────────────────────┐
│  Docker Compose Network (internal bridge)            │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌────────────┐              ┌──────────────────┐   │
│  │    app     │  ──────────> │       db         │   │
│  │ (Node.js)  │   (TCP/5432) │   (PostgreSQL)   │   │
│  │  port 3000 │  <────────── │                  │   │
│  └────────────┘              └──────────────────┘   │
│       ↑                              │               │
│       │                              │               │
│   Students                      Persistent          │
│   (HTTP/3000)                   Data Volume         │
│                                 (pgdata)            │
│                                                      │
└──────────────────────────────────────────────────────┘
```

- **Service Discovery:** The `app` container connects to the `db` container using the hostname `db` (Docker's internal DNS resolves the service name to its IP).
- **Environment Variables:** Database connection details (user, password, host, database name) are passed via the `DATABASE_URL` in `.env`.
- **Networking:** Both containers share an internal Docker Compose network, isolated from the host but able to communicate with each other.

### Build Stages in the Dockerfile

1. **Builder Stage (`node:20-alpine`)**
   - Installs npm dependencies
   - Builds Next.js standalone output via `npm run build`
   - Generates Prisma Client for type-safe database queries

2. **Production Stage (`node:20-alpine`)**
   - Copies only production artifacts from the builder
   - Sets `NODE_ENV=production` for optimized performance
   - Starts the server with `node server.js`
   - Result: Minimal, efficient image (~150MB) ready for deployment

---

## Quick Start

To get BrightPath Tutoring running with both the app and database services:

### Prerequisites
- **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
- **No additional software required**—everything runs in containers

### Step-by-Step

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone <repository-url>
   cd Docker-Labs
   ```

2. **Configure environment variables:**
   Create a `.env` file in the project root with:
   ```env
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=your-secure-password
   POSTGRES_DB=brightpath_db
   DATABASE_URL=postgresql://postgres:your-secure-password@db:5432/brightpath_db
   ```
   *(See the Environment Management section below for more details)*

3. **Start the full stack:**
   ```bash
   docker compose up --build
   ```
   - This command starts both the `app` and `db` containers
   - `--build` rebuilds the app image if source code changed
   - Logs from both containers appear in your terminal

4. **Wait for database readiness:**
   - Docker Compose waits for the database healthcheck to pass before starting the app
   - You'll see `app` service connecting once the database is ready

5. **Apply database migrations:**
   Once both services are running, apply any pending Prisma migrations:
   ```bash
   docker compose exec app npx prisma migrate deploy
   ```

6. **Access the application:**
   - Open your browser at **http://localhost:3000**
   - You're now running the full BrightPath Tutoring stack!

### Useful Docker Compose Commands

```bash
# View running services and their status
docker compose ps

# View logs from all services
docker compose logs

# View logs from just the app service
docker compose logs app

# Stop all services (data persists)
docker compose down

# Stop all services and remove the database volume
docker compose down -v
```

### Single-Container Alternative (for quick prototyping)

If you only want to run the app container without a database:
```bash
docker build -t brightpath-app .
docker run --rm -p 3000:3000 brightpath-app
```
*(This runs the app in memory without persistent storage—suitable for testing UI changes)*

---

## Stability Features

BrightPath Tutoring is designed for **reliability in educational environments** where downtime disrupts student learning. The `docker-compose.yml` implements critical stability patterns:

### Database Healthchecks

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres || (echo 'Database failed healthcheck, will not start' && exit 1)"]
  interval: 5s
  timeout: 5s
  retries: 5
  start_period: 15s
```

- **What it does:** Verifies PostgreSQL is accepting connections before marking the service as "healthy"
- **Why it matters:** 
  - The app won't start until the database is truly ready (prevents connection failures)
  - Detects silent database failures and triggers recovery
  - Ensures students get a working application rather than connection errors

- **Configuration breakdown:**
  - `interval: 5s` – Check every 5 seconds
  - `timeout: 10s` – Wait 5 seconds for the check to complete
  - `retries: 5` – Up to 5 failed checks before declaring the container unhealthy
  - `start_period: 15s` – Grace period after container starts before checks count

### Automatic Restart Policy

```yaml
app:
  restart: unless-stopped
```

- **What it does:** Automatically restarts the app container if it crashes
- **Why it matters:**
  - Transient errors (memory spikes, connection timeouts) don't require manual intervention
  - Ensures students can continue learning with minimal disruption
  - Production-grade reliability from development onward

- **Policy behavior:**
  - Restarts the container if it exits unexpectedly
  - Does NOT restart if you explicitly stop it with `docker compose stop`
  - Can be overridden with `docker compose up --no-restart` during development

### Service Dependency Management

```yaml
app:
  depends_on:
    db:
      condition: service_healthy
```

- **What it does:** Ensures the database is healthy before starting the app
- **Why it matters:**
  - Prevents race conditions where the app tries to connect before Postgres is ready
  - Failed database initialization blocks app startup, making issues visible
  - Students see clear, actionable errors rather than cryptic connection timeouts

---

## Environment Management

### Purpose of `.env` Files

Environment variables store sensitive and configuration data outside your codebase:
- **Secrets:** Database passwords, API keys
- **Configuration:** Database name, hostnames, ports
- **Safety:** Prevents accidentally committing sensitive data to version control

### Setting Up `.env`

Create a `.env` file in the project root:

```env
# PostgreSQL Configuration (required for database container)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-strong-password-here
POSTGRES_DB=brightpath_db

# Prisma/App Configuration (required for app container)
DATABASE_URL=postgresql://postgres:your-strong-password-here@db:5432/brightpath_db
```

### How Docker Compose Uses `.env`

```yaml
services:
  db:
    env_file:
      - .env
  app:
    env_file:
      - .env
```

- Both the `app` and `db` containers load variables from your `.env` file
- Variables are accessible inside containers as environment variables
- The Prisma ORM reads `DATABASE_URL` to establish database connections

### Security Best Practices

1. **Never commit `.env` files to version control:**
   - Add `.env` to your `.gitignore` (already configured)
   - Each environment (dev, staging, production) gets its own `.env`

2. **Use strong passwords:**
   - Minimum 16+ characters for production environments
   - Mix uppercase, lowercase, numbers, and special characters

3. **Rotate secrets periodically:**
   - Change database passwords quarterly
   - Update after any suspected compromise
   - Docker Compose can use new `.env` values on the next `docker compose up --build`

4. **Limit access in production:**
   - Store production `.env` files in secure secret management systems (e.g., AWS Secrets Manager, HashiCorp Vault)
   - Never store production credentials on local machines

### Environment Variables Reference

| Variable | Used By | Purpose | Required |
|----------|---------|---------|----------|
| `POSTGRES_USER` | PostgreSQL container | Database admin user | Yes |
| `POSTGRES_PASSWORD` | PostgreSQL container | Admin password for database access | Yes |
| `POSTGRES_DB` | PostgreSQL container | Initial database name to create | Yes |
| `DATABASE_URL` | App & Prisma | Connection string for app to reach database | Yes |

---

## Business Value of Docker for BrightPath

Docker transforms how BrightPath Tutoring operates, directly supporting institutional and student success:

### Reliability for Student Learning

- **99% uptime capability:** Healthchecks and restart policies ensure the application recovers from transient failures without student intervention
- **No "database isn't ready" errors:** Orchestration ensures services start in the correct order
- **Data persistence:** PostgreSQL volume ensures student progress is never lost, even across container restarts
- **Consistent experience:** Every student runs identical software stack—no "works on my machine" surprises

### Operational Simplicity

- **Single command to run everything:** `docker compose up --build` starts app + database in one go
- **Self-healing infrastructure:** Automatic restarts and healthchecks reduce manual ops work
- **Instructor confidence:** Labs produce consistent results across all student machines, no environment debugging
- **Easy updates:** Ship improvements as new container images without complex deployment procedures

### Cost Efficiency

- **Minimal resource footprint:** Alpine Linux + standalone Next.js build reduces image size (~150MB) and RAM usage
- **No licensing required:** Open-source stack (Next.js, Node.js, PostgreSQL)
- **Scalable without rewrite:** Same container used in development is production-ready—no surprises during scaling

### Security & Compliance

- **Isolated containers:** Database is not accessible from outside the Docker network
- **Environment variable separation:** Secrets are not baked into images
- **Audit trail:** Docker logs show what version is running, when restarts occurred, and error messages
- **Compliance-ready:** Container approach makes it easier to meet educational data protection requirements

### Educational Value

Students using Docker Labs experience:
- **Real-world DevOps practices:** Learn containerization the same way industry teams do
- **Focus on learning:** No time lost installing Node.js, managing npm versions, or debugging environment issues
- **Confidence in consistency:** Instructions work the same way at home, in labs, and during assessments
- **Career readiness:** Docker skills directly transfer to internships and employment

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

