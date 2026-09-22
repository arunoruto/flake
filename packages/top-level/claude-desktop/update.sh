#!/usr/bin/env nix
#!nix shell --ignore-environment nixpkgs#cacert nixpkgs#coreutils nixpkgs#curl nixpkgs#gawk nixpkgs#nix nixpkgs#bash --command bash
#
# Regenerate sources.json from Anthropic's apt repository. Pass a version to
# pin an older release, e.g. `./update.sh 2.2553.0`; with no argument the
# newest version in the index wins.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

BASE_URL="https://downloads.claude.ai/claude-desktop/apt/stable"

# "<version> <pool path> <hex sha256>" per package stanza in the apt index.
index_rows() {
    curl -fsSL "$BASE_URL/dists/stable/main/binary-$1/Packages" |
        awk 'BEGIN { RS = "" } {
            version = filename = sha = ""
            n = split($0, lines, "\n")
            for (i = 1; i <= n; i++) {
                if (lines[i] ~ /^Version: /) version = substr(lines[i], 10)
                else if (lines[i] ~ /^Filename: /) filename = substr(lines[i], 11)
                else if (lines[i] ~ /^SHA256: /) sha = substr(lines[i], 9)
            }
            if (version != "" && filename != "" && sha != "") print version, filename, sha
        }'
}

AMD64_ROWS="$(index_rows amd64)"
ARM64_ROWS="$(index_rows arm64)"

VERSION="${1:-$(cut -d' ' -f1 <<<"$AMD64_ROWS" | sort -V | tail -n1)}"

# "<url>" and "<sri hash>" for one architecture at $VERSION.
platform_entry() {
    local rows="$1" system="$2" row path sha
    row="$(awk -v v="$VERSION" '$1 == v { print; exit }' <<<"$rows")"
    if [ -z "$row" ]; then
        echo "error: no $system package for version $VERSION" >&2
        exit 1
    fi
    path="$(cut -d' ' -f2 <<<"$row")"
    sha="$(cut -d' ' -f3 <<<"$row")"
    printf '    "%s": {\n      "url": "%s/%s",\n      "hash": "%s"\n    }' \
        "$system" "$BASE_URL" "$path" \
        "$(nix hash convert --hash-algo sha256 --to sri "$sha")"
}

{
    printf '{\n  "version": "%s",\n  "platforms": {\n' "$VERSION"
    platform_entry "$AMD64_ROWS" x86_64-linux
    printf ',\n'
    platform_entry "$ARM64_ROWS" aarch64-linux
    printf '\n  }\n}\n'
} >sources.json

echo "claude-desktop: pinned $VERSION"
