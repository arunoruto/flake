# Binary cache (Cachix)

Packages from `packages/` can be pushed to the public
[arunoruto.cachix.org](https://arunoruto.cachix.org) cache, so they are built
once and downloaded everywhere else. The cache is listed in `flake.nix`'s
`nixConfig`, which every `nh`/`nix build`/`home-manager --flake` run against
this flake picks up (NixOS, darwin and standalone Home Manager alike), as long
as `accept-flake-config` is on and the user is trusted.

## Opting a package in

Add this to its `package.nix`:

```nix
passthru.cachix = true;
```

It goes in `passthru`, not `meta`: passthru never changes the store path, and
nixpkgs' `checkMeta` rejects unknown meta keys.

The cache is **public** (free tier, 5 GB), so a flagged package is only pushed
when:

- it has a `meta.license`, every license on it has `free = true`, and none of
  them is the generic `licenses.free` (which says nothing about the actual
  terms);
- it is built from source (no binary `meta.sourceProvenance`);
- it is available on the building platform.

A flagged package that fails one of these is dropped with an evaluation
warning naming the reason. Check what would be pushed with:

```sh
nix eval .#legacyPackages.x86_64-linux.cachixPackages --apply builtins.attrNames
```

Names are the `legacyPackages` attribute path joined with `-`
(`custom.explo` → `custom-explo`) and double as the Cachix pin names.

## Which build gets cached

Store paths depend on the whole build graph, so the cache only helps a machine
that asks for exactly the pushed path. `cachix-sync` builds `legacyPackages`,
which is built against **nixpkgs-unstable**. These match it:

- `nix build .#<pkg>` / `.#custom.<pkg>` (PR work);
- `pkgs.custom.<pkg>` on hosts — the `custom-packages` overlay builds against
  `pkgs.unstable` for exactly this reason;
- `pkgs.unstable.<pkg>` on hosts for `top-level/` packages.

A host's plain `pkgs.<pkg>` for a `top-level/` package is built against the
host's 26.05 nixpkgs and will not hit the cache.

## Pushing

```sh
just cachix-sync -n   # build and report, push nothing
just cachix-sync      # build, push and pin
```

This needs `CACHIX_AUTH_TOKEN`, which zsh and fish export from the
`tokens/cachix` sops secret. Per package it:

1. builds it; a failure is recorded and the run continues;
2. skips it if cache.nixos.org already serves that exact path (nothing to gain);
3. `cachix push`es its outputs;
4. `cachix pin`s the main output with `--keep-revisions 1`, so only the newest
   revision is protected and older ones fall back to LRU eviction.

Failed packages are listed at the end and the run exits non-zero.

## Sizing

```sh
just cachix-size custom.explo
```

Prints the uncompressed NAR size of the package's closure minus what
cache.nixos.org already has — i.e. what the push would add. Cachix stores it
compressed, typically 3–4× smaller. Check this before flagging anything large.

## Never push

Unfree or proprietary packages (claude-code, claude-desktop, dpcpp/oneAPI,
CUDA, matlab, telerising, …) and anything with a secret baked in. The license
filter catches the former only if the package's `meta.license` is accurate.
