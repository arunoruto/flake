# Boot into Gaming Mode the self-contained way: a greetd session loop instead
# of a display manager. Selected by steamos.loginManager = "greetd", the
# default; see ./sddm.nix for the SteamOS-shaped alternative.
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
    desktop_names="$(${pkgs.gnugrep}/bin/grep -m1 '^DesktopNames=' "$desktop_file" | ${pkgs.coreutils}/bin/cut -d= -f2- || true)"

    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP="$session"
    if [ -n "$desktop_names" ]; then
      export XDG_CURRENT_DESKTOP="$desktop_names"
    fi

    # Hand the session identity to the systemd user manager and to D-Bus
    # activation. A compositor started as a *user service* rather than as our
    # child inherits none of it otherwise, and GNOME's shell unit gates on it
    # (`AssertEnvironment=XDG_SESSION_TYPE=wayland`) before it will even run.
    # The logind session itself is made to match further down, in the pam_env
    # rule — both halves are needed.
    identity=""
    for var in XDG_SESSION_ID XDG_SESSION_TYPE XDG_SESSION_DESKTOP \
               XDG_CURRENT_DESKTOP XDG_SEAT XDG_VTNR; do
      if [ -n "''${!var:-}" ]; then
        identity="$identity $var"
      fi
    done
    # shellcheck disable=SC2086
    ${pkgs.systemd}/bin/systemctl --user import-environment $identity || true
    # shellcheck disable=SC2086
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd $identity || true

    # Send the session's output to the journal rather than to the VT.
    #
    # greetd hands its child the console, so by default everything the session
    # prints — gamescope's startup, its errors, a compositor's death rattle —
    # lands on whichever display owns fbcon. That is the wrong place twice
    # over: it is invisible unless something is plugged into the GPU that
    # happens to hold the framebuffer console (not necessarily the one the
    # session renders on), and it is unreachable over SSH, so a session that
    # fails to start leaves a black screen and no way to ask why. In the
    # journal it is `journalctl -t steamos-session` from anywhere.
    #
    # systemd-cat execs the session rather than forking it, so greetd still
    # sees exactly one child and its session bookkeeping is unchanged.
    eval "exec ${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=steamos-session -- $exec_line"
  '';
in
{
  config = lib.mkIf (cfg.enable && cfg.autoStart && cfg.loginManager == "greetd") {
    services.greetd = {
      enable = true;
      # No initial_session: default_session *is* the autologin, so the loop
      # also covers relogin after "Switch to Desktop" / logout.
      settings.default_session = {
        command = lib.getExe steamos-session;
        inherit (cfg) user;
      };
    };

    # Tell logind what kind of session this is, before it creates one.
    #
    # greetd never sets XDG_SESSION_TYPE at all, and marks its sessions
    # XDG_SESSION_CLASS=greeter — reasonable for a greeter, wrong for us,
    # because occupying the greeter slot is exactly how this module gets its
    # respawn loop. logind therefore registers every session as
    # `class=greeter type=tty`, and that is what Desktop Mode trips over:
    # GNOME's shell unit carries `AssertEnvironment=XDG_SESSION_TYPE=wayland`,
    # a `type=tty` session is never eligible to be the user's logind *display*
    # session, and mutter refuses to start without one it can resolve.
    # gamescope hides the problem in Gaming Mode by promoting the session type
    # itself once it holds the DRM device, which a desktop compositor does
    # not do.
    #
    # pam_env runs well before pam_systemd in the stack, so setting the two
    # variables there means the session is created correctly rather than
    # corrected afterwards.
    security.pam.services.greetd.rules.session.steamos-session-identity = {
      order = config.security.pam.services.greetd.rules.session.env.order + 1;
      control = "optional";
      modulePath = "${pkgs.linux-pam}/lib/security/pam_env.so";
      args = [
        "conffile=${pkgs.writeText "steamos-greetd-pam-environment" ''
          XDG_SESSION_TYPE DEFAULT=wayland OVERRIDE=wayland
          XDG_SESSION_CLASS DEFAULT=user OVERRIDE=user
        ''}"
        "readenv=0"
      ];
    };
  };
}
