# Traefik routing and streaming PoC

This disposable Compose project kicks off Stage 1.5 with Traefik 3.7.1, static
file-provider routes, and synthetic frontend/API responders. It publishes only
loopback ports, mounts no Docker socket, and creates no persistent volume.

From the repository root:

```sh
docker compose --project-name sec-filing-rag-poc-traefik-streaming \
  -f poc/stage-1/traefik-streaming/compose.yml config --quiet
docker compose --project-name sec-filing-rag-poc-traefik-streaming \
  -f poc/stage-1/traefik-streaming/compose.yml up -d --wait
CURL_BIN="${CURL_BIN:-curl}" \
  sh poc/stage-1/traefik-streaming/tests/run-functional.sh
docker compose --project-name sec-filing-rag-poc-traefik-streaming \
  -f poc/stage-1/traefik-streaming/compose.yml down --volumes --remove-orphans
```

Capture exact image digests, results, measurements, disconnect/reconnect
observations, and cleanup evidence before checking off tasks 5.1–5.3.

On the tested Apple Silicon host, macOS `/usr/bin/curl` uses an older x86_64
LibreSSL build that failed the TLS handshake with the emulated `linux/amd64`
Traefik image. Set `CURL_BIN=/opt/homebrew/opt/curl/bin/curl` to use the native
Homebrew OpenSSL build; this changes only the test client.
