#!/usr/bin/env bash
# Remove nix-darwin user launchd agents left behind by an earlier generation.
# Usage: scripts/prune-user-agents.sh [--dry|-n]
set -euo pipefail

# Why this is needed: nix-darwin emits the ~/Library/LaunchAgents
# install-and-remove block only when the configuration declares at least one
# `launchd.user.agents` entry. Disable the *last* one and the removal loop
# disappears along with it, orphaning the plists already on disk — launchd keeps
# them registered and `KeepAlive` respawns the processes, so the service stays
# up across switches and no amount of rebuilding gets rid of it.
#
# An agent counts as orphaned when it is not shipped by the generation that is
# currently active. Only `org.nixos.*` is considered: home-manager's own
# `org.nix-community.home.*` agents are managed by its activation, and anything
# else in that directory was not put there by us.

LIVE_AGENTS=/run/current-system/user/Library/LaunchAgents
USER_AGENTS="$HOME/Library/LaunchAgents"

dry=0
case "${1:-}" in
    "") ;;
    -n | --dry) dry=1 ;;
    -h | --help)
        echo "Usage: $0 [--dry|-n]"
        echo "  --dry, -n   list orphaned agents without removing them"
        exit 0
        ;;
    *)
        echo "Error: unknown argument '$1'" >&2
        echo "Usage: $0 [--dry|-n]" >&2
        exit 2
        ;;
esac

if [ ! -d "$LIVE_AGENTS" ]; then
    echo "note: $LIVE_AGENTS is missing; treating every org.nixos user agent as orphaned" >&2
fi

shopt -s nullglob
found=0

for plist in "$USER_AGENTS"/org.nixos.*.plist; do
    name="${plist##*/}"

    # Still part of the active generation — leave it alone.
    if [ -e "$LIVE_AGENTS/$name" ]; then
        continue
    fi

    found=1
    label="${name%.plist}"

    if [ "$dry" -eq 1 ]; then
        echo "orphaned  $label"
    else
        echo "removing  $label"
        launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
        rm -f "$plist"
    fi
done

if [ "$found" -eq 0 ]; then
    echo "no orphaned nix-darwin user agents"
fi
