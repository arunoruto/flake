<a id="readme-top"></a>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/logo-dark.svg">
    <img src="docs/assets/logo.svg" alt="Steamix logo" width="160" height="160">
  </picture>

  <h1>Steamix</h1>

  <p>
    <strong>Your PC, as a Steam console you still own.</strong><br>
    Boot NixOS straight into Steam's Gaming Mode, switch to a desktop and back,
    and keep every change you make, with rollbacks when one goes wrong.
  </p>

  <p>
    <a href="https://github.com/arunoruto/flake/actions/workflows/steamix.yaml"><img src="https://github.com/arunoruto/flake/actions/workflows/steamix.yaml/badge.svg?branch=main" alt="VM tests"></a>
    <a href="https://steamix.cachix.org"><img src="https://img.shields.io/badge/cachix-steamix-5277c3?logo=nixos&logoColor=white" alt="Cachix: steamix"></a>
    <img src="https://img.shields.io/badge/NixOS-26.05%20%7C%20unstable-7ebae4?logo=nixos&logoColor=white" alt="NixOS 26.05 and unstable">
    <a href="../LICENSE"><img src="https://img.shields.io/badge/license-MIT-7c5cff" alt="MIT license"></a>
  </p>

  <p>
    <a href="https://arunoruto.github.io/flake/steamix/"><strong>Explore the docs »</strong></a>
    <br><br>
    <a href="https://arunoruto.github.io/flake/steamix/how-it-works.html">How it works</a>
    ·
    <a href="https://arunoruto.github.io/flake/steamix/options.html">Options</a>
    ·
    <a href="https://arunoruto.github.io/flake/steamix/roadmap.html">Roadmap</a>
    ·
    <a href="https://github.com/arunoruto/flake/issues">Report a bug</a>
  </p>
</div>

<details>
  <summary>Table of contents</summary>
  <ol>
    <li><a href="#about">About</a>
      <ul>
        <li><a href="#features">Features</a></li>
        <li><a href="#built-with">Built with</a></li>
      </ul>
    </li>
    <li><a href="#getting-started">Getting started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About

SteamOS makes a great console, but the console is Valve's, not yours: install
Tailscale and it is gone after the next update, and outside a handful of
devices it is not really an option. Steamix gives a NixOS machine the same
experience, with the machine still yours. It boots into Steam's **Gaming
Mode** (the gamescope-driven Deck UI), "Switch to Desktop" in Steam's power
menu drops into a regular desktop session, and an icon there brings you back.

Everything is configuration, so a change survives every update, and an update
that breaks something is one boot-menu entry away from being undone.

### Features

- **Gaming Mode modelled on Valve's session**: two Xwayland servers, the
  gamescope WSI layer, and the capability flags that make HDR, VRR, tearing
  and the performance overlay appear in Steam's menus.
- **Switch to Desktop and back**, through either a self-contained greetd loop
  or SDDM with SteamOS Manager, the way SteamOS itself does it. Rebooting or a
  crash always lands in Gaming Mode.
- **Living-room defaults**: HDR and VRR on, a performance overlay sized for
  the connected display, SteamOS' memory and network tuning.
- **Decky Loader with one option**, plugins declared in Nix or installed from
  the in-game store, side by side.
- **SteamOS Manager** for the controls Steam reaches through it, including
  TDP, GPU and performance profiles on the handhelds it recognises.
- **A binary cache** for everything nixpkgs does not build, so installs
  download instead of compiling.
- **VM-tested** end to end on NixOS 26.05 and unstable, on every change.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built with

- [NixOS](https://nixos.org)
- [Steam](https://store.steampowered.com) and
  [gamescope](https://github.com/ValveSoftware/gamescope)
- [SteamOS Manager](https://gitlab.steamos.cloud/holo/steamos-manager)
- [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting started

### Prerequisites

- A NixOS system with flakes enabled.
- A GPU with working Vulkan; gamescope needs it. AMD is the best-tested
  family, as it is what SteamOS runs on.
- A **Wayland** desktop session to switch to, such as GNOME or Plasma.
- Steam is unfree, so `nixpkgs.config.allowUnfree` (or an equivalent
  predicate) must allow it.

> [!IMPORTANT]
> With `steamix.autoStart`, the default, the machine logs `steamix.user` in
> **without a password**, console-style. Treat it like a game console, not a
> shared workstation.

### Installation

1. Add Steamix to your flake's inputs:

   ```nix
   inputs.steamix = {
     url = "github:arunoruto/flake?dir=steamix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. Import the module and its overlay, which provides SteamOS Manager and
   Decky Loader:

   ```nix
   imports = [ inputs.steamix.nixosModules.default ];
   nixpkgs.overlays = [ inputs.steamix.overlays.default ];
   ```

3. Turn it on:

   ```nix
   steamix = {
     enable = true;
     user = "alice";
     desktopSession = "plasma"; # any installed Wayland session
   };

   # The desktop itself comes from your own configuration.
   services.desktopManager.plasma6.enable = true;
   ```

4. Switch to the new configuration and reboot into Gaming Mode.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

Decky Loader with declarative plugins:

```nix
steamix.decky-loader = {
  enable = true;
  plugins = with pkgs.deckyPlugins; [
    hltb-for-deck
    protondb-decky
  ];
};
```

The SteamOS-shaped login path, where Steam switches sessions through SteamOS
Manager:

```nix
steamix.loginManager = "sddm";
```

Anything gamescope takes, one list element per argument:

```nix
steamix.gamescope.args = [ "--prefer-vk-device" "1002:7590" ];
```

HDR, VRR and the performance overlay need no configuration. For everything
else, see the [options tour](https://arunoruto.github.io/flake/steamix/options.html),
the generated [option reference](https://arunoruto.github.io/flake/steamix/reference/options.html),
and [hardware setup & tuning](https://arunoruto.github.io/flake/steamix/hardware-and-tuning.html).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Gaming Mode with Switch to Desktop, on greetd and on SDDM
- [x] Decky Loader with declarative plugins
- [x] VM tests in CI, on NixOS 26.05 and unstable
- [x] Binary cache
- [ ] OS updates from Gaming Mode's update button, with automatic rollback
- [ ] GPU selection from the nixos-facter hardware report
- [ ] Mods as Steam compatibility tools, starting with ModEngine3
- [ ] Heroic and emulators as entries in the Steam library
- [ ] Handheld support with Handheld Daemon
- [ ] A settings GUI for people who would rather not edit Nix
- [ ] ARM devices

The [full roadmap](https://arunoruto.github.io/flake/steamix/roadmap.html)
explains each item and the order they come in.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Steamix is incubating inside [arunoruto/flake](https://github.com/arunoruto/flake)
until it is stable, so issues and pull requests go there. The layout is
already the standalone one, so moving it to its own repository will only
change the input URL.

Before sending a change, run the VM tests, from the repository root:

```sh
nix build -L --no-write-lock-file --inputs-from . \
  --override-input nixpkgs nixpkgs ./steamix#checks.x86_64-linux.greetd
```

The tests are `greetd`, `sddm`, `steamos-manager` and `decky-loader`; the
[testing guide](https://arunoruto.github.io/flake/steamix/testing.html)
covers what each checks and how to run one interactively. Format with
`nix fmt`.

| Path | What |
|------|------|
| `modules/nixos/` | The NixOS module, exported as `nixosModules.default` |
| `packages/` | SteamOS Manager, Decky Loader and the `deckyPlugins` scope, exported as `overlays.default` |
| `tests/` | NixOS VM tests, exported as `checks.x86_64-linux.*` |
| `.github/workflows/` | CI, canonical copy; the repository root carries a checked byte-for-byte copy, since GitHub ignores symlinked workflows |
| `docs/` | The documentation, rendered as part of the parent repository's book for now |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License, the license of the repository Steamix
currently lives in. See [LICENSE](../LICENSE).

The logo's snowflake is derived from the
[NixOS logo](https://github.com/NixOS/nixos-artwork/tree/master/logo) by
Simon Frankau and Tim Cuthbertson, licensed
[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

- [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS), the
  original Steam Deck experience on NixOS, and the prior art for much of this
- [Valve](https://www.valvesoftware.com), for Steam, gamescope, SteamOS
  Manager and the Steam Deck that started it all
- [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader) and its
  plugin authors
- [Armada OS](https://github.com/armada-os/armada), for showing the way to
  Gaming Mode on ARM
- [nixos-facter](https://github.com/nix-community/nixos-facter) and
  [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- [Best-README-Template](https://github.com/othneildrew/Best-README-Template),
  for this README's shape

<p align="right">(<a href="#readme-top">back to top</a>)</p>
