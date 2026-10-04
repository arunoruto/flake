# Shared pieces for the Steamix VM tests: stand-ins for what a test VM cannot
# run for real, plus the node configuration every test starts from.
#
# Steam is unfree, downloads its client on first start and needs an account,
# so it is replaced by a stub that behaves like it in the ways the module
# depends on: it is started by the Gaming Mode session with Valve's arguments,
# it calls `steamos-session-select` the way Steam's power menu does, and
# `steam -shutdown` makes the running instance exit.
#
# gamescope is replaced too. It needs a Vulkan device with a DRM render node
# (VK_EXT_physical_device_drm) for every backend, headless included, and the
# only Vulkan driver in a sandboxed VM is lavapipe, which has none: the real
# binary starts, selects llvmpipe, and dies with "Failed to create backend".
# The stub records the command line the session script built and runs Steam
# as its child, which is the contract the module relies on. Everything else in
# the path (greetd, PAM, logind, the launcher, the session script, the
# switcher) is the real thing.
#
# The test driver talks to the stubs through files in `stateDir`: each stub
# records what it saw (arguments, environment, logind session) and polls for
# a command file the test script drops in. Writing the file is the test's
# equivalent of pressing a button on screen.
{ pkgs, lib }:
let
  stateDir = "/tmp/steamix-test";

  # The packages nixpkgs does not have (Decky, its plugins, SteamOS Manager),
  # built against the same nixpkgs as the test.
  steamixPackages = import ../packages { inherit pkgs; };

  # Absolute, so the stubs do not depend on whatever PATH the session got.
  sessionSelect = "/run/current-system/sw/bin/steamos-session-select";

  steamScript = pkgs.writeShellScriptBin "steam" ''
    set -u
    dir=${stateDir}

    # `steam -shutdown` is how the switcher ends Gaming Mode: ask the running
    # instance to exit, as the real client does over its IPC pipe.
    if [ "''${1:-}" = "-shutdown" ]; then
      echo "shutdown requested" >> "$dir/steam.log"
      touch "$dir/steam-shutdown"
      exit 0
    fi

    starts=$(( $(cat "$dir/steam-starts" 2>/dev/null || echo 0) + 1 ))
    echo "$starts" > "$dir/steam-starts"
    printf '%s\n' "$@" > "$dir/steam-args"
    env | sort > "$dir/steam-env"
    echo "start $starts: $*" >> "$dir/steam.log"
    touch "$dir/steam-running"

    # Real Steam dies with the X server gamescope gave it. Without this, a
    # killed gamescope would leave the stub behind, answering the commands
    # meant for the next session's Steam.
    compositor=$PPID

    while [ ! -e "$dir/steam-shutdown" ]; do
      if ! kill -0 "$compositor" 2>/dev/null; then
        rm -f "$dir/steam-running"
        echo "compositor gone, exiting" >> "$dir/steam.log"
        exit 1
      fi
      # The power menu: Steam runs the switcher itself, from inside the
      # session, with Valve's session names ("plasma" for the desktop).
      if [ -e "$dir/steam-cmd" ]; then
        cmd=$(cat "$dir/steam-cmd")
        rm -f "$dir/steam-cmd"
        echo "power menu: $cmd" >> "$dir/steam.log"
        ${sessionSelect} "$cmd" &
      fi
      sleep 0.5
    done

    rm -f "$dir/steam-shutdown" "$dir/steam-running"
    echo "exit after shutdown" >> "$dir/steam.log"
  '';

  # programs.steam wraps its package with `.override` (extra libraries and
  # environment from the system configuration) and installs `.run` next to
  # it, so the stub has to accept both. Neither changes what the stub does.
  steam = lib.makeOverridable (_: steamScript.overrideAttrs { passthru.run = steamScript; }) { };

  # gamescope's side of the contract: take the session script's command
  # line, export the variables gamescope gives its clients, run the command
  # after `--` as a child, and exit when it does. Keeping the process alive
  # (rather than exec'ing) and keeping the name `gamescope` matters: the
  # switcher looks for it by name to tell Gaming Mode from the desktop.
  gamescopeScript = pkgs.writeShellScriptBin "gamescope" ''
    set -u
    dir=${stateDir}

    printf '%s\n' "$@" > "$dir/gamescope-args"
    env | sort > "$dir/gamescope-env"

    while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do shift; done
    [ "$#" -gt 0 ] && shift

    # Printed to the session's stdout, which the session script sends to
    # the journal; the test checks it arrives there.
    echo "gamescope stub: running $1"

    export DISPLAY=:1 GAMESCOPE_WAYLAND_DISPLAY=gamescope-0
    "$@" &
    child=$!
    trap 'kill "$child" 2>/dev/null' TERM INT HUP
    wait "$child"
  '';

  # programs.gamescope wraps `bin/gamescope` and links `bin/gamescopectl`.
  gamescope = pkgs.symlinkJoin {
    name = "gamescope-stub";
    paths = [
      gamescopeScript
      (pkgs.writeShellScriptBin "gamescopectl" "exit 0")
    ];
  };

  # A Wayland session for "Switch to Desktop" to land in. It records the
  # identity the launcher gave it and the logind session it ended up in —
  # the part real desktops are picky about — and runs the "Return to Gaming
  # Mode" action when asked.
  desktopScript = pkgs.writeShellScriptBin "fake-desktop" ''
    set -u
    dir=${stateDir}

    starts=$(( $(cat "$dir/desktop-starts" 2>/dev/null || echo 0) + 1 ))
    echo "$starts" > "$dir/desktop-starts"
    env | sort > "$dir/desktop-env"
    loginctl show-session "''${XDG_SESSION_ID:-}" -p Type -p Class -p Active \
      > "$dir/desktop-session" 2>&1 || true
    touch "$dir/desktop-running"

    while :; do
      if [ -e "$dir/desktop-cmd" ]; then
        rm -f "$dir/desktop-cmd" "$dir/desktop-running"
        # What the "Return to Gaming Mode" launcher entry runs.
        exec ${sessionSelect} gamescope
      fi
      sleep 0.5
    done
  '';

  desktopSession =
    (pkgs.writeTextDir "share/wayland-sessions/fake-desktop.desktop" ''
      [Desktop Entry]
      Name=Fake Desktop
      Comment=Stand-in desktop session for the Steamix VM tests
      Exec=${lib.getExe desktopScript}
      Type=Application
      DesktopNames=FakeDE
    '').overrideAttrs
      { passthru.providedSessions = [ "fake-desktop" ]; };
in
{
  inherit
    stateDir
    steam
    desktopSession
    steamixPackages
    ;

  # The configuration every Steamix test node starts from.
  baseNode =
    { ... }:
    {
      imports = [ ../modules/nixos ];

      users.users.alice = {
        isNormalUser = true;
        description = "Alice, holding the controller";
      };

      programs.steam.package = steam;
      programs.gamescope.package = gamescope;

      systemd.tmpfiles.rules = [ "d ${stateDir} 0755 alice users -" ];

      virtualisation = {
        memorySize = 2048;
        cores = 2;
      };

      documentation.enable = false;
    };
}
