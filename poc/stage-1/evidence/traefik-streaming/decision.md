# PoC decision: traefik-streaming

- Outcome: accept with constraints
- Owner: repository maintainer
- Reviewer: pending
- Decision date (UTC): 2026-07-25
- Evidence: `evidence.md`

## Decision

Use Traefik for the Stage 2 same-origin frontend and `/api` ingress pattern,
including SSE, subject to the constraints below.

## Rationale

The PoC passed HTTPS redirect, exact host routing, frontend/API route selection,
request-size rejection, forwarded-header spoof rejection, backend isolation,
incremental SSE delivery, deliberate disconnect, and successful reconnect.

## Constraints

- Only Traefik may join the externally reachable edge network; application
  services remain on an internal network and expose no host or public ports.
- Configure exact production hosts and publish only HTTPS. Replace the
  disposable certificate with the Stage 2 certificate issuer.
- Configure `forwardedHeaders.trustedIPs` from the actual K3s/L4 proxy path.
  Never enable insecure forwarded-header trust or copy the PoC loopback values
  without validating the production source addresses.
- Use a dedicated higher-priority SSE route. Do not attach Traefik's buffering
  middleware to streaming routes; enforce request body limits on ordinary API
  routes and again at the application boundary.
- Keep `responseForwarding.flushInterval` explicit and ensure the application
  emits a real streaming response. Response headers alone do not prove
  incremental delivery.
- Keep heartbeat intervals below bounded proxy and application timeouts, and
  test disconnect/reconnect through the deployed Stage 2 ingress.
- Treat these Docker Desktop measurements as directional because linux/amd64
  ran under emulation on an arm64 host.

## Stage 2 consequences

- Prefer explicit Traefik `IngressRoute`/middleware resources or equivalently
  rendered, reviewable configuration over opaque ingress annotations.
- Create exact-host frontend, ordinary `/api`, and higher-priority SSE routes.
- Apply request-size middleware only to non-streaming routes and retain
  application-side limits.
- Configure trusted proxy CIDRs in Traefik's static entry-point configuration.
- Preserve separate public-edge and internal-service trust boundaries.
- Repeat the suite with production-like TLS, K3s routing, authentication, and
  actual proxy source addresses before public release.

## Follow-up

During Stage 2, translate this accepted pattern into K3s resources and rerun the
same assertions against the deployed ingress.
