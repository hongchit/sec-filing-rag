# Standalone ARM64 PostgreSQL extension sidecar

This disposable Compose project tests PostgreSQL 18.4 with pgvector 0.8.2 and
pg_textsearch 1.2.0 on native `linux/arm64`. It exposes no host port and does not
reuse the Dev Container database, network, volume, or credentials.

The required project name is `sec-filing-rag-poc-postgres-arm64`. Copy
`.env.example` to the ignored `.env.local` and replace the password with a random,
PoC-only value. Then run all commands from the repository root:

```sh
docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  config

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  build --pull

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  up -d --wait

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  exec -T postgres sh /poc/tests/run-tests.sh
```

Restart the service, run `02-persistence.sql` with `docker compose exec`, and
finish with `down --volumes --remove-orphans`. The reviewed commands and results
belong in `../evidence/postgres-extensions/evidence.md`.

ARM64 is an acceptable deployment architecture and this run establishes the
functional-compatibility milestone. amd64 compatibility is provisionally
assumed but unmeasured; architecture-specific artifacts and digests must still
be verified if amd64 is selected. Stage 1.2 was closed by owner decision with
memory and index-size measurements explicitly deferred to Stage 1.7.
