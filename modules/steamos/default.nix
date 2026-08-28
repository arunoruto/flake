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
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos;
in
{
  imports = [
    ./gaming-mode.nix
    ./session-select.nix
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

    steamArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "-gamepadui"
        "-steamos3"
        "-steampal"
        "-steamdeck"
        "-pipewire-dmabuf"
      ];
      description = ''
        Arguments Steam is launched with inside Gaming Mode. The default is
        the set Valve's own `steam-launcher` uses, plus `-pipewire-dmabuf`
        for Remote Play. `-steamos3` is what ties Steam into gamescope's
        focus handling and puts "Switch to Desktop" in the power menu.
      '';
    };

    hdr.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow HDR output in Gaming Mode: starts gamescope with
        `--hdr-enabled` and tells Steam the session supports HDR, which is
        what puts the HDR toggle in Gaming Mode's display settings.

        Harmless on SDR displays — gamescope only drives HDR when the
        connected output actually advertises it. Requires the gamescope WSI
        Vulkan layer ({option}`steamos.gamescope.wsi.enable`) for games to
        hand HDR swapchains through.
      '';
    };

    vrr.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow variable refresh rate (FreeSync/G-Sync): starts gamescope with
        `--adaptive-sync` and exposes the VRR toggle in Gaming Mode's display
        settings. Ignored by gamescope when the output does not support it.
      '';
    };

    tearing.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Allow tearing presentation (`--immediate-flips`) and expose Steam's
        per-game tearing toggle. Trades visible tearing for latency; off by
        default because VRR is the better answer on displays that have it.
      '';
    };

    mangoapp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Run gamescope's mangoapp overlay, which is what backs Steam's
          built-in "Performance Overlay" levels in Gaming Mode.
        '';
      };

      fontScale = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.float lib.types.ints.positive);
        default = null;
        example = 2.7;
        description = ''
          Multiplier for the performance overlay's size (MangoHud's
          `font_scale`, which scales the panel as well as the text).

          MangoHud draws the overlay at a fixed size that was picked for the
          Steam Deck's 1280x800 panel, so it shrinks to an unreadable speck on
          a 4K television. The default `null` scales it automatically against
          the tallest connected output — roughly 1.8x at 1440p and 2.7x at
          2160p — which keeps it about the size it is on a Deck. Set a number
          to pin it, or `1` for MangoHud's own sizing.
        '';
      };

      backgroundAlpha = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.float lib.types.ints.unsigned);
        default = 0.8;
        example = 0.5;
        description = ''
          Opacity of the performance overlay's backdrop, from `0` (invisible)
          to `1` (solid).

          MangoHud defaults to `0.5`, which is legible on a monitor an arm's
          length away and washes out into the game from across a living room.
          `null` leaves MangoHud's own default alone.
        '';
      };
    };

    realtime.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Let gamescope renice itself into realtime scheduling (`--rt`), by
        giving the binary `cap_sys_nice` via
        {option}`programs.gamescope.capSysNice`.

        Off by default: the capability puts gamescope in secure-execution
        mode, where the loader ignores `LD_LIBRARY_PATH`/`LD_PRELOAD`, which
        has historically broken launching it from Steam's FHS environment.
        Turn it on and verify Gaming Mode still starts before keeping it.
      '';
    };

    gamescope = {
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "--output-width"
          "3840"
          "--output-height"
          "2160"
        ];
        description = ''
          Extra arguments appended to the gamescope command line, after the
          ones this module derives from the options above.
        '';
      };

      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          GAMESCOPE_MODE_SAVE_FILE = "/tmp/modes.cfg";
        };
        description = ''
          Extra environment variables for the Gaming Mode session. These are
          exported last, so they override the module's own defaults.
        '';
      };

      wsi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Install the gamescope WSI Vulkan layer
            (`VK_LAYER_FROG_gamescope_wsi`) and enable it for the session.
            The layer is how games present through gamescope directly — it
            carries frame pacing, the fps limiter, and HDR swapchains.
            Without it HDR content is tonemapped down to SDR.
          '';
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ pkgs.gamescope-wsi ];
          defaultText = lib.literalExpression "[ pkgs.gamescope-wsi ]";
          description = ''
            64-bit builds of the gamescope WSI layer, added to
            {option}`hardware.graphics.extraPackages`. Override this to keep
            the layer in step with a non-default
            {option}`programs.gamescope.package`.
          '';
        };

        packages32 = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ pkgs.pkgsi686Linux.gamescope-wsi ];
          defaultText = lib.literalExpression "[ pkgs.pkgsi686Linux.gamescope-wsi ]";
          description = ''
            32-bit builds of the gamescope WSI layer, added to
            {option}`hardware.graphics.extraPackages32`. Needed by 32-bit
            games and by Proton's 32-bit halves.
          '';
        };
      };
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
      {
        assertion = cfg.gamescope.wsi.enable -> config.hardware.graphics.enable32Bit;
        message = "steamos.gamescope.wsi.enable needs hardware.graphics.enable32Bit for the 32-bit layer.";
      }
    ];

    warnings = lib.optional (cfg.autoStart && cfg.desktopSession == null) ''
      steamos.desktopSession is unset: "Switch to Desktop" in Gaming Mode will
      relaunch Gaming Mode. Set it to a session name (e.g. "gnome" or "plasma")
      to get a Desktop Mode.
    '';
  };
}
