# PoC evidence: traefik-streaming

## Metadata

- Status: `complete`
- Owner: repository maintainer
- Reviewer: pending
- Started at (UTC): 2026-07-25
- Completed at (UTC): 2026-07-25T21:36:10Z
- Repository commit: `af342263b30f90bcc1f1d85023059cc534c616f8`
  plus the uncommitted Stage 1.5 files whose checksums are recorded below
- Host architecture: `arm64`
- Target platform: `linux/amd64`
- Execution mode: Docker Desktop 29.6.2 with Compose 5.3.1; target images
  ran under amd64 emulation

## Question and acceptance criteria

Can Traefik enforce same-origin `/api` routing, HTTPS redirect, exact host
matching, trusted forwarded-header boundaries, request body limits, and a usable
bounded SSE stream without exposing backend services?

## Pinned inputs

| Input | Version or digest | Source | Integrity verification |
| --- | --- | --- | --- |
| Traefik | `v3.7.1`; index `sha256:6b9cbca6fac42ab0075f5437d8dc1685cfd188626d8d515839ea94f8b6271c42`; linux/amd64 manifest `sha256:72ed9e98f2395fca5a9e1c67e131910c21ff06e694955da8e0eae0e5206fc27b` | official image | Compose pins the amd64 manifest; registry manifest inspected with `docker buildx imagetools inspect`; local amd64 image ID `sha256:c7884ffa7a8be9185718011b6ca075c8c6756e0104e5f6f432f72ae7a85fa8d2` |
| Python responder | `3.13.5-alpine`; index `sha256:37b14db89f587f9eaa890e4a442a3fe55db452b69cca1403cc730bd0fbdc8aaf`; linux/amd64 manifest `sha256:f1a962d8ffa50b2006b72b4713a09a89e57def2d28ac28a36900bc070a00db61` | official image | Compose pins the amd64 manifest; registry manifest inspected with `docker buildx imagetools inspect`; local amd64 image ID `sha256:0a387e2ecc4d2bdfd1dedd0134843eb735b0196999e9de16d9ca6f993348e0d3` |

## Reproduction

See `../../traefik-streaming/README.md`. The documented commands were run with
`CURL_BIN=/opt/homebrew/opt/curl/bin/curl`. A clean cached-image
`docker compose up -d --wait` completed in 11.42 seconds.

The executed files had these SHA-256 checksums:

| File | SHA-256 |
| --- | --- |
| `compose.yml` | `7d13638d1c1db9e5a3465e3a96a60d4303ebe11b35363a7b593ab101b9779033` |
| `traefik/dynamic.yml` | `db918a93c73f20a5742d1e61234de3707586b1eeef64f6660cf8df6df2f1077c` |
| `responders/responder.py` | `1a56ad4f3c676bd78614d710e2b46cd1cb3f27577c08e2fbd52a294065a732d7` |
| `tests/run-functional.sh` | `3196188ad8e3a05fe28097ced6c48c10bf1306ab0717e7114daaeaa166e43963` |

## Observations

| Check | Expected | Observed | Pass |
| --- | --- | --- | --- |
| HTTPS redirect | HTTP redirects to HTTPS | `301` with an HTTPS location | yes |
| Same-origin routing | `/` reaches frontend; `/api` reaches API | frontend body and API echo assertions passed through the same host | yes |
| Host validation | unapproved host returns 404 | `invalid.localhost` returned `404` | yes |
| Body limit | 1,025-byte request returns 413 | `/api/echo` returned `413` | yes |
| Forwarded headers | upstream sees approved proxy values | upstream saw `https`; injected `203.0.113.200` was discarded and replaced with the edge peer | yes |
| SSE heartbeat | five events arrive without buffering | three heartbeats were visible after 2.5 seconds; a complete stream delivered five in 5.017 seconds | yes |
| Disconnect/reconnect | a new stream works after disconnect | the first client was killed after the incremental assertion; a new connection delivered five events | yes |
| Anti-buffering headers | stream identifies no-cache/no-buffer behavior | `Cache-Control: no-cache` and `X-Accel-Buffering: no` were present | yes |
| Public exposure | only Traefik has published ports | Traefik published loopback `18080` and `18443`; frontend and API had no host bindings and only joined the internal network | yes |
| Bounded timeouts | ingress does not permit unbounded streams | read/write `15s`, idle `30s`; test client `--max-time 8` | yes |
| Cleanup | no PoC containers, networks, or volumes remain | `down --volumes --remove-orphans` removed all three containers and both networks; follow-up Compose and filtered-network listings were empty | yes |

## Measurements

- Local amd64 image sizes: Traefik 187,073,256 bytes; Python responder
  45,274,529 bytes.
- Post-test snapshot: Traefik 40.64 MiB, API 21.91 MiB, frontend 21.86 MiB.
  CPU was 0.00%, 0.08%, and 0.07%, respectively. This is a single
  Docker Desktop snapshot, not a production capacity measurement.
- Frontend request: HTTP 200 in 0.007232 seconds.
- Complete five-event SSE request: HTTP 200 in 5.017374 seconds.
- Clean cached-image startup to all services healthy: 11.42 seconds.

## Limitations and anomalies

- This Compose kickoff proves configuration behavior, not K3s routing resources.
- The disposable default certificate is suitable only for this PoC.
- The host is arm64 and emulated the intended linux/amd64 target; repeat the
  resource measurements on the Stage 2 target host.
- macOS `/usr/bin/curl` used an older x86_64 LibreSSL build and failed this
  emulated TLS handshake. Native Homebrew curl 8.20.0 with OpenSSL 3.6.2 passed.
- The first configuration failed because Traefik ping implicitly tried to bind
  its default entry point to `:8080`; pinning ping to `web` removed the conflict.
- A single internal Docker network prevented loopback port publication. The
  accepted topology gives only Traefik an edge network while all workloads use
  a separate internal ingress network.
- Applying Traefik's buffering middleware to the SSE route buffered the complete
  response despite response headers. The accepted configuration uses a
  higher-priority stream router without that middleware and proper chunked
  upstream framing.
- Authentication, application authorization, production certificates, CORS,
  full security headers, K3s source addresses, and load behavior remain Stage 2
  concerns.
