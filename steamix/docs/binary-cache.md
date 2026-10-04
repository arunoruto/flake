# Binary cache

Steamix has its own binary cache at
[steamix.cachix.org](https://steamix.cachix.org), so a Steamix machine
downloads what it would otherwise compile:

| Package | Why it is not on cache.nixos.org |
|---------|----------------------------------|
| SteamOS Manager | not in nixpkgs |
| Decky Loader | not in nixpkgs |
| 32-bit gamescope WSI layer | in nixpkgs, but Hydra does not build it; the module installs it by default (`steamix.gamescope.wsi.package32`) |

The Decky plugins are not cached: they are release downloads, so a cache
would save nothing.

## Using it

Machines that import the module get it from `steamix.binaryCache.enable`,
which is on by default and adds the cache and its key to `nix.settings`,
next to `cache.nixos.org`:

```nix
steamix.binaryCache.enable = true; # the default
```

It asks for no trust beyond what importing the module already does: the
module runs as root, and the cache is signed with a key pinned in it. Set it
to `false` to build everything yourself.

Building Steamix's flake directly (`nix build`, the VM tests) uses the same
cache through the flake's `nixConfig`, if `accept-flake-config` is on. Nix
ignores that setting when Steamix is a flake input, which is why the module
option exists. The URL and key, if you want to add them by hand:

```text
https://steamix.cachix.org
steamix.cachix.org-1:RDiQCw/nTZL8BuFm4uZrKEnkCU0xJ+w7zwQ+IQBXan0=
```

## When it helps

A cache only serves the exact store path a machine asks for, and that path
depends on the whole nixpkgs it was built against. CI builds the cached set
against two nixpkgs revisions, the ones the parent repository's lock file
pins for `nixpkgs` (the stable release the hosts run) and `nixpkgs-unstable`.
A machine on either of those revisions gets downloads; a machine on any
other revision builds locally, exactly as it would without the cache.

While Steamix lives inside its parent repository, that means the parent's
hosts always hit it, and other machines hit it when their nixpkgs happens to
match. Once Steamix has its own repository and lock file, CI will build
against Steamix's own pins and the channel heads instead.

## How it is filled

The `cache` job in the Steamix workflow runs on `main` after every VM test
passed, once per channel. It builds the steamix flake's `cache` set, pushes
those outputs and their runtime closures (Cachix skips anything
`cache.nixos.org` has, so in practice one path per package), and pins each as
`<package>-<channel>`, keeping three revisions, so the free tier's garbage
collection never evicts what machines are using. Build-only paths, such as
fetched sources and Decky's pnpm dependencies, are never pushed.

It pushes with an auth token stored as the repository secret
`STEAMIX_CACHIX_AUTH_TOKEN`. Without the secret the job still builds, and
skips the push with a notice.

To see what would be pushed:

```sh
nix eval --no-write-lock-file --inputs-from . --override-input nixpkgs nixpkgs \
  ./steamix#cache --apply builtins.attrNames
```
