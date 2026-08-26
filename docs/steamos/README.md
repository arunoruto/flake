# steamos

`modules/steamos/` turns a NixOS machine into a Steam machine: it boots
straight into Steam's **Gaming Mode** (the gamescope-driven Deck UI), and the
"Switch to Desktop" button in Steam's power menu drops you into a regular
desktop session — with an icon there to return to Gaming Mode, just like
SteamOS.

It is deliberately *not* [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS).
Jovian ships Valve's full stack (steamos-manager, powerbuttond, vendor
gamescope-session, Deck hardware support) and is the right choice for an
actual Steam Deck. This module instead composes what nixpkgs already
provides — `programs.steam.gamescopeSession` and `greetd` — with two small
scripts, and is aimed at ordinary PCs used as living-room machines.

## Split-ready

Like [devix](../devix/README.md), this tree is mechanism only and written to
be usable outside this flake (and eventually to move into its own repository,
`steamos.nix`):

- it only touches plain `pkgs`, plain `lib`, and upstream NixOS options — no
  repo overlays (`pkgs.unstable`), no extended `lib`, no tag system;
- it is exported as `nixosModules.steamos`;
- all policy (which host, which user, which desktop session) stays with the
  consumer. In this repo that is the adapter
  `modules/nixos/programs/gaming/steamos.nix`, which defaults
  `steamos.user` to `users.primaryUser` and turns the display manager off
  when the module owns the login path.

## Usage

In this repo (see `systems/x86_64-linux/yhwach/` for the worked example):

```nix
{
  system.tags = [ "desktop" "gaming" ]; # desktop stack + steam defaults

  steamos = {
    enable = true;
    desktopSession = "gnome"; # any installed wayland session name
  };
}
```

From another flake:

```nix
{
  inputs.mar-flake.url = "github:arunoruto/flake";

  # in a NixOS configuration:
  imports = [ inputs.mar-flake.nixosModules.steamos ];

  config = {
    steamos = {
      enable = true;
      user = "alice";
      desktopSession = "plasma";
    };
    # the desktop session itself still comes from your own config:
    services.desktopManager.plasma6.enable = true;
  };
}
```

Requirements and expectations:

- A GPU with working Vulkan (gamescope requires it). AMD is the best-tested
  family for gamescope — it is what SteamOS runs on.
- The desktop session must be a **Wayland** session; X11 sessions are out of
  scope.
- `steamos.autoStart` (the default) logs `steamos.user` in **without a
  password prompt**, console-style — treat the machine like a game console,
  not a multi-user workstation. Screen lockers of the desktop session still
  work once switched.
- Steam itself is unfree; `nixpkgs.config.allowUnfree` (or an equivalent
  predicate) must permit it.

Gamescope flags (resolution, refresh rate, HDR, …) are configured through the
upstream options, e.g.:

```nix
programs.steam.gamescopeSession.args = [
  "--output-width 3840"
  "--output-height 2160"
  "--hdr-enabled"
];
```

See [How it works](./how-it-works.md) for the mechanism and its failure
modes, [Options](./options.md) for the reference, and
[Hardware setup & tuning](./hardware-and-tuning.md) for the checklist that
makes the machine actually good — nixos-facter, nixos-hardware, gamescope
display tuning, controllers.
