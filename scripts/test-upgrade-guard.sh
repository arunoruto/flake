#!/usr/bin/env bash
# Exercise modules/nixos/system/upgrade-guard.sh against the real GitHub API.
# Needs network, curl, jq and python3:
#   nix shell nixpkgs#{curl,jq,python3} -c scripts/test-upgrade-guard.sh
set -uo pipefail
cd "$(dirname "$0")/.."
guard=modules/nixos/system/upgrade-guard.sh
tmp=$(mktemp -d)
trap 'kill "$sink" 2>/dev/null; rm -rf "$tmp"' EXIT

# Stand-in for ntfy: count POSTs.
python3 -c '
import http.server, sys
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        self.rfile.read(int(self.headers["Content-Length"]))
        open(sys.argv[1], "a").write("post\n")
        self.send_response(200); self.end_headers()
    def log_message(self, *a): pass
http.server.HTTPServer(("127.0.0.1", 18765), H).serve_forever()
' "$tmp/posts" &
sink=$!
sleep 1
mkdir "$tmp/creds"
touch "$tmp/posts"
echo http://127.0.0.1:18765/test >"$tmp/creds/ntfy"

git fetch -q origin main
main=$(git rev-parse origin/main)
fails=0
check() { # name expected-exit rev [env...]
  local name=$1 want=$2 rev=$3
  shift 3
  if [[ $rev == none ]]; then printf '#!/bin/sh\nexit 1\n'; else printf '#!/bin/sh\necho %s\n' "$rev"; fi >"$tmp/nixos-version"
  chmod +x "$tmp/nixos-version"
  before=$(wc -l <"$tmp/posts" 2>/dev/null || echo 0)
  env REPO=arunoruto/flake BRANCH=main HOST=test NIXOS_VERSION="$tmp/nixos-version" \
    CREDENTIALS_DIRECTORY="$tmp/creds" "$@" bash -euo pipefail "$guard" >/dev/null
  got=$?
  after=$(wc -l <"$tmp/posts" 2>/dev/null || echo 0)
  notified=$((after - before))
  want_notified=$((want == 0 ? 0 : 1))
  if [[ $got == "$want" && $notified == "$want_notified" ]]; then
    echo "ok   $name (exit $got, notified $notified)"
  else
    echo "FAIL $name (exit $got want $want, notified $notified want $want_notified)"
    fails=$((fails + 1))
  fi
}

check "dirty rev skips" 1 "$main-dirty"
check "unpushed rev skips" 1 0123456789abcdef0123456789abcdef01234567
check "rev behind main runs" 0 "$(git rev-parse origin/main~3)"
check "rev equal to main runs" 0 "$main"
check "diverged rev skips" 1 a8bfb57f41ed33afc987f5e7171666448cacfdce # old snowfall branch
check "no revision runs" 0 none
check "API unreachable skips" 1 "$main" GITHUB_API=http://127.0.0.1:9
exit "$fails"
