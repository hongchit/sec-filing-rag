# ARM64 PostgreSQL sidecar handoff

This document preserves the Stage 1.2 working context before any DevContainer rebuild. The approved deployment target remains `linux/amd64`; the current development host reports `aarch64`.

## Decision boundary

Run an ARM64 sidecar preflight first to prove:

- PostgreSQL 18 starts with pinned pgvector and `pg_textsearch` candidates.
- `pg_textsearch` loads through `shared_preload_libraries`.
- both extensions can be created in the same database.
- representative vector, BM25, and metadata-filtered queries work together.
- data and indexes remain usable after a disposable sidecar restart.
- the build and test procedure is reproducible without production secrets or data.

ARM64 results do **not** prove:

- that the image builds or runs on `linux/amd64`.
- native amd64 latency, memory, image-size, or resource-envelope acceptance.
- that ARM64-specific binaries or image digests may be promoted to Stage 2.

ARM64 is an acceptable deployment architecture. By owner decision, a successful native ARM64 run permits a provisional amd64 compatibility assumption, provided documentation never presents ARM64 measurements or digests as amd64 evidence. Stage 1.2 remains incomplete until all required measurements, including memory and index size, are recorded.

## Safe execution model

Prefer a dedicated Compose project outside `.devcontainer`:

```text
host Docker engine
├── existing DevContainer project        unchanged
└── sec-filing-rag-poc-postgres-arm64    disposable
    ├── PostgreSQL 18 + extensions
    ├── dedicated network
    └── dedicated volume
```

The sidecar should expose no port. Execute SQL with `docker compose exec`. If a host port is temporarily necessary, bind only to `127.0.0.1` and use a non-default port.

Do not reuse the root `.env`, the existing `db` service, its volume, or any Kestra/application credentials. Generate PoC-only credentials in a gitignored local environment file.

## Work to perform from the host

These steps are instructions for a terminal outside the sandbox. They intentionally do not modify or rebuild the running DevContainer.

1. Checkpoint the repository and confirm the harness commit exists:

   ```sh
   cd /path/to/sec-filing-rag
   git status --short
   git log -1 --oneline
   ```

   Expected harness commit: `dd5adea chore: add Stage 1 PoC harness`.

2. Create the bounded implementation files under:

   ```text
   poc/stage-1/postgres-extensions/
   ├── Dockerfile
   ├── compose.arm64.yml
   ├── init/
   ├── tests/
   └── README.md
   ```

   Do not edit `.devcontainer/docker-compose.yml` for the first preflight.

3. Use an explicit ARM64 platform in the temporary Compose service:

   ```yaml
   platform: linux/arm64
   ```

   The image must be built from pinned PostgreSQL 18, pgvector, and `pg_textsearch` versions or immutable revisions. Avoid floating `latest`, `main`, and unqualified `pg18` inputs.

4. Configure PostgreSQL with:

   ```text
   shared_preload_libraries=pg_textsearch
   ```

   Install extension artifacts during the image build, then run `CREATE EXTENSION vector` and `CREATE EXTENSION pg_textsearch` during disposable database initialization.

5. Create a local credential file that remains ignored:

   ```sh
   umask 077
   cp poc/stage-1/postgres-extensions/.env.example \
      poc/stage-1/postgres-extensions/.env.local
   ```

   Replace example values with random PoC-only credentials. Never copy values from the repository root `.env`.

6. Validate the effective Compose configuration before starting it:

   ```sh
   docker compose \
     --project-name sec-filing-rag-poc-postgres-arm64 \
     --env-file poc/stage-1/postgres-extensions/.env.local \
     -f poc/stage-1/postgres-extensions/compose.arm64.yml \
     config
   ```

7. Build and run only the disposable sidecar:

   ```sh
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
   ```

8. Run tests through `docker compose exec`; do not connect the sidecar to the DevContainer network. Record exact commands and reviewed results in `evidence/postgres-extensions/evidence.md`.

9. Verify restart persistence with `docker compose restart`, not by reusing or inspecting the application database.

10. Remove the explicit PoC resources when evidence is captured:

    ```sh
    docker compose \
      --project-name sec-filing-rag-poc-postgres-arm64 \
      --env-file poc/stage-1/postgres-extensions/.env.local \
      -f poc/stage-1/postgres-extensions/compose.arm64.yml \
      down --volumes --remove-orphans
    ```

    Confirm that no resource with the exact project name remains before deleting `.env.local`.

## If a DevContainer change later becomes necessary

Do it only after the standalone sidecar passes and the current work is committed. From the host:

1. Commit evidence and ensure `git status --short` is empty.
2. Push or otherwise preserve the branch if a remote is available.
3. Record the current commit with `git rev-parse HEAD`.
4. Modify `.devcontainer/docker-compose.yml` or `.devcontainer/devcontainer.json` from the host editor.
5. Rebuild the DevContainer.
6. Start a new chat and provide the recorded commit plus this file as context.
7. Run:

   ```sh
   poc/stage-1/scripts/validate-harness.sh
   openspec instructions apply --change define-sec-filing-rag-platform --json
   git status --short
   ```

Do not mark Stage 1.2 complete merely because the rebuilt environment starts.

## Resume point

- OpenSpec change: `define-sec-filing-rag-platform`
- Completed implementation tasks: Stage 1.1 tasks 1.1–1.3
- Active work: Stage 1.2 PostgreSQL extension-stack PoC
- Deployment architectures: validated `linux/arm64`; provisionally assumed `linux/amd64`
- Current environment: `linux/arm64`
- Next action: verify and pin exact extension source revisions, then implement the standalone ARM64 sidecar files
