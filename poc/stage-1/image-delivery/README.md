# Stage 1.6 image-delivery probe

This PoC packages a dependency-free Python 3.14 HTTP service. Local Docker
Desktop validation uses native `linux/arm64`; GitHub Actions publishes the
`linux/amd64` image required by the K3s VPS. It proves image construction,
immutable private registry delivery, and deployment connectivity; it is not
the future FastAPI application and contains no database, provider,
authentication, or user-input behavior.

Public endpoints are limited to:

- `GET /` — static identification text.
- `GET /healthz` — `{"status":"ok"}`.
- `GET /version` — the full build revision and `sha-<revision>` image version.
- Any other path — `404 {"error":"not_found"}`.

The image pins the multi-platform OCI index for `python:3.14.5-slim-trixie`;
Docker resolves its arm64 or amd64 child manifest from the requested platform.
It runs as UID/GID 10001 and is compatible with a read-only root filesystem.
Run the source tests inside the Dev Container:

```bash
poc/stage-1/image-delivery/tests/run-tests.sh
```

Do not add the Docker socket to the Dev Container. Follow
[`docs/stage-1-6-operator-runbook.md`](../../../docs/stage-1-6-operator-runbook.md)
for the deliberately human-run Docker, GitHub, GHCR, ARC, and K3s procedure.
