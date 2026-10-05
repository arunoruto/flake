#!/usr/bin/env bash
# Evaluate every nixos/darwin/home configuration (and the x86_64-linux dev
# shells) in parallel; print one `<attr> <drvPath>` line per job, sorted, with
# EVAL-FAILED in place of the drvPath on error. Exits 1 if any job failed.
#
#   scripts/eval-all.sh [--workers N]   (default 4; each worker peaks ~3 GB)
#
# Used by `just eval-all` and by CI. In GitHub Actions the failures are also
# written to the job summary.
set -euo pipefail

workers=4
while [ $# -gt 0 ]; do
  case "$1" in
    --workers) workers="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp)"
trap 'rm -f "$out"' EXIT

status=0
nix run --inputs-from "$root" nixpkgs#nix-eval-jobs -- \
  --impure \
  --force-recurse \
  --workers "$workers" \
  --max-memory-size 2048 \
  --option extra-experimental-features pipe-operators \
  "$root/scripts/eval-all.nix" >"$out" || status=$?

jq -r '"\(.attr) \(.drvPath // "EVAL-FAILED")"' "$out" | sort

failed="$(jq -r 'select(.error) | .attr' "$out" | sort)"
if [ -z "$failed" ]; then
  # A crash of nix-eval-jobs itself leaves no per-job errors behind.
  [ "$status" -eq 0 ] || echo "nix-eval-jobs exited with status $status" >&2
  exit "$status"
fi

jq -r 'select(.error) | "\n=== \(.attr) ===\n\(.error)"' "$out" >&2
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "## :x: Evaluation failed"
    # shellcheck disable=SC2016 # literal Markdown backticks
    echo "$failed" | sed 's/^/- `/; s/$/`/'
  } >>"$GITHUB_STEP_SUMMARY"
fi
exit 1
