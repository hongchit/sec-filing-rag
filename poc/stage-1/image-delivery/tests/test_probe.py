from __future__ import annotations

import json
import os
import signal
import socket
import subprocess
import sys
import time
import unittest
import urllib.error
import urllib.request
from pathlib import Path

PROBE = Path(__file__).resolve().parents[1] / "probe.py"
REVISION = "0123456789abcdef0123456789abcdef01234567"


def available_port() -> int:
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


class RunningProbe:
    def __init__(self) -> None:
        self.port = available_port()
        environment = os.environ.copy()
        environment.update(
            {
                "BUILD_REVISION": REVISION,
                "IMAGE_VERSION": f"sha-{REVISION}",
                "PORT": str(self.port),
            }
        )
        self.process = subprocess.Popen(
            [sys.executable, str(PROBE)],
            env=environment,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            try:
                urllib.request.urlopen(self.url("/healthz"), timeout=0.2).read()
                return
            except (OSError, urllib.error.URLError):
                if self.process.poll() is not None:
                    break
                time.sleep(0.05)
        return_code = self.process.wait(timeout=1)
        raise RuntimeError(f"probe did not start: return_code={return_code}")

    def url(self, path: str) -> str:
        return f"http://127.0.0.1:{self.port}{path}"

    def stop(self) -> int:
        if self.process.poll() is None:
            self.process.send_signal(signal.SIGTERM)
        return self.process.wait(timeout=3)


class ProbeContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.probe = RunningProbe()

    def tearDown(self) -> None:
        self.assertEqual(self.probe.stop(), 0)

    def fetch(self, path: str) -> tuple[int, str, bytes]:
        try:
            response = urllib.request.urlopen(self.probe.url(path), timeout=2)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            return response.status, response.headers["Content-Type"], response.read()

    def test_root(self) -> None:
        status, content_type, body = self.fetch("/")
        self.assertEqual(status, 200)
        self.assertEqual(content_type, "text/plain; charset=utf-8")
        self.assertEqual(body, b"SEC Filing RAG Stage 1.6 delivery probe\n")

    def test_health(self) -> None:
        status, content_type, body = self.fetch("/healthz")
        self.assertEqual(status, 200)
        self.assertEqual(content_type, "application/json")
        self.assertEqual(json.loads(body), {"status": "ok"})

    def test_version_is_sanitized(self) -> None:
        status, _, body = self.fetch("/version")
        self.assertEqual(status, 200)
        self.assertEqual(
            json.loads(body),
            {"revision": REVISION, "version": f"sha-{REVISION}"},
        )

    def test_unknown_route(self) -> None:
        status, _, body = self.fetch("/not-public")
        self.assertEqual(status, 404)
        self.assertEqual(json.loads(body), {"error": "not_found"})


class ProbeValidationTests(unittest.TestCase):
    def test_invalid_revision_fails_before_listening(self) -> None:
        environment = os.environ.copy()
        environment.update(
            {"BUILD_REVISION": "not-a-sha", "IMAGE_VERSION": "development"}
        )
        result = subprocess.run(
            [sys.executable, str(PROBE)],
            env=environment,
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("BUILD_REVISION", result.stderr)


if __name__ == "__main__":
    unittest.main()
