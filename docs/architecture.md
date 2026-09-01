# Architecture

This page is the map of the repository: what lives where, how a host gets built,
and where to start when adding something new.

## Directory layout

| Path | Purpose |
|------|---------|
| `flake.nix` | Inputs and output wiring. Host/user discovery is delegated to `systems/` and `homes/`. |
| `systems/<arch>/<host>/` | One directory per host, auto-discovered. The directory name **is** the hostname. |
| `systems/iso/` | Installer ISO definition and the list of hosts that get an `iso-*` image. |
| `modules/nixos/` | NixOS modules (desktop, services, system, security, users, …). |
| `modules/darwin/` | nix-darwin modules (homebrew, services, system, users). |
| `modules/home-manager/` | Home Manager modules — the largest tree, see [background vs foreground](#background-vs-foreground). |
| `modules/devix/` | Development-environment *mechanism*: a registry of languages, addons, LSPs, and formatters consumed by editors (helix, zed, opencode). Exposed as `homeModules.devix` and `devenvModules.*`. See [devix](#devix). |
| `steamos/` | Steam-machine *mechanism* as its own in-repo flake: boot into Steam's Gaming Mode with a switchable Desktop Mode, without Jovian. Consumed as a relative-path input (`inputs.nixpkgs.follows`), re-exported as `nixosModules.steamos`; carries its own packages and docs. See [steamos](./steamos/README.md). |
| `homes/<user>/` | Per-user Home Manager entry points, auto-discovered for standalone `homeConfigurations`. SSH public keys live in `homes/<user>/keys/`. |
| `lib/` | Small helper library layered onto `nixpkgs.lib` (directory listing, tag predicate, `eachSystem`). |
| `overlays/` | Nixpkgs overlays: custom packages, modifications, `pkgs.unstable`, … |
| `packages/` | Custom packages: `top-level/` (auto-discovered), `custom/` (namespaced under `pkgs.custom`), plus python/kodi/home-assistant scopes and the `docs` book. |
| `shells/` | Dev shells (`nix develop .#go`, `.#website`, `.#nix`). |
| `secrets/` | sops-encrypted secrets. Recipients (age keys per user and host) are declared in `secrets/.sops.yaml`. |
| `scripts/` | Repo tooling (package bump script, CI checks) — driven via the `justfile`. |
| `docs/` | This mdBook. Published via GitHub Pages, buildable with `nix build .#docs`. |
| `justfile` | Task runner: `just --list` shows all daily commands. |

## How a host is built

```text
flake.nix
  └─ systems/default.nix          scans systems/<arch>/ for host directories
       ├─ arch contains "darwin"? ─ nix-darwin's darwinSystem
       │    └─ modules/darwin + home-manager + stylix + sops + homes/nixos.nix
       └─ otherwise ─────────────── lib.nixosSystem
            └─ modules/nixos + home-manager + facter + homes/nixos.nix
                 └─ homes/nixos.nix instantiates home-manager for
                    homes.users (default: the primary user), each importing
                    homes/<user>/ + modules/home-manager
```

- `networking.hostName` is forced to the directory name.
- A `facter.json` in the host directory is picked up automatically (hardware detection via nixos-facter).
- A `nixpkgs.nix` in the host directory supplies per-host nixpkgs `config`, merged
  over the shared one. This is the only way to set it: `pkgs` is instantiated in
  `systems/default.nix` outside the module system, so a host cannot use
  `nixpkgs.config` in its `configuration.nix` (the nixpkgs module rejects it).
  See `systems/x86_64-linux/kyuubi/nixpkgs.nix`, which permits an insecure
  Broadcom wifi driver for that host alone.
- `users.primaryUser` **must** be set in every host config; the user account itself comes from `modules/nixos/users/` (or `modules/darwin/users/`).
- Standalone `homeConfigurations.<user>` (for non-NixOS machines) are generated from the `homes/<user>/` directories, independent of any host.

## The tag system

Hosts describe themselves with a list of tags instead of toggling dozens of options:

```nix
# systems/x86_64-linux/madara/configuration.nix
system.tags = [ "desktop" "workstation" "development" "management" ];
```

- The known tags are enumerated in `modules/shared/tags.nix` — the option type
  rejects anything else at eval time, so a typo or a tag without consumers
  cannot slip in silently. Current tags: `desktop`, `laptop`, `workstation`,
  `development`, `management`, `nas`, `gaming`, `server` (each with a one-line
  meaning in that file).
- Modules query tags through `config.lib.tags.hasTag "<tag>"` (the predicate lives
  in `lib/has-tag.nix`; the option is declared under `modules/{nixos,darwin}/system/tags/`).
- Tag modules under `modules/{nixos,darwin}/system/tags/` translate tags into
  concrete settings (e.g. `desktop` enables the desktop environment stack,
  `management` installs colmena, `gaming` enables Steam). Server *roles* key on
  the `server` tag — tailscale exit-node/connector/SSH advertising and the
  no-sound-stack default — never on the *absence* of an interactive tag: a
  workstation or laptop without `desktop` is still somebody's machine.
- Colmena reuses the same tags for deployment targeting:
  `colmena apply --on @desktop` (wired via `colmena.deployment.tags`).
- Home Manager cannot read `config.lib.tags` without infinite recursion, so
  `modules/home-manager/imports.nix` imports the predicate directly against
  `osConfig` and maps tags onto its own `hosts.{desktop,laptop,workstation,development}.enable`
  options. Inside home-manager modules, gate on `config.hosts.*.enable`.

## Background vs foreground

`modules/home-manager/` is split by *session type*, not by program category:

- **`background/`** — everything that works on a headless machine or over SSH:
  shell, git, editors, CLI tools, AI tooling, user services. Imported
  unconditionally.
- **`foreground/`** — everything that needs a display: desktop environments,
  bars, GUI programs, fonts-for-GUI. Gated behind `foreground.enable`, which
  defaults from the `desktop` tag (darwin), the `gui.enable` option
  (NixOS), or `true` (standalone home-manager).
- **`theming/`** — stylix wiring, wallpaper, color scheme; enabled with the
  `desktop` tag.
- **`development/`** — *policy*: which languages/tools from `modules/devix`
  (the mechanism) are turned on for `development`-tagged hosts.

## devix

Development-environment *mechanism*: describe a language once — its language
servers, formatters and indentation — and every editor that consumes the
description configures itself from it. Stylix's idea, applied to dev tooling.

It is documented in its own section, starting at [devix](./devix/README.md):
[concepts](./devix/concepts.md), [usage](./devix/usage.md),
[adding a language](./devix/adding-a-language.md),
[adding an editor](./devix/adding-an-editor.md), and a generated
[support matrix](./devix/reference/support-matrix.md) and option reference.

The one thing worth repeating here is the split this repository depends on:
`modules/devix` is pure mechanism and enables nothing, while
`modules/home-manager/development/` is the policy that decides which languages
are on for which hosts.

## Adding a host

1. Create `systems/<arch>/<hostname>/default.nix` (plus `configuration.nix`,
   `hardware-configuration.nix` or `facter.json`, and optionally `disk.nix` for
   disko). The directory is discovered automatically.
2. Set `users.primaryUser` and `system.tags` in the config.
3. Add the host's age key to `secrets/.sops.yaml` and re-encrypt:
   `just secrets-rekey` (key comes from the host's SSH key, see [sops](./sops.md)).
4. For colmena deploys, set `colmena.deployment.targetHost`.
5. If the host should get an installer image, add it to the list in
   `systems/iso/default.nix` — then `just iso <hostname>`.

## Adding a user

1. Create `homes/<user>/default.nix` (auto-discovered as
   `homeConfigurations.<user>`); put SSH public keys in `homes/<user>/keys/`.
2. Create `modules/nixos/users/<user>.nix` (auto-imported; see `mirza.nix` for
   the pattern).
3. Set `users.primaryUser = "<user>"` on the hosts that belong to them, and add
   their age key to `secrets/.sops.yaml`.

## Custom options cheat sheet

Options defined by this flake (as opposed to upstream NixOS/HM options):

| Option | Defined in | Meaning |
|--------|-----------|---------|
| `system.tags` | `modules/{nixos,darwin}/system/tags/` | Host capability tags (see above) |
| `users.primaryUser` | `modules/{nixos,darwin}/users/` | The one human this machine belongs to |
| `users.users.<u>.isAdmin` | `modules/nixos/users/` | wheel + virtualisation groups |
| `homes.users` / `homes.enable` | `homes/nixos.nix` | Which users get home-manager |
| `gui.enable` | `modules/nixos/programs/` | "This host has GUI applications" (feeds `foreground.enable`) |
| `desktop-environment.enable` | `modules/nixos/desktop/` | Desktop environment stack |
| `hosts.{desktop,laptop,workstation,development}.enable` | `modules/home-manager/imports.nix` | HM-side mirror of the tags |
| `devix.*` | `modules/devix/` | Development environments — see the [devix](./devix/README.md) section |
| `steamos.*` | `steamos/modules/nixos/` | Steam-machine mode — see the [steamos](./steamos/README.md) section |
| `facter.hardwareProfiles` | `systems/hardware-profiles.nix` | Read-only: which nixos-hardware `common/` profiles this host's facter report selected |
| `foreground.enable` | `modules/home-manager/foreground/` | GUI-facing home config |
| `theming.{enable,scheme,image}` | `modules/home-manager/theming/`, `modules/nixos/system/theming.nix` | Stylix scheme/wallpaper |
| `rssh.enable`, `yubikey.enable`, `cachix.enable`, `latex.enable` | `modules/nixos/**` | Feature toggles for individual services |

NAS behaviour follows the `nas` tag, and the TPM2 stack is driven by the
upstream `security.tpm2.enable` (this flake just layers PKCS11/tooling on top).

New custom options should be namespaced (or documented here) so they stay
distinguishable from upstream options.
