# Symfony 8 Base Project Template

A base project template for Symfony 8, using Docker Compose for local development and Caddy as the web server / reverse proxy (with automatic HTTPS).

## Stack

- Symfony 8
- Redis
- Percona 8 (MySQL)
- Docker Compose
- Caddy (with local TLS cert trust support)

## Services

| Service    | Description                                                |
|------------|--------------------------------------------------------------|
| `app`      | PHP/Symfony application container                            |
| `queue`    | Same image as `app`, runs Symfony Messenger workers via supervisord |
| `node`     | Node 22 container for frontend asset building/watching       |
| `database` | Percona 8.4 (MySQL-compatible)                                |
| `caddy`    | Web server / reverse proxy with local HTTPS                  |
| `redis`    | Redis 8                                                       |

## Local Development

1. Create your environment files:

   ```bash
   cp .env.example .env
   cp app/.env.example app/.env
   ```

   Adjust the values in both `.env` (used by Docker Compose, e.g. database credentials) and `app/.env` (used by Symfony) as needed for your local setup.

2. Start the containers:

   ```bash
   docker compose up -d
   ```

3. Run the setup script:

   ```bash
   ./setup.sh
   ```

   This script handles the initial project setup (e.g. installing dependencies, generating app keys/env files, running migrations, and trusting Caddy's locally-generated TLS certificates so your browser/OS doesn't flag the site as insecure).

That's it — once both steps complete, the app should be reachable locally over HTTPS via Caddy.

## Production Deployment

Deployment is fully handled by a single script:

```bash
./deploy.sh
```

This script is responsible for building/pulling images, running the production Docker Compose configuration, applying migrations, and restarting services as needed.

## Notes

- Make sure Docker and Docker Compose are installed before running any of the above.
- `setup.sh` is intended for local/dev environments only — do not run it against production.
- `deploy.sh` assumes the target environment already has the required environment variables/secrets configured.