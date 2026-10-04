# Steamix

Turn a NixOS machine into a Steam machine: boot straight into Steam's
**Gaming Mode** (the gamescope-driven Deck UI), with "Switch to Desktop" in
Steam's power menu dropping into a regular desktop session and an icon there
to come back — like SteamOS, without shipping Valve's stack.

Start with [docs/README.md](./docs/README.md); [docs/how-it-works.md](./docs/how-it-works.md)
explains the moving parts, [docs/options.md](./docs/options.md) is the curated
option tour, `docs/reference/` is generated from the module itself, and
[docs/roadmap.md](./docs/roadmap.md) is where the project is headed.
Prebuilt packages come from [steamix.cachix.org](./docs/binary-cache.md).

## Layout

| Path | What |
|------|------|
| `modules/nixos/` | The NixOS module: `steamix.*` options, exported as `nixosModules.default` |
| `packages/` | `steamos-manager`, `decky-loader`, and the `deckyPlugins` scope, exposed via `overlays.default` |
| `.github/workflows/` | CI, canonical copy; the repository root carries a checked byte-for-byte copy, since GitHub ignores symlinked workflows |
| `tests/` | NixOS VM tests, exposed as `checks.x86_64-linux.*`; see [docs/testing.md](./docs/testing.md) |
| `docs/` | mdBook pages (rendered as part of the parent repo's book for now) |

Home Manager modules are deliberately absent rather than stubbed; per-user
pieces would land as `homeModules.default` when there is something to put in
them.

## Status

Incubating inside [arunoruto/flake](https://github.com/arunoruto/flake) until
stable, consumed there as a relative-path flake input with
`inputs.nixpkgs.follows` — which is why no `flake.lock` is committed here.
The layout is already the standalone one, so graduating to its own repository
is a URL change for consumers.
