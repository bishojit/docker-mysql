# Database initialization scripts

Any `*.sql`, `*.sql.gz`, or `*.sh` file placed in this directory is executed
**once**, in alphabetical order, the first time the `db_data` volume is created
(i.e. on a fresh database). They do not run again on subsequent starts.

Use them to create extra schemas, seed reference data, or add tightly-scoped
users. Prefix with a number to control order, e.g. `01-schema.sql`,
`02-seed.sql`.

> The application database (`MYSQL_DATABASE`) and user (`MYSQL_USER`, with
> privileges limited to that database) are already created for you by the image
> — you do not need a script for those.
