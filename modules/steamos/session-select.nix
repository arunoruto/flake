# The SteamOS-compatible session switcher: "Switch to Desktop" in Gaming Mode,
# and the icon on the desktop that brings you back.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos;

  # The Steam client hardcodes invocations of `steamos-session-select` for the
  # "Switch to Desktop" button in Gaming Mode (historically with Valve's KDE
  # session names as the argument), so the binary name and the accepted
  # arguments follow Valve's script. Selection is written to a state file that
  # the login loop (see ./autostart.nix) consumes exactly once.
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    set -eu

    request="''${1:-gamescope}"

    case "$request" in
      gamescope | steam)
        target="steam"
        ;;
      desktop | plasma*)
        # SteamOS only knows about KDE; treat every desktop flavor Steam may
        # ask for as "the configured desktop session".
        target=${
          if cfg.desktopSession != null then lib.escapeShellArg cfg.desktopSession else ''"steam"''
        }
        ;;
      *)
        # Power users may name any installed wayland session directly.
        target="$request"
        ;;
    esac

    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
    select_file="$state_dir/steamos-session-select"

    if [ "$target" = "steam" ]; then
      # Gaming Mode is the fallback session; no marker needed.
      rm -f "$select_file"
    else
      mkdir -p "$state_dir"
      printf '%s\n' "$target" > "$select_file"
    fi

    # End the current graphical session; the login loop then starts the
    # selected one. In Gaming Mode a clean Steam shutdown takes gamescope
    # (and thus the session) down with it; from a desktop we ask logind.
    if ${pkgs.procps}/bin/pgrep -x gamescope > /dev/null; then
      exec ${lib.getExe' config.programs.steam.package "steam"} -shutdown
    else
      exec ${pkgs.systemd}/bin/loginctl terminate-session "''${XDG_SESSION_ID:-}"
    fi
  '';

  # SteamOS ships the same affordance on the desktop: an icon that brings
  # you back to Gaming Mode.
  return-to-gaming-mode = pkgs.makeDesktopItem {
    name = "return-to-gaming-mode";
    desktopName = "Return to Gaming Mode";
    comment = "Leave the desktop and return to Steam";
    exec = "${steamos-session-select}/bin/steamos-session-select gamescope";
    icon = "steam";
    categories = [ "Game" ];
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.autoStart) {
    environment.systemPackages = [
      steamos-session-select
    ]
    ++ lib.optional (cfg.desktopSession != null) return-to-gaming-mode;
  };
}
