# Stage 1.6 image delivery decision

Status: pending operator evidence

- Outcome: pending (`accept`, `constrain`, `replace`, or `defer`)
- Private registry decision: GHCR
- Deployment connectivity decision: repository-scoped ARC, outbound HTTPS,
  zero-to-one ephemeral runner
- Pull credential decision: namespace-local classic PAT with only
  `read:packages`
- ARC credential decision: repository-restricted fine-grained PAT with
  Administration read/write, stored only as an out-of-band Kubernetes Secret
- Image identity decision: full Git commit tag plus registry top-level and
  amd64 child-manifest digests; workloads use only the resolved amd64 digest,
  and manual deployment never rebuilds or retags the accepted commit
- Provenance decision: publish BuildKit OCI provenance and SBOM attestations;
  do not use GitHub artifact attestations because private personal repositories
  require Enterprise Cloud
- TLS decision: namespace-local `cloudflare-origin-cert`; Traefik
  cross-namespace references remain disabled
- PoC lifecycle: delete `project-sec-filing-rag-poc` after evidence
- Persistent-demo boundary: independent manifests, static endpoints only, no
  user input, providers, database, or cost-generating operation
- Stage 1.7 carry-forward: measure ARC controller/listener idle footprint and
  one active runner peak

Tasks 6.1–6.3 remain incomplete until the evidence record proves publication,
private pulling, least-privilege deployment, restoration, PoC cleanup, and the
independent persistent demo on the native K3s host.
