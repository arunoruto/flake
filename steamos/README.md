# steamos.nix

Turn a NixOS machine into a Steam machine: boot straight into Steam's
**Gaming Mode** (the gamescope-driven Deck UI), with "Switch to Desktop" in
Steam's power menu dropping into a regular desktop session and an icon there
to come back — like SteamOS, without shipping Valve's stack.

Start with [docs/README.md](./docs/README.md); [docs/how-it-works.md](./docs/how-it-works.md)
explains the moving parts, [docs/options.md](./docs/options.md) is the curated
option tour, and `docs/reference/` is generated from the module itself.

## Layout

| Path | What |
|------|------|
| `modules/nixos/` | The NixOS module: `steamos.*` options, exported as `nixosModules.default` |
| `packages/` | `steamos-manager`, `decky-loader`, and the `deckyPlugins` scope, exposed via `overlays.default` |
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
