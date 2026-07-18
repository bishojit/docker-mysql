# Secure MySQL + phpMyAdmin (Docker Compose)

A production-minded, security-hardened local stack:

- **MySQL 8.4 (LTS)** — the database.
- **phpMyAdmin 5.2** — a web UI for managing it.

## Security highlights

| Concern              | How it's handled                                                                 |
| -------------------- | -------------------------------------------------------------------------------- |
| Credentials          | Docker **secrets** (files), never hard-coded or baked into env values.           |
| Network exposure     | MySQL lives on an **internal** network with no internet route; not published to the LAN. |
| Host binding         | Ports bind to **127.0.0.1 only** — never `0.0.0.0`.                               |
| Least privilege      | App user is scoped to a single database; `root` is used only for admin.          |
| Privilege escalation | `no-new-privileges` on both containers; phpMyAdmin drops all Linux capabilities. |
| Server hardening     | `skip-name-resolve`, `local-infile=0`, `secure-file-priv` (via `command:` flags). |
| UI hardening         | Arbitrary-server login disabled, version pings off, short session lifetime.      |
| Resilience           | Health checks, ordered startup, restart policy, capped logs, resource limits.    |
| Reproducibility      | Images are version-pinned.                                                        |

## Prerequisites

- Docker Engine 24+ and the Docker Compose v2 plugin (`docker compose`).

## Quick start

```bash
# 1. Configuration (non-secret)
cp .env.example .env

# 2. Generate strong random passwords into ./secrets
#    Windows:
./scripts/generate-secrets.ps1
#    macOS / Linux / Git Bash:
./scripts/generate-secrets.sh

# 3. Start
docker compose up -d

# 4. Watch it become healthy
docker compose ps
```

Then open **http://localhost:8080**.

### Logging in

Log in with the **application user** (recommended day-to-day):

- **Username:** value of `MYSQL_USER` in `.env` (default `appuser`)
- **Password:** contents of `secrets/mysql_password.txt`

For full administration, log in as `root` with the contents of
`secrets/mysql_root_password.txt`.

## Connecting an application

**From another container** in this Compose project, connect to host `db`,
port `3306`, database `appdb`, user `appuser`.

**From your host machine:** MySQL is not published to the host by default (it
lives on an internal, isolated network). Two options:

- Quick queries without exposing a port:
  ```bash
  docker compose exec db mysql -u appuser -p appdb
  ```
- Native client (Workbench / DBeaver / CLI): opt in by uncommenting the
  host-exposure recipe under the `db` service in `docker-compose.yml`, then
  recreate the stack. It binds `127.0.0.1:${MYSQL_HOST_PORT}` (loopback only):
  ```
  Host: 127.0.0.1   Port: 3306   Database: appdb
  User: appuser     Password: <secrets/mysql_password.txt>
  ```

## Common operations

```bash
docker compose logs -f db            # follow database logs
docker compose ps                    # status + health
docker compose down                  # stop (keeps data)
docker compose down -v               # stop and DELETE all data (destructive)
docker compose pull && docker compose up -d   # update to newer pinned images
```

### Backup & restore

```bash
# Backup (reads the root password from the secret file inside the container)
docker compose exec db sh -c \
  'exec mysqldump -uroot -p"$(cat /run/secrets/mysql_root_password)" --single-transaction --all-databases' \
  > backup.sql

# Restore
docker compose exec -T db sh -c \
  'exec mysql -uroot -p"$(cat /run/secrets/mysql_root_password)"' < backup.sql
```

## Hardening further (for real remote/production use)

This stack is hardened for local/dev-server use. Before exposing it to a network:

1. **Do not publish phpMyAdmin directly.** Put it behind a reverse proxy
   (nginx / Traefik / Caddy) that terminates **TLS**, and set `PMA_ABSOLUTE_URI`
   to the public `https://` URL. Consider restricting access by IP or adding an
   auth layer at the proxy.
2. **Keep MySQL off the host.** By default the database has no host port and is
   internal-only — leave the host-exposure recipe under `db` commented out.
3. **Pin by digest** (e.g. `mysql:8.4@sha256:...`) so image contents can't drift.
4. **Restrict `root`.** Consider setting `MYSQL_ROOT_HOST=localhost` (add it to
   the `db` environment) so `root` cannot authenticate over TCP at all — then
   rely on the scoped app user via phpMyAdmin.
5. **Back up regularly** and test restores.

## Project layout

```
.
├── docker-compose.yml           # the stack
├── .env.example                 # non-secret config (copy to .env)
├── mysql/
│   └── initdb/                   # first-boot SQL/shell scripts (optional)
├── phpmyadmin/
│   └── config.user.inc.php       # UI hardening overrides
├── scripts/
│   ├── generate-secrets.ps1      # credential generator (Windows)
│   └── generate-secrets.sh       # credential generator (POSIX)
└── secrets/                      # git-ignored password files
```

## Troubleshooting

- **phpMyAdmin can't connect / "mysqli::real_connect".** MySQL is probably still
  initializing. `docker compose ps` should show `db` as `healthy`; give it up to
  ~30s on first boot.
- **`db` won't start after changing a password.** The password only applies on a
  **fresh** data volume. To reset from scratch (destroys data):
  `docker compose down -v` then `docker compose up -d`.
- **Port already in use.** Change `MYSQL_HOST_PORT` / `PMA_HOST_PORT` in `.env`.
