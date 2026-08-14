"""Minimal Stage 1.6 HTTP probe with no third-party runtime dependencies."""

from __future__ import annotations

import json
import os
import re
import signal
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DEFAULT_PORT = 8080
REVISION_PATTERN = re.compile(r"(?:[0-9a-f]{40}|development)")
VERSION_PATTERN = re.compile(r"(?:sha-[0-9a-f]{40}|development)")


def _metadata() -> tuple[str, str]:
    revision = os.environ.get("BUILD_REVISION", "development")
    version = os.environ.get("IMAGE_VERSION", "development")
    if REVISION_PATTERN.fullmatch(revision) is None:
        raise ValueError("BUILD_REVISION must be a full lowercase Git SHA")
    if VERSION_PATTERN.fullmatch(version) is None:
        raise ValueError("IMAGE_VERSION must be sha-<full-lowercase-Git-SHA>")
    return revision, version


class ProbeHandler(BaseHTTPRequestHandler):
    """Serve only the deliberately public probe contracts."""

    protocol_version = "HTTP/1.1"
    server_version = "sec-filing-rag-probe"
    sys_version = ""

    def _send(self, status: HTTPStatus, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler contract
        if self.path == "/":
            self._send(
                HTTPStatus.OK,
                b"SEC Filing RAG Stage 1.6 delivery probe\n",
                "text/plain; charset=utf-8",
            )
            return

        if self.path == "/healthz":
            self._send(
                HTTPStatus.OK,
                b'{"status":"ok"}',
                "application/json",
            )
            return

        if self.path == "/version":
            revision, version = _metadata()
            body = json.dumps(
                {"revision": revision, "version": version},
                separators=(",", ":"),
                sort_keys=True,
            ).encode("utf-8")
            self._send(HTTPStatus.OK, body, "application/json")
            return

        self._send(
            HTTPStatus.NOT_FOUND,
            b'{"error":"not_found"}',
            "application/json",
        )

    def log_message(self, format_string: str, *args: object) -> None:
        # Do not log client addresses, headers, environment, or topology.
        print(f"probe {format_string % args}", flush=True)


def serve() -> None:
    """Run until SIGTERM/SIGINT, then close without a deadlock."""

    _metadata()
    port = int(os.environ.get("PORT", str(DEFAULT_PORT)))
    if not 1 <= port <= 65535:
        raise ValueError("PORT must be between 1 and 65535")

    stop = threading.Event()

    def request_stop(_signum: int, _frame: object) -> None:
        stop.set()

    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)

    server = ThreadingHTTPServer(("0.0.0.0", port), ProbeHandler)
    server.timeout = 0.25
    try:
        while not stop.is_set():
            server.handle_request()
    finally:
        server.server_close()


if __name__ == "__main__":
    serve()
