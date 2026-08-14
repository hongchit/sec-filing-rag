# Stage 1.6 private image delivery operator runbook

This runbook intentionally leaves GitHub, GHCR, Cloudflare, ARC, and K3s
operations to the human operator. Read each command before running it. Run local
project checks in the Dev Container; run Docker Desktop orchestration on the
macOS host; run cluster commands through the established private administrative
path. Never paste a token, kubeconfig, certificate, Secret value, VPS address,
or expanded environment into evidence or chat.

The workflow has two distinct phases:

1. Prove delivery in disposable namespace `project-sec-filing-rag-poc`, rehearse
   a failed rollout and restoration, capture evidence, then delete that exact
   namespace.
2. Create `project-sec-filing-rag` separately and deploy the accepted digest
   from its independent manifests as the persistent static demo.

The same hostname is used sequentially. Never run both ingresses at once.

## 1. Local source and image validation

From the host, enter the existing Dev Container and run the dependency-free
tests:

```bash
devcontainer exec \
  --workspace-folder [path-to-project-root]/sec-filing-rag \
  bash -lc 'poc/stage-1/image-delivery/tests/run-tests.sh'
```

Expect all root, health, version, 404, metadata-validation, and SIGTERM tests to
pass. The Dev Container deliberately has no Docker socket.

On the macOS host, confirm the exact commit and remote before building:

```bash
cd [path-to-project-root]/sec-filing-rag
git status --short
git rev-parse --verify HEAD
git remote -v
```

Stop if `origin` is absent or points to an unexpected repository. Commit the
reviewed Stage 1.6 files before using the resulting revision as image identity.
Then set non-secret shell values:

```bash
STAGE16_REVISION=$(git rev-parse HEAD)
STAGE16_VERSION="sha-${STAGE16_REVISION}"
STAGE16_BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
STAGE16_SOURCE_URL=$(git remote get-url origin)
STAGE16_LOCAL_IMAGE="sec-filing-rag-probe:${STAGE16_VERSION}"
```

Build and run the local image natively as arm64. GitHub Actions separately
builds the amd64 image for the VPS:

```bash
time docker buildx build \
  --platform linux/arm64 \
  --file poc/stage-1/image-delivery/Dockerfile \
  --build-arg "BUILD_DATE=${STAGE16_BUILD_DATE}" \
  --build-arg "BUILD_REVISION=${STAGE16_REVISION}" \
  --build-arg "IMAGE_VERSION=${STAGE16_VERSION}" \
  --build-arg "SOURCE_URL=${STAGE16_SOURCE_URL}" \
  --tag "${STAGE16_LOCAL_IMAGE}" \
  --load \
  poc/stage-1/image-delivery
```

Inspect architecture, user, labels, and size without printing environment data:

```bash
docker image inspect "${STAGE16_LOCAL_IMAGE}" \
  --format 'platform={{.Os}}/{{.Architecture}} user={{.Config.User}} size={{.Size}} health={{json .Config.Healthcheck.Test}}'
docker image inspect "${STAGE16_LOCAL_IMAGE}" \
  --format 'revision={{index .Config.Labels "org.opencontainers.image.revision"}} version={{index .Config.Labels "org.opencontainers.image.version"}} source={{index .Config.Labels "org.opencontainers.image.source"}}'
```

Expect `linux/arm64`, user `10001:10001`, the full commit revision, and the
matching `sha-<commit>` version.

Start one explicitly named, loopback-only, hardened test container:

```bash
docker run --detach \
  --platform linux/arm64 \
  --name sec-filing-rag-poc-stage-1-6-probe \
  --publish 127.0.0.1:18086:8080 \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges=true \
  --pids-limit 64 \
  --memory 64m \
  --cpus 0.25 \
  "${STAGE16_LOCAL_IMAGE}"
```

Check health and contracts from the host:

```bash
docker inspect sec-filing-rag-poc-stage-1-6-probe \
  --format 'running={{.State.Running}} health={{.State.Health.Status}}'
curl --fail --silent --show-error http://127.0.0.1:18086/
curl --fail --silent --show-error http://127.0.0.1:18086/healthz
curl --fail --silent --show-error http://127.0.0.1:18086/version
curl --silent --output /dev/null --write-out '%{http_code}\n' \
  http://127.0.0.1:18086/not-public
```

Optionally prove Dev Container-to-host reachability:

```bash
devcontainer exec \
  --workspace-folder [path-to-project-root]/sec-filing-rag \
  python -c "import urllib.request; print(urllib.request.urlopen('http://host.docker.internal:18086/healthz', timeout=3).read().decode())"
```

Test graceful stop and remove only the named disposable container:

```bash
time docker stop --timeout 5 sec-filing-rag-poc-stage-1-6-probe
docker inspect sec-filing-rag-poc-stage-1-6-probe \
  --format 'exit={{.State.ExitCode}} error={{.State.Error}}'
docker rm sec-filing-rag-poc-stage-1-6-probe
```

This removes the disposable container, not the locally built image. Local
arm64 timing is authoritative only for local development; Stage 1.7 uses native
amd64 VPS measurements for deployment capacity. Record the sanitized results in
`poc/stage-1/evidence/image-delivery/evidence.md`.

## 2. Create the private GitHub repository and push

In the GitHub web UI, create a **private personal repository**. Do not initialize
it with another README or license. Confirm its exact URL, then run locally:

```bash
git remote add origin git@github.com:<OWNER>/<REPOSITORY>.git
git remote -v
git push --set-upstream origin main
```

If `origin` already exists, inspect it and use `git remote set-url origin ...`
only when you deliberately intend to replace it.

In repository settings:

1. Allow GitHub Actions and restrict allowed Actions to the pinned Actions used
   by `.github/workflows/stage-1-6-image-delivery.yml` and
   `.github/workflows/stage-1-6-deploy.yml` if your plan supports it.
2. Keep default `GITHUB_TOKEN` permissions read-only; the publish job requests
   only `packages: write` in addition to `contents: read`.
3. Protect `main`; require the probe test job before merge.
4. Create environments `stage-1-6-poc` and `stage-1-6-persistent`. Add required
   review for deployments if your GitHub plan supports private-repository
   reviewers. Otherwise, owner-only `workflow_dispatch` is the manual gate.
5. Do not add registry or ARC credentials as ordinary workflow secrets; GHCR
   publication uses the per-job `GITHUB_TOKEN`, and ARC credentials stay in
   Kubernetes.

The first successful publish creates a private package named
`sec-filing-rag-probe`. In its package settings, verify it is private and linked
to this repository.

## 3. Prepare the K3s host

Connect over the established private Tailscale/SSH administration path. Do not
open ports 22, 6443, Headlamp, or any runner port publicly.

The remaining host commands assume the reviewed `deploy/stage-1-6` directory
is present in the current directory on the VPS. Avoid installing a persistent
private-repository credential on the server. From the macOS host, copy only
that directory over the private administration path to a temporary location:

```bash
scp -r deploy/stage-1-6 \
  '<VPS_OPERATOR>@<TAILSCALE_NAME>:/tmp/sec-filing-rag-stage-1-6'
```

Then connect to the VPS and work from its parent directory so paths such as
`deploy/stage-1-6/arc/controller-values.yaml` continue to resolve:

```bash
ssh '<VPS_OPERATOR>@<TAILSCALE_NAME>'
mkdir -p /tmp/sec-filing-rag-stage-1-6-work/deploy
mv /tmp/sec-filing-rag-stage-1-6 \
  /tmp/sec-filing-rag-stage-1-6-work/deploy/stage-1-6
cd /tmp/sec-filing-rag-stage-1-6-work
```

The copied files contain no credentials. Remove this exact temporary work
directory after the milestone is reviewed; do not remove it while it is still
needed for the persistent deployment.

Preflight the host:

```bash
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get node -o jsonpath='{range .items[*]}{.metadata.name}{" arch="}{.status.nodeInfo.architecture}{"\n"}{end}'
sudo k3s kubectl get pods -n kube-system
sudo k3s kubectl get service -n kube-system traefik
sudo k3s secrets-encrypt status
sudo k3s kubectl top node
```

Stop unless exactly one node is Ready and its architecture is `amd64`, Traefik
is ready, Secret encryption is enabled, and capacity fits the documented
quotas plus ARC.

Choose a kubectl client patch compatible with the cluster. Remove the K3s
suffix from the server version and verify the official amd64 checksum:

```bash
sudo k3s kubectl version --output=yaml
KUBECTL_VERSION=v<MAJOR.MINOR.PATCH>
curl --fail --silent --show-error --location \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
```

Add the exact version and returned 64-character checksum as repository or both
deployment-environment variables:

- `KUBECTL_VERSION`
- `KUBECTL_SHA256_AMD64`

## 4. Install ARC 0.14.2 manually

ARC adds cluster-level CRDs/controller state. Review the chart release and the
tracked values before installation:

```bash
helm show chart \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller \
  --version 0.14.2
helm show chart \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  --version 0.14.2
```

Install the pinned controller:

```bash
sudo -H helm --kubeconfig /etc/rancher/k3s/k3s.yaml upgrade --install \
  arc-controller \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller \
  --version 0.14.2 \
  --namespace arc-systems \
  --create-namespace \
  --values deploy/stage-1-6/arc/controller-values.yaml \
  --wait
```

For the personal repository, create a fine-grained PAT restricted to this one
repository with only **Administration: read and write**. This permission lets
ARC register repository runners; it is separate from the GHCR pull token.

Create the runner namespace and service account first:

```bash
sudo k3s kubectl apply -f deploy/stage-1-6/arc/runner-namespace.yaml
```

Read the ARC token silently into a root-readable temporary file and create its
Secret from that file. The token is never a process argument, Git content, or
terminal output:

```bash
umask 077
ARC_TOKEN_FILE=$(mktemp /tmp/sec-filing-rag-arc-token.XXXXXX)
read -r -s -p 'ARC repository PAT: ' ARC_REPOSITORY_TOKEN
printf '\n'
printf '%s' "${ARC_REPOSITORY_TOKEN}" > "${ARC_TOKEN_FILE}"
unset ARC_REPOSITORY_TOKEN
sudo k3s kubectl create secret generic arc-github-auth \
  --namespace arc-runners-sec-filing-rag \
  --from-file="github_token=${ARC_TOKEN_FILE}"
rm -f "${ARC_TOKEN_FILE}"
unset ARC_TOKEN_FILE
```

Copy the non-secret values example outside Git and edit only its repository URL:

```bash
cp deploy/stage-1-6/arc/runner-values.example.yaml /tmp/sec-filing-rag-runner-values.yaml
chmod 600 /tmp/sec-filing-rag-runner-values.yaml
${EDITOR:-vi} /tmp/sec-filing-rag-runner-values.yaml
```

Install the repository-scoped zero-to-one runner set:

```bash
sudo -H helm --kubeconfig /etc/rancher/k3s/k3s.yaml upgrade --install \
  sec-filing-rag-deploy \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  --version 0.14.2 \
  --namespace arc-runners-sec-filing-rag \
  --values /tmp/sec-filing-rag-runner-values.yaml \
  --wait
```

The tracked runner template pins both actions-runner version `2.334.0` and its
resolved `linux/amd64` manifest digest. Stop if chart rendering changes or
removes that digest before installation.

Verify controller/listener readiness and zero idle runner pods:

```bash
sudo k3s kubectl get pods -n arc-systems
sudo k3s kubectl get pods -n arc-runners-sec-filing-rag
sudo k3s kubectl get networkpolicy -n arc-runners-sec-filing-rag
```

Expect the controller and listener, but no ephemeral runner while no job is
queued. Delete the non-secret temporary values copy after the install:

```bash
rm /tmp/sec-filing-rag-runner-values.yaml
```

## 5. Create the disposable namespace and out-of-band Secrets

Apply only the operator-owned namespace/quota/RBAC scaffold:

```bash
sudo k3s kubectl apply -f deploy/stage-1-6/poc/namespace.yaml
```

Create a second classic GitHub PAT with only `read:packages`. Do not reuse the
ARC token. Build a mode-`0600` Docker configuration outside Git, create the
namespace-local pull Secret from it, and then remove the temporary file. The
token is never placed in a process argument:

```bash
umask 077
GHCR_CONFIG_DIR=$(mktemp -d /tmp/sec-filing-rag-ghcr.XXXXXX)
GHCR_OWNER='<GITHUB_OWNER>'
read -r -s -p 'GHCR read:packages token: ' GHCR_READ_TOKEN
printf '\n'
GHCR_AUTH=$(printf '%s' "${GHCR_OWNER}:${GHCR_READ_TOKEN}" | base64 -w 0)
printf '{"auths":{"ghcr.io":{"username":"%s","password":"%s","auth":"%s"}}}\n' \
  "${GHCR_OWNER}" "${GHCR_READ_TOKEN}" "${GHCR_AUTH}" \
  > "${GHCR_CONFIG_DIR}/config.json"
unset GHCR_READ_TOKEN GHCR_AUTH
sudo k3s kubectl create secret generic ghcr-pull \
  --namespace project-sec-filing-rag-poc \
  --type=kubernetes.io/dockerconfigjson \
  --from-file=".dockerconfigjson=${GHCR_CONFIG_DIR}/config.json"
rm -f "${GHCR_CONFIG_DIR}/config.json"
rmdir "${GHCR_CONFIG_DIR}"
unset GHCR_CONFIG_DIR GHCR_OWNER
```

Create the Origin CA TLS Secret from files already held outside every
repository:

```bash
sudo k3s kubectl create secret tls cloudflare-origin-cert \
  --namespace project-sec-filing-rag-poc \
  --cert=/path/outside/repositories/origin.pem \
  --key=/path/outside/repositories/origin-key.pem
```

Verify only Secret names/types, never their data:

```bash
sudo k3s kubectl get secret ghcr-pull cloudflare-origin-cert \
  --namespace project-sec-filing-rag-poc \
  -o custom-columns=NAME:.metadata.name,TYPE:.type
```

Prove the runner identity boundary before any workflow:

```bash
RUNNER_ID='system:serviceaccount:arc-runners-sec-filing-rag:sec-filing-rag-deploy-runner'
sudo k3s kubectl auth can-i patch deployments.apps \
  --as="$RUNNER_ID" -n project-sec-filing-rag-poc
sudo k3s kubectl auth can-i get secrets \
  --as="$RUNNER_ID" -n project-sec-filing-rag-poc
sudo k3s kubectl auth can-i create rolebindings.rbac.authorization.k8s.io \
  --as="$RUNNER_ID" -n project-sec-filing-rag-poc
sudo k3s kubectl auth can-i list nodes --as="$RUNNER_ID"
sudo k3s kubectl auth can-i get pods --as="$RUNNER_ID" -n default
```

Expect `yes`, then four `no` results.

## 6. Run and observe the GitHub Actions pipeline

First push the reviewed commit. A push to `main` runs tests, builds only
`linux/amd64`, pushes `sha-<full-commit>` to private GHCR once, adds BuildKit
OCI SBOM and provenance attestations, and validates both the registry's
top-level digest and the amd64 child-manifest digest. It does **not** deploy.
GitHub's separate `actions/attest` service is intentionally not used: private
personal repositories require Enterprise Cloud for that feature.

Inspect the run in GitHub or with the CLI:

```bash
gh run list --workflow stage-1-6-image-delivery.yml --limit 5
gh run view <RUN_ID>
```

Record both published `sha256:<64 hex>` values. The top-level digest identifies
the OCI index containing the image plus its SBOM/provenance attestations; the
amd64 child digest is the immutable workload identity. On the VPS, prove
anonymous access to the private amd64 image fails before creating any
node-global registry configuration:

```bash
sudo k3s ctr images pull \
  ghcr.io/<OWNER>/sec-filing-rag-probe@sha256:<AMD64_DEPLOY_DIGEST>
```

Expect an authorization/denied error. Do not copy the complete error if it
contains identifying infrastructure detail.

Now manually dispatch the disposable deployment and request restoration
rehearsal. Use the exact 40-character revision whose image digests you just
reviewed:

```bash
STAGE16_ACCEPTED_REVISION='<FULL_40_CHARACTER_GIT_SHA>'
gh workflow run stage-1-6-deploy.yml \
  --ref main \
  -f image_revision="${STAGE16_ACCEPTED_REVISION}" \
  -f target=poc \
  -f rehearse_failure=true
gh run list --workflow stage-1-6-deploy.yml --limit 1
gh run watch <RUN_ID>
```

Approve `stage-1-6-poc` in the GitHub UI if environment approval is enabled.
While the deploy job runs, observe one ephemeral runner and then its removal:

```bash
sudo k3s kubectl get pods -n arc-runners-sec-filing-rag --watch
```

After success, verify immutable identity and exposure:

```bash
sudo k3s kubectl rollout status deployment/sec-filing-rag-probe \
  -n project-sec-filing-rag-poc
sudo k3s kubectl get pods,service,ingress \
  -n project-sec-filing-rag-poc -o wide
sudo k3s kubectl get pod -n project-sec-filing-rag-poc \
  -l app.kubernetes.io/name=sec-filing-rag-probe \
  -o jsonpath='{.items[0].status.containerStatuses[0].imageID}{"\n"}'
curl --fail --silent --show-error https://sec-filing-rag.henrychan.dev/
curl --fail --silent --show-error https://sec-filing-rag.henrychan.dev/healthz
curl --fail --silent --show-error https://sec-filing-rag.henrychan.dev/version
```

The `imageID` must contain the recorded amd64 child digest. Confirm the active
runner had no Docker socket, privileged mode, or host networking:

```bash
sudo k3s kubectl get pod -n arc-runners-sec-filing-rag \
  -l actions.github.com/scale-set-name=sec-filing-rag-deploy \
  -o jsonpath='{range .items[*]}{.metadata.name}{" hostNetwork="}{.spec.hostNetwork}{" privileged="}{.spec.containers[0].securityContext.privileged}{" mounts="}{range .spec.containers[0].volumeMounts[*]}{.mountPath}{","}{end}{"\n"}{end}'
```

If the runner has already exited, use the observed pod description captured
during the run and the tracked chart values. Never dump all pod environment.

From a non-tailnet network, repeat the platform negative tests: public TCP 22
and 6443 fail, direct-origin 443 fails, no NodePort exists, while the proxied
hostname succeeds. Use the exact procedures in the production k3s runbooks;
do not place live IP addresses in this repository.

## 7. Delete the disposable proof

Review the exact target first:

```bash
sudo k3s kubectl get all,ingress,secret,role,rolebinding \
  -n project-sec-filing-rag-poc
sudo k3s kubectl get namespace project-sec-filing-rag 2>/dev/null || true
```

The next command permanently deletes the PoC namespace and its namespaced
Secrets and diagnostics. It does not delete the persistent namespace or GHCR
image:

```bash
sudo k3s kubectl delete namespace project-sec-filing-rag-poc
sudo k3s kubectl wait --for=delete namespace/project-sec-filing-rag-poc \
  --timeout=120s
```

Verify `project-sec-filing-rag` was not mutated.

## 8. Deploy the independent persistent demo

Apply the separate persistent scaffold:

```bash
sudo k3s kubectl apply -f deploy/stage-1-6/persistent/namespace.yaml
```

Repeat the two Secret-creation commands from section 5 using namespace
`project-sec-filing-rag`. Secrets cannot be copied by the deploy runner and
must not be exported from the old namespace.

Dispatch the independent persistent overlay after reviewing it. Reuse the
accepted PoC image revision even if `main` has moved; the manual workflow
resolves its existing digest and does not rebuild or retag it:

```bash
gh workflow run stage-1-6-deploy.yml \
  --ref main \
  -f image_revision="${STAGE16_ACCEPTED_REVISION}" \
  -f target=persistent \
  -f rehearse_failure=false
gh run list --workflow stage-1-6-deploy.yml --limit 1
gh run watch <RUN_ID>
```

Approve the persistent environment if configured. Verify the same digest,
public health/version contracts, ClusterIP-only Service, and zero idle runner
pods. Record native node and ARC resource measurements:

```bash
sudo k3s kubectl top node
sudo k3s kubectl top pods -n arc-systems
sudo k3s kubectl top pods -n arc-runners-sec-filing-rag
sudo k3s kubectl top pods -n project-sec-filing-rag
sudo k3s kubectl get pods -n arc-runners-sec-filing-rag
```

## 9. Completion gate

Fill in the evidence and decision records without secrets. Only after another
review confirms private pull, digest identity, least privilege, restoration,
negative exposure, PoC cleanup, persistent deployment, and native resource
evidence should tasks 6.1–6.3 be marked complete.

Do not archive the OpenSpec change after Stage 1.6; Stage 1.7 and later tasks
remain pending.

After the persistent deployment and evidence review, remove only the copied
non-secret operator files from the VPS:

```bash
cd /tmp
rm -rf /tmp/sec-filing-rag-stage-1-6-work
```

This command does not remove any namespace, Secret, image, ARC release, or
persistent workload.
