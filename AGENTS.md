# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single flake managing NixOS, nix-darwin, and standalone Home Manager configurations, plus custom packages, overlays, dev shells, and an mdBook docs site (`docs/`, start with `docs/architecture.md`).

## Commands

Day-to-day commands are `just` recipes; `just` lives in the `nix` dev shell (`nix develop .#nix`), which also installs the git hooks.

```sh
just switch                 # build + activate this host (nh os switch)
just home [user]            # switch a user's home-manager config
just fmt                    # nix fmt (nixfmt-tree)
just check                  # nix flake check --accept-flake-config
just eval-all               # evaluate every nixos/darwin/home config (catches eval errors)
just deploy --on <host>     # colmena deploy (management-tagged hosts)
just bump packages/top-level/<pkg>   # nix-update a custom package
just docs                   # serve mdBook docs with live reload
just iso <host>             # build installer ISO for a host
just secrets                # sops edit secrets/secrets.yaml
```

Evaluate/build a single configuration (the closest thing to "running one test"):

```sh
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix eval .#homeConfigurations.<user>.activationPackage.drvPath
```

Custom packages live under `legacyPackages`: `nix build .#<pkg>` (top-level) or `nix build .#custom.<pkg>`.

## Hard rules enforced by hooks / CI

- **Never commit `flake.lock`** — it is bumped only by the scheduled Update Lockfile GitHub action; a pre-commit hook (`scripts/block-lockfile-commit.sh`) rejects local commits touching it.
- **New `packages/**/package.nix` files must set `__structuredAttrs = true;` and `strictDeps = true;`** (`scripts/check-new-packages.sh`). Existing packages are grandfathered.
- Formatting (`nixfmt`) is CI-enforced via `nix flake check`. `statix`/`deadnix` run as local commit hooks only and never fail CI.
- Every configuration must at least evaluate. CI (`.github/workflows/check.yaml`) runs `nix flake check`; `just eval-all` walks every nixos/darwin/home config locally. Nothing *builds* the configurations in CI, so a config that evaluates but fails to build only surfaces on `just switch` / `just deploy`.

## Conventions (not hook-enforced)

- **Platform checks go through `hostPlatform`**: write `stdenv.hostPlatform.isLinux` / `.isDarwin` / `.isx86_64` — the bare `stdenv.isLinux` forms are deprecated in nixpkgs and emit evaluation warnings. The tree was swept clean of them (2026-08); don't reintroduce one.

## Architecture

### Host/user auto-discovery

- `systems/<arch>/<host>/` — one directory per host; the directory name **is** the hostname (forced via `networking.hostName`). `systems/default.nix` scans arch dirs and builds `darwinSystem` or `nixosSystem` accordingly. A `facter.json` in the host dir is picked up automatically for hardware config — and mapped onto nixos-hardware `common/` tuning profiles by `systems/hardware-profiles.nix` (CPU generation, amd-pstate, fstrim; inspect via `config.facter.hardwareProfiles`) — and an optional `nixpkgs.nix` supplies per-host nixpkgs `config` (see below).
- **`nixpkgs.config` cannot be set from a host module** — `pkgs` is instantiated in `systems/default.nix` outside the module system, and the nixpkgs module asserts against it. A host needing its own `permittedInsecurePackages`, `cudaSupport`, etc. drops a `nixpkgs.nix` next to its `configuration.nix`; those attributes are merged over the shared config for that host only (`systems/x86_64-linux/kyuubi/nixpkgs.nix` is the worked example).
- `homes/<user>/` — auto-discovered as standalone `homeConfigurations.<user>`; `homes/nixos.nix` also instantiates home-manager inside every NixOS/darwin host for `homes.users` (default: the `users.primaryUser`, which every host must set).
- `systems/iso/` — installer image definitions; hosts listed there get an `iso-<host>` output.

### The tag system

Hosts self-describe with `system.tags = [ "desktop" "workstation" "development" "management" ... ]` instead of many toggles. The known tags are enumerated (with their meanings) in `modules/shared/tags.nix`; the option type is an enum, so an unknown tag is an eval error — extend that list when adding a tag. NixOS/darwin modules query `config.lib.tags.hasTag "<tag>"` (predicate in `lib/has-tag.nix`, option in `modules/{nixos,darwin}/system/tags/`); tag modules there translate tags into concrete settings. The baseline for untagged hosts is deliberately slim. Colmena reuses the same tags for deploy targeting (`colmena apply --on @<tag>`).

Home Manager modules **cannot** read `config.lib.tags` (infinite recursion); `modules/home-manager/imports.nix` maps the OS tags onto `hosts.{desktop,laptop,workstation,development}.enable`, so inside HM modules gate on `config.hosts.*.enable`.

### Home Manager split: background vs foreground

`modules/home-manager/` is split by session type, not program category:

- `background/` — headless/SSH-safe (shell, git, editors, CLI, AI tooling, user services); imported unconditionally.
- `foreground/` — needs a display; gated behind `foreground.enable` (defaults from `gui.enable` on NixOS, `desktop` tag on darwin, `true` standalone).
- `theming/` — stylix/wallpaper/scheme (scheme + wallpaper are chosen in `flake.nix`).
- `development/` — *policy*: which languages/tools from `modules/devix` get enabled on `development`-tagged hosts.

### devix

`modules/devix/` is the development-environment *mechanism*: a registry of languages, LSPs, and formatters consumed by editors (helix, zed, opencode). Exposed as `homeModules.devix` and `devenvModules.*` for reuse outside this flake. The old home-manager helix config is kept on purpose as a reference — don't delete it.

Everything inside is auto-discovered, so there are no import lists to keep in sync:

- `languages/<lang>.nix` — one file per language, pure data (LSPs, formatters, indentation, `consumerMeta`). `languages/default.nix` finds them and `core/mkLanguage.nix` turns each into a `devix.languages.<lang>` option. Adding a language is adding that one file.
- `addons/<addon>.nix` — one file per *addon*: a group of servers that is not a language of its own (grammar checking, AI completion). An addon attaches its `lspServers` to the languages it names (`"*"` for all) instead of pretending to be a language. `core/mkAddon.nix` turns each into `devix.addons.<addon>`.
- `consumers/<name>/` — one directory per editor/tool, holding `default.nix` (registry entry: `capability`, `metaOptions`, `activeWhen`, `editorCommand`, adapter paths), `transform.nix` (pure data → that tool's config format), `home.nix` (Home Manager adapter) and optionally `devenv.nix`. `consumers/registry.nix` discovers them and derives the consumer list, the exposure toggles, the `defaultEditor` enum, the EDITOR/VISUAL map, and the adapter lists that *both* targets assemble themselves from.
- `core/` — the option schema; `targets/home/` — the Home Manager wiring shared by all consumers.

Two things gate what a consumer sees, and `consumers/registry.nix` applies **both** — adapters and transforms must not re-implement either:

- *exposure* — `consumers.<name>.enable` toggles present on every LSP, formatter, language and addon, all defaulting to `true`.
- *capability* — each consumer declares `capability = "all"` (configures languages generically, like Helix) or `"meta"` (only languages carrying `consumerMeta.<name>`, like Zed and OpenCode). A `"meta"` consumer also supplies `metaOptions`, which types its slice of `consumerMeta` — so a typo or wrong type in a language's metadata is a build error rather than silently ignored.

Two more rules that keep devix reusable outside this flake:

- **No `pkgs.unstable` (or any overlay of ours) in `languages/` and `addons/`.** They take plain `pkgs`, so `homeModules.devix` evaluates against a bare nixpkgs. "Use the unstable build" is policy: `devix.lsps.nixd.package = pkgs.unstable.nixd;` in `modules/home-manager/development/`. An LSP's `command` is derived from its `package`, so overriding the package is enough — only set `command` explicitly when the binary is not the package's main program (`lib.getExe'` cases).
- devix must not use the repo's extended `lib` (it runs under home-manager and is exported standalone) — use `builtins.readDir` / `lib.filterAttrs` directly.

Options were renamed from `development.*` to `devix.*` (and `autoConfigureEditors` to `autoEnable`); `core/renames.nix` generates back-compat aliases that warn.

### Custom lib

`lib/` extends `nixpkgs.lib` (via `lib.extend`) with `getDirectories`, `eachSystem`, `arr`, `networking`, and `hasTag` helpers. The extended lib reaches NixOS module evaluation (passed as the module system's `lib`), but **not** home-manager or darwin modules — don't assume `lib.getDirectories` etc. exist there.

### Packages

`packages/default.nix` builds a `makeScope`: `top-level/` is auto-discovered via `packagesFromDirectoryRecursive`, `custom/` is namespaced under `pkgs.custom`, plus `python3Packages/`, `kodiPackages/`, and `home-assistant-custom-components/` scopes layered onto their nixpkgs counterparts. Overlays in `overlays/` expose these as `pkgs.<name>` / `pkgs.custom.<name>` and provide `pkgs.unstable`.

### Adding a host / user

See `docs/architecture.md` for the step-by-step; the short version: create the auto-discovered directory, set `users.primaryUser` + `system.tags`, add the age key to `secrets/.sops.yaml` and `just secrets-rekey`.

## Custom options cheat sheet

| Option | Meaning |
|--------|---------|
| `system.tags` | Host capability tags |
| `users.primaryUser` | The one human this machine belongs to (required per host) |
| `users.users.<u>.isAdmin` | wheel + virtualisation groups |
| `homes.users` / `homes.enable` | Which users get home-manager |
| `gui.enable` | NixOS: host has GUI apps (feeds `foreground.enable`) |
| `hosts.{desktop,laptop,workstation,development}.enable` | HM-side mirror of the tags |
| `foreground.enable` | GUI-facing home config |
| `theming.{enable,scheme,image}` | Stylix scheme/wallpaper |

New custom options should be namespaced or documented in `docs/architecture.md`.
