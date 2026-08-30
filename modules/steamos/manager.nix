# SteamOS Manager: the system daemon Steam queries for OS-level features it
# cannot reach itself — TDP and GPU performance limits, CPU scaling, storage
# formatting. Steam probes the interface at startup and shows only the settings
# the daemon can actually back.
#
# Off by default, and worth reading the warning below before turning it on:
# upstream's session management assumes SDDM, so enabling this on a greetd
# login path trades a working "Switch to Desktop" for the performance controls.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos.manager;
  enabled = config.steamos.enable && cfg.enable && cfg.package != null;

  # With no state file the manager's "Switch to Desktop" falls back to
  # plasma.desktop, which only exists on Valve's image; SDDM then cannot
  # find the session and drops back into Gaming Mode. Seed the state with
  # the configured desktop session instead. Only desktop_session is set:
  # the remaining fields carry usable serde defaults, and the login-mode
  # enum serializes differently from what its TOML name suggests.
  seedState = pkgs.writeText "steamos-manager-state.toml" ''
    [session_manager]
    desktop_session = "${config.steamos.desktopSession}.desktop"
  '';
in
{
  options.steamos.manager = {
    enable = lib.mkEnableOption "SteamOS Manager, the OS-integration daemon Steam talks to";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.steamos-manager or null;
      defaultText = lib.literalExpression "pkgs.steamos-manager or null";
      description = ''
        The SteamOS Manager package, or `null` when none is available.

        nixpkgs does not package it, so this is `null` unless an overlay
        provides `pkgs.steamos-manager`; the module then does nothing and warns
        rather than failing to evaluate.
      '';
    };
  };

  config = lib.mkMerge [
    {
      warnings =
        lib.optional (config.steamos.enable && cfg.enable && cfg.package == null) ''
          steamos.manager.enable is on but no SteamOS Manager package is
          available, so nothing was configured. nixpkgs does not ship one; set
          steamos.manager.package or provide pkgs.steamos-manager through an
          overlay.
        ''
        ++ lib.optional (enabled && config.steamos.autoStart && config.steamos.loginManager == "greetd") ''
          steamos.manager.enable is on while steamos.loginManager is
          "greetd", and those two disagree about how sessions are switched.

          SteamOS Manager advertises the SessionManagement1 interface,
          which Steam prefers over the steamos-session-select script the
          greetd path ships. It switches sessions by writing an SDDM
          autologin drop-in to /etc/sddm.conf.d and stopping
          graphical-session.target, and it asks for
          "gamescope-wayland.desktop" by name where that path registers
          "steam". Nothing reads either under greetd, so "Switch to
          Desktop" would drop back into Gaming Mode.

          Either set steamos.loginManager = "sddm", which wires the two up
          together, or leave the manager off.
        '';
    }

    (lib.mkIf enabled {
      environment.systemPackages = [ cfg.package ];
      services.dbus.packages = [ cfg.package ];

      systemd = {
        packages = [ cfg.package ];

        # Upstream ships the system daemon D-Bus-activated, but Steam expects
        # it to already be running when it probes at startup.
        services.steamos-manager = {
          overrideStrategy = "asDropin";
          wantedBy = [ "multi-user.target" ];
        };

        # The user daemon is the half that exposes the public interface, and it
        # only makes sense once there is a graphical session to serve.
        user.services.steamos-manager = {
          overrideStrategy = "asDropin";
          wantedBy = [ "graphical-session.target" ];
        };
      };
    })

    (lib.mkIf (enabled && config.steamos.desktopSession != null) {
      # `C` copies only when the file is absent, so a session later chosen
      # over D-Bus (SetDefaultDesktopSession) is not overwritten on boot.
      systemd.user.tmpfiles.users.${config.steamos.user}.rules = [
        "d %h/.config/steamos-manager 0755 - - -"
        "C %h/.config/steamos-manager/state.toml 0644 - - - ${seedState}"
      ];
    })
  ];
}
