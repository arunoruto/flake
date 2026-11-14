#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bundix ruby_3_4 curl jq gnused nix-prefetch-github
# shellcheck shell=bash

# Bumps Sure: source hash, re-locked Gemfile.lock and gemset.nix.
# Usage: ./update.sh [version]   (default: latest release)

set -euo pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
VERSION="${1:-$(curl -s https://api.github.com/repos/we-promise/sure/releases/latest | jq -r .tag_name | sed 's/^v//')}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

HASH="$(nix-prefetch-github we-promise sure --rev "v$VERSION" | jq -r .hash)"
SRC="https://raw.githubusercontent.com/we-promise/sure/v$VERSION"
curl -sfo "$WORK/Gemfile" "$SRC/Gemfile"
curl -sfo "$WORK/Gemfile.lock" "$SRC/Gemfile.lock"

cd "$WORK"
# nixpkgs' Ruby patch level rarely matches upstream's exact pin.
sed -i '/^ruby file: ".ruby-version"/d' Gemfile
sed -i '/^RUBY VERSION/,/^$/d' Gemfile.lock
# Prebuilt platform gems -> source gems, keeping every locked version.
platforms="$(sed -n '/^PLATFORMS/,/^$/p' Gemfile.lock | sed '1d;/^$/d')"
# shellcheck disable=SC2086
HOME="$WORK" BUNDLE_PATH="$WORK/.bundle" bundle lock --add-platform ruby --remove-platform $platforms
bundix -l

cp Gemfile Gemfile.lock gemset.nix "$ROOT/"
sed -i -e "s/version = \".*\";/version = \"$VERSION\";/" \
  -e "s#hash = \"sha256-.*\";#hash = \"$HASH\";#" "$ROOT/package.nix"
