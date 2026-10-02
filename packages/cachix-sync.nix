# Opt-in Cachix pushing for this repo's own packages.
#
# A package opts in with `passthru.cachix = true;` in its package.nix
# (passthru, not meta: it never touches the drv hash, and checkMeta would
# reject an unknown meta key). The cache is public, so a flagged package is
# only collected when every one of its licenses is free and it is built from
# source; a flagged package that fails either check is dropped with a
# warning, never pushed.
#
# `ownPackages` is the legacyPackages scope from ./default.nix. Its
# python3Packages/kodiPackages/home-assistant-custom-components scopes are
# nixpkgs' sets with ours merged in, so those are walked by their directory
# listing only - never the whole nixpkgs set.
{
  pkgs,
  ownPackages,
  cacheName,
  maxDepth ? 2,
}:
let
  inherit (pkgs) lib;

  # Scopes that wrap a nixpkgs package set: only the names we ship.
  mergedScopes = {
    python3Packages = ./python3Packages;
    kodiPackages = ./kodiPackages;
    home-assistant-custom-components = ./home-assistant-custom-components;
  };
  dirNames =
    dir: lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir));

  flagged = drv: (drv.passthru or { }).cachix or false;

  # Why a flagged package may not go to the public cache; null when it may.
  rejection =
    drv:
    let
      meta = drv.meta or { };
      licenses = lib.toList (meta.license or [ ]);
      # The generic `licenses.free` says nothing about the actual license
      # (dpcpp-prop wears it), so it does not count.
      isFree = l: builtins.isAttrs l && (l.free or false) && (l.shortName or null) != "free";
    in
    if licenses == [ ] then
      "no meta.license"
    else if !lib.all isFree licenses then
      "license is not (specifically) free"
    else if !lib.all (s: s.isSource or false) (meta.sourceProvenance or [ ]) then
      "not built from source (meta.sourceProvenance)"
    else if !(meta.available or true) then
      "not available on ${pkgs.stdenv.hostPlatform.system}"
    else
      null;

  collect =
    depth: prefix: set: names:
    lib.foldl' (
      acc: name:
      let
        key = if prefix == "" then name else "${prefix}-${name}";
        r = builtins.tryEval set.${name};
        v = r.value;
      in
      if !(set ? ${name}) || !r.success then
        acc
      else if lib.isDerivation v then
        let
          isFlagged = builtins.tryEval (flagged v);
          reason = builtins.tryEval (rejection v);
        in
        if !(isFlagged.success && isFlagged.value) then
          acc
        else if !reason.success then
          lib.warn "cachix-sync: skipping ${key}: meta does not evaluate" acc
        else if reason.value != null then
          lib.warn "cachix-sync: skipping ${key}: ${reason.value}" acc
        else
          acc // { ${key} = v; }
      else if mergedScopes ? ${key} then
        acc // collect (depth + 1) key v (dirNames mergedScopes.${key})
      else if builtins.isAttrs v && depth < maxDepth then
        acc // collect (depth + 1) key v (lib.attrNames v)
      else
        acc
    ) { } names;

  packages = collect 1 "" ownPackages (lib.attrNames ownPackages);

  sync = pkgs.writeShellApplication {
    name = "cachix-sync";
    runtimeInputs = [
      pkgs.cachix
      pkgs.jq
    ];
    text = ''
      usage() {
        echo "usage: cachix-sync [-n|--dry-run] [FLAKE]   (FLAKE defaults to .)"
        echo "Builds every package flagged passthru.cachix = true and pushes it"
        echo "to ${cacheName}, pinning the newest revision of each."
      }

      dry_run=0
      flake=.
      for arg in "$@"; do
        case "$arg" in
          -n | --dry-run) dry_run=1 ;;
          -h | --help) usage; exit 0 ;;
          *) flake="$arg" ;;
        esac
      done

      if ((!dry_run)) && [[ -z "''${CACHIX_AUTH_TOKEN:-}" ]]; then
        echo "CACHIX_AUTH_TOKEN is not set (it comes from the tokens/cachix sops secret)." >&2
        exit 1
      fi

      system="$(nix eval --impure --raw --expr builtins.currentSystem)"
      attr="$flake#legacyPackages.$system.cachixPackages"

      mapfile -t names < <(nix eval --json "$attr" --apply builtins.attrNames | jq -r '.[]')
      echo "''${#names[@]} package(s) flagged for ${cacheName} on $system"

      failed=()
      for name in "''${names[@]}"; do
        echo ">> $name"
        if ! outs="$(nix build --no-link --print-out-paths "$attr.$name")"; then
          failed+=("$name (build)")
          continue
        fi
        main="$(head -n1 <<<"$outs")"

        # Hydra already serves it: pushing would only spend cache space.
        if nix path-info --store https://cache.nixos.org "$main" &>/dev/null; then
          echo "   already on cache.nixos.org, skipping"
          continue
        fi

        if ((dry_run)); then
          echo "   would push and pin $main"
          continue
        fi

        # shellcheck disable=SC2086 # one store path per word
        if ! cachix push ${cacheName} $outs; then
          failed+=("$name (push)")
          continue
        fi
        # Only the newest revision stays protected; older ones fall back to
        # LRU eviction once the cache fills up.
        if ! cachix pin ${cacheName} "$name" "$main" --keep-revisions 1; then
          failed+=("$name (pin)")
        fi
      done

      if ((''${#failed[@]})); then
        printf 'Failed: %s\n' "''${failed[@]}" >&2
        exit 1
      fi
    '';
  };
in
{
  inherit packages sync;
}
