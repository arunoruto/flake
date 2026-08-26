# steamos.nix — a self-configured Steam-machine module: boot straight into
# Steam's Gaming Mode (gamescope) with an optional Desktop Mode to switch to,
# without pulling in the full Jovian/steamos-manager stack.
#
# This tree is written to be reusable outside this flake (and eventually split
# into its own repository): it only uses plain `pkgs`, plain `lib`, and
# upstream NixOS options — no repo overlays (`pkgs.unstable`), no extended
# `lib`, no tag system. Policy (which host enables it, which user, which
# desktop session) lives with the consumer; see modules/nixos/programs/gaming/
# for this flake's adapter.
#
# Documentation: docs/steamos/ (README, how-it-works, options).
{ config, lib, ... }:
let
  cfg = config.steamos;
in
{
  imports = [
    ./session.nix
    ./autostart.nix
  ];

  options.steamos = {
    enable = lib.mkEnableOption "the SteamOS-like Gaming Mode experience";

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "alice";
      description = ''
        The user the Gaming Mode session runs as. Required when
        {option}`steamos.autoStart` is enabled — the machine logs this user
        in without a password prompt, console-style.
      '';
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Boot straight into Gaming Mode. This owns the login path with a
        greetd session loop, so it cannot be combined with a regular
        display manager (GDM/SDDM/...). Disable it to merely register the
        "Steam" session with whatever display manager you already run.
      '';
    };

    desktopSession = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "gnome";
      description = ''
        Name of the Wayland session started by "Switch to Desktop" in
        Gaming Mode (a session name from
        {option}`services.displayManager.sessionData.sessionNames`, i.e.
        the basename of a `wayland-sessions/*.desktop` file). When `null`,
        switching to the desktop relaunches Gaming Mode.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.autoStart -> cfg.user != null;
        message = "steamos.autoStart needs steamos.user to know who to log in as.";
      }
      {
        assertion =
          cfg.desktopSession == null
          || lib.elem cfg.desktopSession config.services.displayManager.sessionData.sessionNames;
        message = ''
          steamos.desktopSession "${toString cfg.desktopSession}" is not an installed session.
          Valid session names are:
            ${lib.concatStringsSep "\n  " config.services.displayManager.sessionData.sessionNames}
        '';
      }
    ];

    warnings = lib.optional (cfg.autoStart && cfg.desktopSession == null) ''
      steamos.desktopSession is unset: "Switch to Desktop" in Gaming Mode will
      relaunch Gaming Mode. Set it to a session name (e.g. "gnome" or "plasma")
      to get a Desktop Mode.
    '';
  };
}
