# phpMyAdmin (standalone)

Runs **only phpMyAdmin** and connects to a MySQL/MariaDB server you already
have. No database is started by this stack.

## Security highlights

| Concern              | How it's handled                                              |
| -------------------- | ------------------------------------------------------------- |
| Host binding         | UI binds to **127.0.0.1 only** — never `0.0.0.0`.             |
| Arbitrary servers    | Off by default (`PMA_ARBITRARY=0`) — locked to `PMA_HOST`.    |
| Privilege escalation | `no-new-privileges`; **all** Linux capabilities dropped.     |
| Info disclosure      | PHP version hidden, version checks and error reports off.     |
| Sessions             | Short login-cookie validity, not persisted past the session. |
| Reproducibility      | Image is version-pinned (`phpmyadmin:5.2-apache`).           |

## Quick start

```bash
cp .env.example .env      # then set PMA_HOST for your database
docker compose up -d
```

Open **http://localhost:8080** and log in with your MySQL username and password.

## Pointing it at your database (`PMA_HOST`)

| Your MySQL is…                        | Set `PMA_HOST` to…                          |
| ------------------------------------- | ------------------------------------------- |
| On this machine / Docker Desktop      | `host.docker.internal` (default)            |
| A remote server                       | its hostname or IP, e.g. `db.example.com`   |
| In **another Docker Compose project** | that DB's service name (e.g. `db`) + attach its network (below) |

### Connecting to a DB in another Docker network

If your MySQL runs in another compose project (e.g. it's on network
`docker-mysql_backend`):

1. `docker network ls` to find the network name.
2. In `.env`, set `PMA_HOST=db` (the database's **service name**).
3. In `docker-compose.yml`, uncomment the `networks:` block at the bottom, set
   the real network `name:`, and add `networks: [default, dbnet]` under the
   `phpmyadmin` service.
4. `docker compose up -d`.

## Common operations

```bash
docker compose ps                 # status + health
docker compose logs -f            # follow logs
docker compose down               # stop and remove
docker compose pull && docker compose up -d   # update the pinned image
```

## Production notes

- Don't publish phpMyAdmin directly. Put it behind a reverse proxy that
  terminates **TLS**, set `PMA_ABSOLUTE_URI` to the public `https://` URL, and
  restrict access (IP allow-list or an auth layer at the proxy).
- Keep `PMA_ARBITRARY=0` so the tool can only reach the one server you intend.

## Troubleshooting

- **"mysqli::real_connect (2002)" / cannot connect.** `PMA_HOST` is wrong or the
  DB isn't reachable from the container. For a DB on the host, use
  `host.docker.internal`; for one in another Docker network, attach that network
  (see above). Confirm the DB actually accepts connections from this host/user.
- **Port already in use.** Change `PMA_HOST_PORT` in `.env`.
