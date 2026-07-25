#!/usr/bin/env sh
set -eu
base_url=https://127.0.0.1:18443
host_header='Host: poc.localhost'
CURL_BIN=${CURL_BIN:-curl}
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

redirect_headers=$("$CURL_BIN" -fsS -D - -o /dev/null -H "$host_header" http://127.0.0.1:18080/)
printf '%s' "$redirect_headers" | grep -Eqi '^location: https://'
"$CURL_BIN" -fkSs -H "$host_header" "$base_url/" | grep -Fq 'stage-1.5 frontend'
"$CURL_BIN" -fkSs -H "$host_header" "$base_url/api/echo" | grep -Fq '"forwarded_proto": "https"'
[ "$("$CURL_BIN" -kSs -o /dev/null -w '%{http_code}' -H 'Host: invalid.localhost' "$base_url/")" = 404 ]
oversize_status=$(head -c 1025 /dev/zero | "$CURL_BIN" -kSs -o /dev/null -w '%{http_code}' \
  -H "$host_header" -H 'Content-Type: application/octet-stream' --data-binary @- "$base_url/api/echo")
[ "$oversize_status" = 413 ]

spoofed_forwarded_for=$("$CURL_BIN" -fkSs -H "$host_header" \
  -H 'X-Forwarded-For: 203.0.113.200' "$base_url/api/echo")
! printf '%s' "$spoofed_forwarded_for" | grep -Fq '"forwarded_for": "203.0.113.200"'

stream_headers=$("$CURL_BIN" -fkSs -D - -o /dev/null -H "$host_header" "$base_url/api/events")
printf '%s' "$stream_headers" | grep -Eqi '^x-accel-buffering: no'
printf '%s' "$stream_headers" | grep -Eqi '^cache-control: no-cache'

"$CURL_BIN" -fkSsN --max-time 8 -H "$host_header" "$base_url/api/events" \
  >"$tmp_dir/disconnected-events" &
stream_pid=$!
sleep 2.5
incremental_heartbeats=$(grep -c '^event: heartbeat$' "$tmp_dir/disconnected-events")
[ "$incremental_heartbeats" -ge 2 ]
kill "$stream_pid"
wait "$stream_pid" 2>/dev/null || true

events=$("$CURL_BIN" -fkSsN --max-time 8 -H "$host_header" "$base_url/api/events")
reconnected_heartbeats=$(printf '%s' "$events" | grep -c '^event: heartbeat$')
[ "$reconnected_heartbeats" -eq 5 ]
printf 'incremental_heartbeats_after_2.5s=%s reconnected_heartbeats=%s\n' \
  "$incremental_heartbeats" "$reconnected_heartbeats"
printf '%s\n' 'Traefik routing, forwarded-header, and SSE disconnect/reconnect checks passed'
