# Boot into Gaming Mode: a greetd session loop instead of a display manager.
#
# greetd's `default_session` is (ab)used kiosk-style: it runs the launcher
# below as the configured user, and respawns it whenever the session ends.
# The launcher does what a display manager would do — resolve a session's
# .desktop file, export the session identity variables, exec its command —
# picking Gaming Mode unless a one-shot selection was left behind by
# `steamos-session-select` (see ./session.nix). Rebooting or logging out of
# the desktop therefore always lands back in Gaming Mode, like SteamOS.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos;

  # Every session registered via services.displayManager.sessionPackages
  # (the steam session, GNOME, Plasma, ...) collected in one directory.
  sessionsDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";

  steamos-session = pkgs.writeShellScriptBin "steamos-session" ''
    set -eu

    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
    select_file="$state_dir/steamos-session-select"

    # Consume-once: a selection applies to exactly one login cycle.
    session="steam"
    if [ -r "$select_file" ]; then
      session="$(cat "$select_file")"
      rm -f "$select_file"
    fi

    desktop_file="${sessionsDir}/$session.desktop"
    if ! [ -r "$desktop_file" ]; then
      echo "steamos-session: no wayland session '$session', falling back to Gaming Mode" >&2
      # Do not hot-loop greetd if even the fallback cannot start.
      sleep 2
      session="steam"
      desktop_file="${sessionsDir}/steam.desktop"
    fi

    exec_line="$(${pkgs.gnugrep}/bin/grep -m1 '^Exec=' "$desktop_file" | ${pkgs.coreutils}/bin/cut -d= -f2-)"
    desktop_names="$(${pkgs.gnugrep}/bin/grep -m1 '^DesktopNames=' "$desktop_file" | ${pkgs.coreutils}/bin/cut -d= -f2-)"

    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP="$session"
    if [ -n "$desktop_names" ]; then
      export XDG_CURRENT_DESKTOP="$desktop_names"
    fi

    eval "exec $exec_line"
  '';
in
{
  config = lib.mkIf (cfg.enable && cfg.autoStart) {
    services.greetd = {
      enable = true;
      # No initial_session: default_session *is* the autologin, so the loop
      # also covers relogin after "Switch to Desktop" / logout.
      settings.default_session = {
        command = lib.getExe steamos-session;
        inherit (cfg) user;
      };
    };
  };
}
