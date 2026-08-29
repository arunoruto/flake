# Boot into Gaming Mode the way SteamOS does: SDDM autologin, with session
# switching handled by SteamOS Manager. Selected by
# steamos.loginManager = "sddm"; see ./autostart.nix for the greetd default.
#
# The appeal over greetd is that nothing has to be corrected afterwards. SDDM
# registers a logind session of class `user` and type `wayland` on its own, so
# the pam_env rule the greetd path needs does not exist here, and Valve's
# software finds the shape it expects.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos;
  enabled = cfg.enable && cfg.autoStart && cfg.loginManager == "sddm";
in
{
  config = lib.mkIf enabled {
    services.displayManager = {
      # Gaming Mode is registered under Valve's session name as well as our
      # own; SteamOS Manager asks for "gamescope-wayland.desktop" by name when
      # Steam requests game mode, and it is not configurable.
      # See ./gaming-mode.nix for where that alias is registered.
      defaultSession = "gamescope-wayland";

      autoLogin = {
        enable = true;
        inherit (cfg) user;
      };

      sddm = {
        enable = true;
        # Valve runs the X11 greeter, but the closure is much smaller this way
        # and on an autologin machine the greeter should never be seen.
        wayland.enable = true;
        # This is the respawn loop: log back in when a session ends, so
        # quitting Steam or logging out of the desktop lands in Gaming Mode
        # again rather than at a greeter.
        autoLogin.relogin = true;
      };
    };

    # SteamOS Manager is what actually performs the switch, by writing an
    # autologin drop-in into /etc/sddm.conf.d and ending the session.
    steamos.manager.enable = true;

    # Vendor failsafe: a stale temporary session config would otherwise pin the
    # machine to a session that no longer starts, with no way back in.
    systemd.services.display-manager.serviceConfig.ExecStartPre = [
      "-${pkgs.coreutils}/bin/rm /etc/sddm.conf.d/zzt-holo-temp-login.conf"
      "-${pkgs.coreutils}/bin/rm /etc/sddm.conf.d/zzt-steamos-temp-login.conf"
    ];

    # Tell the manager which session "Switch to Desktop" means. Steam
    # occasionally overwrites this, so it is reasserted for every session
    # rather than set once.
    systemd.user.services.steamos-set-desktop-session = lib.mkIf (cfg.desktopSession != null) {
      description = "Point SteamOS Manager at the configured desktop session";
      wants = [ "steamos-manager.service" ];
      after = [ "steamos-manager.service" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe cfg.manager.package} set-default-desktop-session ${cfg.desktopSession}.desktop";
      };
    };
  };
}
