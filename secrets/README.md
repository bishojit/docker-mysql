# Secrets

This directory holds the credential files consumed by Docker secrets. They are
**git-ignored** and must never be committed.

Required files (each contains only the password, no trailing newline):

| File                        | Used for                                    |
| --------------------------- | ------------------------------------------- |
| `mysql_root_password.txt`   | MySQL `root` account                        |
| `mysql_password.txt`        | Application user (`MYSQL_USER`) password     |

## Generate them

From the project root:

```powershell
# Windows (PowerShell)
./scripts/generate-secrets.ps1
```

```bash
# macOS / Linux / Git Bash
./scripts/generate-secrets.sh
```

Both scripts create strong random passwords and **skip** any file that already
exists, so they will not clobber credentials on a running stack.

## Rotate a password

1. Stop the stack: `docker compose down`
2. Change the password inside MySQL (or delete the `db_data` volume for a fresh
   start), then update the corresponding `*.txt` file.
3. `docker compose up -d`
