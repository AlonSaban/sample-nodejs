# DevOps Sample Node.js App

## Overview

A lightweight Node.js application. It features basic web endpoints, Prometheus metrics integration, and is designed for Kubernetes deployment and CI/CD pipeline demonstrations.

## Features

- Express.js web server
- Prometheus metrics integration
- Readiness and liveness probe endpoints
- Customizable port via environment variable

## Prerequisites

- Node.js (v22.1.0)



## Git Workflow & Automated Versioning

- **Branching Strategy (GitHub Flow):** `main` is protected and represents production. All changes are developed on short-lived `feat/` or `fix/` branches and merged via Pull Requests gated by Semgrep SAST.
- **Semantic Versioning:** Merges to `main` automatically calculate and tag the next SemVer release (`mathieudutour/github-tag-action`) using Conventional Commits (`fix:` $\rightarrow$ patch, `feat:` $\rightarrow$ minor, `feat!:` $\rightarrow$ major).
Gitops repo ([`sample-nodejs-gitops`](https://github.com/AlonSaban/sample-nodejs-gitops)).

## DevSecOps Pipeline (`.github/workflows/ci-cd.yaml`)

1. **Stage 1 — Static Application Security Testing (SAST):** Runs `semgrep` on every Pull Request and push to `main`, failing the build on `ERROR`-severity findings.
2. **Stage 2 — Version, Build, Container Scan & Push:** Bumps the Git tag, builds the Docker image, scans OS and Node.js packages with **Trivy** (blocking deployment on any `HIGH` or `CRITICAL` vulnerabilities), and pushes verified images to `ghcr.io/alonsaban/sample-nodejs`.
3. **Stage 3 — GitOps Deployment Trigger:** Updates `image.tag` in [`AlonSaban/sample-nodejs-gitops`](https://github.com/AlonSaban/sample-nodejs-gitops) (`sample-nodejs/values.yaml`), triggering ArgoCD to automatically sync the new version into Kubernetes.

## Container Security Hardening (`Dockerfile`)

- Built on `node:22-alpine` with `apk update && apk upgrade --no-cache` to ensure base OS packages (including OpenSSL) are patched at build time.
- Installs production dependencies only (`--omit=dev`) and removes `npm`, `yarn`, and `corepack` from the runtime layer to minimize attack surface and eliminate package-manager CVEs.
- Runs strictly as the non-root `node` user (`UID 1000`).

## Local Docker Verification

```bash
docker build -t sample-nodejs:local .
docker run -d -p 8080:8080 --name test-app sample-nodejs:local
curl -i http://localhost:8080/my-app
docker rm -f test-app