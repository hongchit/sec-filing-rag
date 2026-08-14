# Stage 1.6 image delivery evidence

Status: awaiting operator execution

Record only sanitized evidence. Never paste tokens, Secret YAML/data,
kubeconfigs, certificate paths, origin addresses, public VPS addresses, or
expanded environment/configuration output.

## Pinned inputs

- Git commit:
- Local/native architecture: `linux/arm64`
- VPS/native architecture: `linux/amd64`
- Python multi-platform index digest:
  `sha256:c845af9399020c7e562969a13689e929074a10fd057acd1b1fad06a2fb068e97`
- Resolved arm64 child manifest digest:
  `sha256:4701f9885ba369bf50a80ae4b5e1f637be3aa961dbb9b676d295e98fb2c01075`
- Resolved amd64 child manifest digest:
  `sha256:7d8de339aa8619f9b25e7d474d687ae4f6ef9704adad90a136af0f485adeccb7`
- GHCR image name:
- Commit tag:
- GHCR top-level index/manifest digest:
- GHCR amd64 deployment-manifest digest:
- ARC controller/scale-set chart version: `0.14.2`
- Runner version: `2.334.0`
- Runner amd64 manifest digest:
  `sha256:91a87fc7ecea714252b01a1a3f0c64d0f8fe6a05fd466a631b9a51f88f4c7aca`
- Kubectl version and amd64 SHA-256:

## Local functional evidence

- Dev Container unit/contract test result:
- Host Docker build command and elapsed time:
- Image size:
- Startup-to-healthy time:
- Reported platform and configured user:
- Read-only, capability-drop, health, HTTP-contract, and SIGTERM result:
- Limitation: local arm64 proves source/image portability but does not replace
  native amd64 production-build and VPS evidence.

### Preliminary implementation validation (2026-08-13)

This is development-metadata evidence only, not the operator acceptance run:

- Five dependency-free syntax/unit/HTTP/SIGTERM tests passed in the Dev
  Container.
- Docker Desktop built and loaded `linux/arm64` from the pinned OCI index; the
  resolved base child was the arm64 digest recorded above.
- The final rebuilt image reported user `10001:10001`, size `144396550`
  bytes, and local image ID
  `sha256:5f22d4e8b16c65bc65f6787e086b112a4f2797269f2df2289f1dd0738d237bea`.
- A loopback-only container ran with a read-only root filesystem, all
  capabilities dropped, no new privileges, and a healthy Docker health check.
- `/`, `/healthz`, `/version`, and the expected `404` were verified from the
  Dev Container through `host.docker.internal`.
- SIGTERM produced exit code `0`, with `OOMKilled=false`; only the named test
  container was removed. The development-tagged local image was retained.
- The labels intentionally used `development` and placeholder source metadata
  because the reviewed implementation had not yet been committed or connected
  to its confirmed GitHub destination.

## GHCR and provenance evidence

- Workflow run URL/ID:
- Tag/top-level/amd64-child digest agreement:
- Anonymous pull denial (sanitized error class only):
- Namespace-scoped authenticated pull result:
- OCI revision/version labels:
- BuildKit OCI SBOM/provenance availability:
- GitHub artifact-attestation limitation: private personal repositories need
  Enterprise Cloud; `actions/attest` is not part of this PoC.

## ARC and RBAC evidence

- Controller/listener readiness:
- Idle runner count:
- Active ephemeral runner count:
- Allowed deployment checks:
- Denied Secret/RBAC/node/default-namespace checks:
- Docker socket/privileged/host-network absence:
- Idle controller/listener resources:
- Active runner peak resources:

## Disposable deployment and restoration

- PoC namespace creation:
- Running pod `imageID` digest match:
- Cluster-local and public health/version checks:
- Deliberately invalid digest failure:
- Accepted digest restoration:
- Public 22/6443/direct-origin/NodePort negative checks:
- PoC namespace cleanup and persistent-namespace non-mutation:

## Independent persistent demo

- Persistent namespace creation:
- Independent manifest review:
- Accepted digest deployment:
- Public Cloudflare health/version checks:
- ARC returned to zero runners:

## Limitations and review

- Native amd64 measurements:
- Known limitations:
- Operator:
- Reviewer:
- Reviewed UTC date:
