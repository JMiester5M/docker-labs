# Docker Labs App - Features & System Needs

## Core Features (Student-Facing)

1. **User Accounts & Authentication**  
   - Students can sign up, log in, and log out securely.  
   - Passwords are stored securely (hashed) and sessions/tokens are protected.

2. **Browse Available Labs**  
   - Students can view a catalog of Docker labs with titles, difficulty, and estimated time.  
   - Labs can be filtered or searched (e.g., by topic: images, containers, volumes, networks).

3. **Start and Run a Lab**  
   - Students can launch a selected lab, which provisions a Docker-based environment or provides instructions tied to Docker commands.  
   - Clear step-by-step instructions and objectives are shown for each lab.

4. **Progress Tracking**  
   - The app tracks which labs a student has started, completed, and their completion dates.  
   - Visual indicators (e.g., badges or checkmarks) show completion status.

5. **Lab Feedback & Hints**  
   - Students can view hints for challenging steps within a lab.  
   - After finishing a lab, students can submit feedback (difficulty, clarity, comments).


## System & Technical Requirements

1. **Docker Integration**  
   - Host environment must have Docker installed and accessible to the backend or lab runner.  
   - Labs are defined in a way that can be executed reproducibly (e.g., using Dockerfiles, docker-compose, or scripted command sequences).

2. **Web Application Stack**  
   - Frontend built with Next.js (React) using the existing project structure.  
   - Backend API endpoints to manage labs, user data, and progress.

3. **Persistent Data Storage**  
   - A database (e.g., PostgreSQL, MySQL, or SQLite for development) to store users, labs, and progress.  
   - Migrations or schema definitions maintained in version control.

4. **Authentication & Security**  
   - Secure authentication mechanism with protected routes for logged-in users.  
   - Basic hardening: input validation, protection against common web vulnerabilities.

5. **Containerized Deployment (Target)**  
   - Application services (web app, backend, database) are containerized using Docker.  
   - Docker Compose or similar tooling to run the full stack locally for students.
