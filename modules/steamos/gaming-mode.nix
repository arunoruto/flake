# Gaming Mode: the gamescope session Steam runs in, modelled on Valve's own
# `gamescope-session` script (steamos-customizations / PKGBUILDs-mirror) with
# the Steam Deck hardware bits left out.
#
# nixpkgs' `programs.steam.gamescopeSession` boils that script down to
# `gamescope --steam -- steam -tenfoot`, which is enough to *see* Gaming Mode
# but not enough for it to behave: the session Steam expects also sets up a
# second Xwayland server for games, the WSI layer, and a pile of
# `STEAM_GAMESCOPE_*` capability flags the client reads at startup. So this
# module registers its own session instead of using that one.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos;

  gamescopeArgs = [
    # Steam integration: the atoms/XWM protocol Steam drives Gaming Mode with.
    "--steam"

    # Two Xwayland servers, as SteamOS runs: the Deck UI keeps server 0 and
    # games are isolated onto server 1 (see STEAM_MULTIPLE_XWAYLANDS below).
    # With a single server the Steam UI and the game fight over one focus
    # stack, which strands input on the overlay after the Steam button is
    # pressed — the game keeps rendering but never gets focus back.
    "--xwayland-count"
    "2"

    # Console-feel touches from Valve's session.
    "--hide-cursor-delay"
    "3000"
    "--fade-out-duration"
    "200"
  ]
  ++ lib.optional cfg.realtime.enable "--rt"
  ++ lib.optional cfg.hdr.enable "--hdr-enabled"
  ++ lib.optional cfg.vrr.enable "--adaptive-sync"
  ++ lib.optional cfg.tearing.enable "--immediate-flips"
  ++ lib.optional cfg.mangoapp.enable "--mangoapp"
  ++ cfg.gamescope.args;

  # Capability flags the Steam client reads once, at startup, to decide which
  # Gaming Mode features to offer. They are not gamescope settings — Steam
  # simply believes them, so only advertise what this session really provides.
  sessionEnv = {
    # Steam and its games are X11 clients of gamescope's Xwayland servers,
    # whatever the display manager told us we were logging into.
    XDG_SESSION_TYPE = "x11";

    # Per-game Xwayland isolation; the client half of --xwayland-count 2.
    STEAM_MULTIPLE_XWAYLANDS = "1";

    # Don't let SDL games minimise themselves when the overlay takes focus.
    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";

    # Present through the gamescope WSI layer rather than plain Xwayland WSI.
    ENABLE_GAMESCOPE_WSI = if cfg.gamescope.wsi.enable then "1" else "0";

    # Don't wait for buffers to idle client-side before handing them over.
    vk_xwayland_wait_ready = "false";

    # Colour management, scaling and upscaler toggles in the Deck UI.
    STEAM_GAMESCOPE_COLOR_MANAGED = "1";
    STEAM_GAMESCOPE_VIRTUAL_WHITE = "1";
    STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT = "1";
    STEAM_GAMESCOPE_NIS_SUPPORTED = "1";

    # Steam's own volume handling, and its URL handler for steam:// links.
    STEAM_ENABLE_VOLUME_HANDLER = "1";
    SRT_URLOPEN_PREFER_STEAM = "1";

    # Steam's on-screen keyboard for Qt/GTK apps launched inside the session.
    QT_IM_MODULE = "steam";
    GTK_IM_MODULE = "Steam";

    # There is no way to set a colour space for an NV12 buffer in Wayland yet,
    # so Remote Play Together and gamescope agree on one out of band.
    GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601";

    # Older vkd3d-proton picks a swapchain latency low enough to look like
    # swapchain starvation under gamescope.
    VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3";
  }
  // lib.optionalAttrs cfg.hdr.enable {
    STEAM_GAMESCOPE_HDR_SUPPORTED = "1";
  }
  // lib.optionalAttrs cfg.vrr.enable {
    STEAM_GAMESCOPE_VRR_SUPPORTED = "1";
  }
  // lib.optionalAttrs cfg.tearing.enable {
    STEAM_GAMESCOPE_HAS_TEARING_SUPPORT = "1";
    STEAM_GAMESCOPE_TEARING_SUPPORTED = "1";
  }
  // lib.optionalAttrs cfg.mangoapp.enable {
    STEAM_USE_MANGOAPP = "1";
    STEAM_MANGOAPP_PRESETS_SUPPORTED = "1";
    STEAM_MANGOAPP_HORIZONTAL_SUPPORTED = "1";
    # mangoapp sets GAMESCOPE_EXTERNAL_OVERLAY itself these days.
    STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND = "1";
  }
  // cfg.gamescope.env;

  exports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") sessionEnv
  );

  steamos-gamescope-session = pkgs.writeShellScriptBin "steamos-gamescope-session" ''
    set -eu

    # /run/wrappers/bin first so the cap_sys_nice gamescope wins when
    # steamos.realtime.enable put one there, then the ambient PATH so the
    # wrapper `programs.gamescope` installs (it carries that module's
    # args/env) is preferred over the bare package — which is appended last
    # only as a guaranteed fallback. mangohud supplies `mangoapp`, which
    # gamescope spawns by name.
    export PATH="/run/wrappers/bin:$PATH:${config.programs.gamescope.package}/bin:${pkgs.mangohud}/bin"

    ${exports}

    # gamescope remembers per-output modes and EDID overrides here.
    export GAMESCOPE_MODE_SAVE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/modes.cfg"
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$GAMESCOPE_MODE_SAVE_FILE")"
    ${pkgs.coreutils}/bin/touch "$GAMESCOPE_MODE_SAVE_FILE"

    # The callback-based framerate limiter communicates through this file.
    GAMESCOPE_LIMITER_FILE="$(${pkgs.coreutils}/bin/mktemp -t gamescope-limiter.XXXXXXXX)"
    export GAMESCOPE_LIMITER_FILE
    ${lib.optionalString cfg.mangoapp.enable ''
      # Steam owns this file: it writes a `preset=N` line here for the
      # performance-overlay level, then runs `mangohudctl toggle reload_config`
      # (visible in Steam's own console_log.txt) to make mangoapp re-parse its
      # config. The levels themselves are MangoHud's built-in presets — 1 is
      # fps-only, 2 the Deck-style horizontal bar, 3 adds temps and clocks, 4
      # is full.
      #
      # Valve's session script instead points MANGOHUD_CONFIGFILE at a fresh
      # mktemp, which this module copied — so mangoapp watched a file Steam
      # never writes and every level looked the same. Point it where Steam
      # actually writes.
      MANGOHUD_CONFIGFILE="''${XDG_DATA_HOME:-$HOME/.local/share}/Steam/config/mangohud.conf"
      export MANGOHUD_CONFIGFILE
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$MANGOHUD_CONFIGFILE")"
      # Seed only when Steam has not written one yet, so an existing level
      # survives. Both lines are what Steam itself puts in the file: `control`
      # opens MangoHud's control channel, and `no_display` keeps the overlay
      # off until Steam has pushed a level.
      if [ ! -e "$MANGOHUD_CONFIGFILE" ]; then
        ${pkgs.coreutils}/bin/printf '%s\n' no_display control=mangohud > "$MANGOHUD_CONFIGFILE"
      fi

      # Size the overlay for the display. MangoHud draws it at a fixed size
      # tuned for the Deck's 1280x800 panel, so on a 4K television it is a
      # speck. Steam rewrites the config file above whenever the level
      # changes, so the scale cannot live in it — MANGOHUD_CONFIG is applied
      # *after* the file, and `read_cfg` is what keeps the file (and with it
      # Steam's preset) being read at all.
      ${
        if cfg.mangoapp.fontScale != null then
          "font_scale=${toString cfg.mangoapp.fontScale}"
        else
          ''
            font_scale="$(
              for modes in /sys/class/drm/*/modes; do
                connector="''${modes%/modes}"
                [ "$(cat "$connector/status" 2>/dev/null)" = connected ] || continue
                ${pkgs.coreutils}/bin/head -n1 "$modes" 2>/dev/null
              done \
                | ${pkgs.coreutils}/bin/cut -dx -f2 \
                | ${pkgs.coreutils}/bin/sort -rn \
                | ${pkgs.coreutils}/bin/head -n1 \
                | ${pkgs.gawk}/bin/awk '
                    { height = $1 + 0 }
                    END {
                      if (height < 800) height = 800
                      scale = height / 800
                      if (scale > 4) scale = 4
                      printf "%.2f", scale
                    }
                  '
            )"
            [ -n "$font_scale" ] || font_scale=1
          ''
      }
      export MANGOHUD_CONFIG="read_cfg,font_scale=$font_scale${
        lib.optionalString (
          cfg.mangoapp.backgroundAlpha != null
        ) ",background_alpha=${toString cfg.mangoapp.backgroundAlpha}"
      }"
    ''}

    # The session identity is exported into the systemd user manager by the
    # login loop (./autostart.nix), which does it for every session rather
    # than just this one. Deliberately not repeated here: XDG_SESSION_TYPE is
    # x11 inside Gaming Mode, and leaking that into the user manager would
    # follow us into Desktop Mode.

    # Steam opens a file descriptor per shader cache entry, among other things.
    ulimit -n 524288 || true

    exec gamescope ${lib.escapeShellArgs gamescopeArgs} -- \
      ${lib.getExe' config.programs.steam.package "steam"} ${lib.escapeShellArgs cfg.steamArgs}
  '';

  sessionEntry = ''
    [Desktop Entry]
    Name=Steam
    Comment=Steam Gaming Mode (gamescope)
    Exec=${lib.getExe steamos-gamescope-session}
    Type=Application
    DesktopNames=gamescope
  '';

  # Registered under the name "steam" — the same session name nixpkgs'
  # gamescopeSession uses — so switching away and back (./session-select.nix)
  # keeps working, and so does anything already referring to it.
  #
  # On the SDDM path it is registered under Valve's name as well. SteamOS
  # Manager asks for "gamescope-wayland.desktop" by name when Steam requests
  # game mode, and that string is not configurable, so the session has to
  # answer to it or switching back from the desktop fails.
  sessionAliases = [ "steam" ] ++ lib.optional (cfg.loginManager == "sddm") "gamescope-wayland";

  sessionPackage =
    (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" sessionEntry).overrideAttrs
      (old: {
        buildCommand =
          old.buildCommand
          + lib.optionalString (cfg.loginManager == "sddm") ''
            ln -s steam.desktop "$out/share/wayland-sessions/gamescope-wayland.desktop"
          '';
        passthru.providedSessions = sessionAliases;
      });
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = lib.mkDefault true;
      # This module provides the session itself; nixpkgs' minimal one would
      # register a second `steam.desktop` and collide with it. Forced rather
      # than merged, so a consumer that had switched it on gets this session
      # instead of a module-system conflict they cannot act on.
      gamescopeSession.enable = lib.mkForce false;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = lib.mkDefault cfg.realtime.enable;
    };

    services.displayManager.sessionPackages = [ sessionPackage ];

    environment.systemPackages = [ steamos-gamescope-session ];

    hardware.graphics = lib.mkIf cfg.gamescope.wsi.enable {
      extraPackages = [ cfg.gamescope.wsi.package ];
      extraPackages32 = [ cfg.gamescope.wsi.package32 ];
    };

    # Controller access comes from hardware.steam-hardware, which
    # programs.steam turns on: it installs Valve's steam-devices rules, which
    # already tag /dev/uinput for the active session and carry uaccess rules
    # for every controller Steam supports. Nothing to add here — a blanket
    # `KERNEL=="hidraw*", TAG+="uaccess"` would hand the session every HID
    # device on the machine, which is more than Valve grants on a Deck.

    # Proton runs some threads at negative niceness. Scope the allowance to
    # the user Gaming Mode logs in as rather than granting it system-wide.
    security.pam.loginLimits = lib.mkIf (cfg.user != null) [
      {
        domain = cfg.user;
        type = "hard";
        item = "nice";
        value = "-8";
      }
    ];

    # Gaming Mode's network settings write *system* connections, which
    # normally needs the networkmanager group — impossible to grant mid-setup
    # on a machine you drive with a controller. Jovian allows this for anyone
    # in `users`; scope it to the one account the session runs as instead.
    security.polkit.extraConfig =
      lib.mkIf (cfg.user != null && config.networking.networkmanager.enable)
        ''
          // steamos: let ${cfg.user} configure Wi-Fi from Gaming Mode
          polkit.addRule(function(action, subject) {
            if (
              action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
              subject.user == ${builtins.toJSON cfg.user} &&
              subject.local &&
              subject.active
            ) {
              return polkit.Result.YES;
            }
          });
        '';
  };
}
