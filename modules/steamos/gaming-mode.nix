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

  # How many columns the horizontal levels lay out. Shared with the scale
  # calculation, which uses it to work out how wide the table would be.
  mangoappTableColumns = 20;

  # What each performance-overlay level looks like. Defining a preset here
  # replaces MangoHud's built-in one, so each is spelled out — minus the Deck's
  # battery readouts, which a desktop has nothing to fill in. The sizing
  # placeholder is substituted at session start, once the display is known.
  mangoappPresets =
    let
      sizing = "font_scale=@fontScale@" + alpha;
      denseSizing = "font_scale=@denseScale@" + alpha;
      alpha = lib.optionalString (
        cfg.mangoapp.backgroundAlpha != null
      ) "\nbackground_alpha=${toString cfg.mangoapp.backgroundAlpha}";
    in
    pkgs.writeText "steamos-mangoapp-presets.conf" ''
      [preset 0]
      no_display

      [preset 1]
      ${sizing}
      legacy_layout=0
      cpu_stats=0
      gpu_stats=0
      fps
      fps_only
      frametime=0

      [preset 2]
      ${denseSizing}
      legacy_layout=0
      horizontal
      hud_no_margin
      table_columns=${toString mangoappTableColumns}
      fps
      frame_timing=1
      frametime=0
      cpu_stats
      cpu_power
      gpu_stats
      gpu_power
      ram
      vram

      [preset 3]
      ${denseSizing}
      legacy_layout=0
      horizontal
      hud_no_margin
      table_columns=${toString mangoappTableColumns}
      fps
      frame_timing=1
      frametime=0
      cpu_stats
      cpu_power
      cpu_temp
      cpu_mhz
      gpu_stats
      gpu_power
      gpu_temp
      gpu_core_clock
      gpu_mem_clock
      ram
      vram
      hdr

      [preset 4]
      ${denseSizing}
      full
      throttling_status=0
      io_read=0
      io_write=0
      arch=0
      engine_version=0
      gamemode=0
      vkbasalt=0
      frame_count=0
      show_fps_limit=0
      resolution=0
      media_player=0
      version=0
      frame_timing_detailed=1
      refresh_rate=1
      network=1
      hdr
    '';

  steamos-gamescope-session = pkgs.writeShellScriptBin "steamos-gamescope-session" ''
    set -eu

    # Put this session's output in the journal, whoever started it.
    #
    # Whatever launches the session hands it a console, so by default
    # everything it prints — gamescope's mode selection, its errors, a
    # compositor's death rattle — lands on whichever display owns fbcon.
    # That is the wrong place twice over: invisible unless something is
    # plugged into the GPU holding the framebuffer console (not necessarily
    # the one being rendered on), and unreachable over SSH, so a session that
    # fails to start leaves a black screen and no way to ask why. In the
    # journal it is `journalctl -t steamos-session` from anywhere.
    #
    # The greetd launcher wraps whatever session it resolves, desktops
    # included, and sets this variable to say so; SDDM runs the .desktop file
    # directly and does not, which is why this has to live here rather than
    # only on that path. systemd-cat execs rather than forks, so the process
    # tree its parent sees is unchanged either way.
    if [ -z "''${STEAMOS_SESSION_JOURNAL:-}" ]; then
      export STEAMOS_SESSION_JOURNAL=1
      exec ${lib.getExe' pkgs.systemd "systemd-cat"} \
        --identifier=steamos-session -- "$0" "$@"
    fi

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

      # Size the overlay for the display, through the *presets* file rather
      # than the config.
      #
      # MangoHud draws the overlay at a size tuned for the Deck's 1280x800
      # panel, so on a 4K television it is a speck. Steam owns the config file
      # above and rewrites it on every level change, so the sizing cannot live
      # there. Two other routes do not work either:
      #
      #   - MANGOHUD_CONFIG makes mangoapp draw every element twice. MangoHud
      #     applies the preset once while reading the config and again while
      #     re-reading the environment, appending to the same element list with
      #     nothing to deduplicate it — at level 1 that is two FPS counters.
      #   - leaving MANGOHUD_CONFIGFILE unset, so MangoHud merges its usual
      #     search path, hands the variable to gamescope, which points it at a
      #     temporary file of its own and bypasses that path anyway.
      #
      # MANGOHUD_PRESETSFILE is read independently of both. Steam still chooses
      # the level; this decides what each level looks like.
      # Two scales, because one does not fit every level.
      #
      # Level 1 is a single number and can take the full scale. The denser
      # levels lay out a table whose width MangoHud computes as
      # `font_size * font_scale * table_columns * 4.6`; at the full scale that
      # comes to ~5960px on this display and spills off the right edge, and the
      # vertical `full` level spills off the bottom for the same reason. So the
      # dense levels get whatever scale still fits the widest row, which is
      # still far larger than MangoHud's default.
      ${
        if cfg.mangoapp.fontScale != null then
          ''
            font_scale=${toString cfg.mangoapp.fontScale}
            dense_scale=${toString cfg.mangoapp.fontScale}
          ''
        else
          ''
            eval "$(
              for modes in /sys/class/drm/*/modes; do
                connector="''${modes%/modes}"
                [ "$(cat "$connector/status" 2>/dev/null)" = connected ] || continue
                ${pkgs.coreutils}/bin/head -n1 "$modes" 2>/dev/null
              done \
                | ${pkgs.gnused}/bin/sed 's/x/ /' \
                | ${pkgs.coreutils}/bin/sort -k2 -rn \
                | ${pkgs.coreutils}/bin/head -n1 \
                | ${pkgs.gawk}/bin/awk -v cols=${toString mangoappTableColumns} '
                    { width = $1 + 0; height = $2 + 0 }
                    END {
                      # Fall back to the Deck panel, which is what MangoHud
                      # sizes itself for, so an unreadable display yields 1.
                      if (width < 1280) width = 1280
                      if (height < 800) height = 800

                      scale = height / 800
                      if (scale > 4) scale = 4

                      # Widest the table may be, leaving a small margin.
                      fits = (width * 0.95) / (24 * 4.6 * cols)
                      dense = (fits < scale ? fits : scale)
                      if (dense < 1) dense = 1

                      printf "font_scale=%.2f dense_scale=%.2f", scale, dense
                    }
                  '
            )"
            [ -n "''${font_scale:-}" ] || font_scale=1
            [ -n "''${dense_scale:-}" ] || dense_scale=1
          ''
      }
      mangohud_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/MangoHud"
      export MANGOHUD_PRESETSFILE="$mangohud_dir/steamos-presets.conf"
      ${pkgs.coreutils}/bin/mkdir -p "$mangohud_dir"
      ${pkgs.gnused}/bin/sed \
        -e "s|@fontScale@|$font_scale|g" \
        -e "s|@denseScale@|$dense_scale|g" \
        ${mangoappPresets} > "$MANGOHUD_PRESETSFILE"
    ''}

    # The session identity is exported into the systemd user manager by the
    # login loop (./autostart.nix), which does it for every session rather
    # than just this one. Deliberately not repeated here: XDG_SESSION_TYPE is
    # x11 inside Gaming Mode, and leaking that into the user manager would
    # follow us into Desktop Mode.

    ${lib.optionalString (cfg.manager.enable && cfg.loginManager == "sddm") ''
      # SteamOS Manager ends a session by stopping graphical-session.target,
      # which on SteamOS proper takes the whole session down because every
      # session unit is bound to it. Here gamescope is a plain child of
      # sddm-helper, so stopping that target used to do nothing and "Switch
      # to Desktop" hung forever. Park a stand-in unit in the target whose
      # stop shuts Steam down cleanly; gamescope and the session follow it
      # down, and SDDM's Relogin then starts whichever session the manager
      # wrote into its temp drop-in. The unit name is load-bearing: the
      # manager also reads gamescope-session.service to answer "which mode
      # am I in".
      ${pkgs.systemd}/bin/systemctl --user reset-failed gamescope-session.service 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl --user stop gamescope-session.service 2>/dev/null || true
      ${pkgs.systemd}/bin/systemd-run --user --collect --quiet \
        --unit=gamescope-session.service \
        --property=RemainAfterExit=yes \
        --property=PartOf=graphical-session.target \
        --property=Wants=graphical-session.target \
        --property=ExecStop='${lib.getExe' config.programs.steam.package "steam"} -shutdown' \
        ${pkgs.coreutils}/bin/true || true
    ''}

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
