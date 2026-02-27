# Branching Strategy

This project uses a simple Git workflow with dedicated branches for production, integration, and emergency fixes.

## main (Production-Ready Code)

- Contains only production-ready, deployable code.
- Every commit on `main` should be stable and tested.
- Only merged from:
	- `develop` for regular releases.
	- `hotfix/*` for emergency fixes.

## develop (Integration Work)

- Primary integration branch where day-to-day development is merged.
- Represents the next release in progress.
- All feature branches are merged into `develop` via pull requests.
- When `develop` is in a stable state and ready for release, it is merged into `main`.

## hotfix/* (Emergency Fixes)

- Used for critical, time-sensitive fixes to production.
- Naming convention: `hotfix/<short-description>` (e.g., `hotfix/fix-login-bug`).
- Branches are created from `main`:
	- `git switch main`
	- `git switch -c hotfix/<short-description>`
- After validation, hotfix branches are merged into **both** `main` and `develop` so the fix is present in current and future releases.
- Once merged, the hotfix branch can be deleted.

## General Guidelines

- All merges into `develop` and `main` should go through pull requests.
- Keep branches focused and small; prefer multiple smaller feature branches over one very large one.
- Rebase or update your feature branch regularly from `develop` to minimize merge conflicts.
