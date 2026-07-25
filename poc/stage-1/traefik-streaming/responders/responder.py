import json
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROLE = sys.argv[1]

class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def send_bytes(self, status, body, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            return self.send_bytes(200, b'{"status":"ok"}')
        if ROLE == "api" and self.path == "/api/echo":
            body = json.dumps({
                "host": self.headers.get("Host"),
                "forwarded_host": self.headers.get("X-Forwarded-Host"),
                "forwarded_proto": self.headers.get("X-Forwarded-Proto"),
                "forwarded_for": self.headers.get("X-Forwarded-For"),
            }, sort_keys=True).encode()
            return self.send_bytes(200, body)
        if ROLE == "api" and self.path == "/api/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Transfer-Encoding", "chunked")
            self.end_headers()
            try:
                for event_id in range(1, 6):
                    event = f"id: {event_id}\nevent: heartbeat\ndata: {event_id}\n\n".encode()
                    self.wfile.write(f"{len(event):x}\r\n".encode() + event + b"\r\n")
                    self.wfile.flush()
                    time.sleep(1)
                self.wfile.write(b"0\r\n\r\n")
                self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
                pass
            return
        if ROLE == "frontend":
            return self.send_bytes(200, b"stage-1.5 frontend\n", "text/plain")
        self.send_bytes(404, b'{"error":"not_found"}')

    def do_POST(self):
        self.rfile.read(int(self.headers.get("Content-Length", "0")))
        self.send_bytes(200, b'{"status":"accepted"}')

    def log_message(self, format, *args):
        sys.stderr.write(f"{ROLE} {self.address_string()} {format % args}\n")

ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
