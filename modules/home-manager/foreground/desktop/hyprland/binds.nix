# Binds in Hyprland >= 0.55 are `hl.bind(keys, dispatcher, { flags })`:
#
#   * keys       one string, e.g. "SUPER + SHIFT + Q" (or "code:28", "mouse:272")
#   * dispatcher an `hl.dsp.*` call -- raw Lua, so it goes through mkLuaInline
#   * flags      a table; the old bind suffixes are flags now:
#                bindm -> mouse, binde -> repeating, bindl -> locked,
#                bindr -> release, plus long_press, non_consuming,
#                transparent, ignore_mods, submap_universal and description
#
# `description` shows up in `hyprctl binds`, which is the cheapest way to
# remember what you bound. https://wiki.hypr.land/Configuring/Core/Binds/
{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  cfg = config.hypr.binds;
  mod = cfg.modifier;

  inherit (lib.generators) mkLuaInline;

  bind = keys: dispatcher: flags: {
    _args = [
      keys
      (mkLuaInline dispatcher)
    ]
    ++ lib.optional (flags != { }) flags;
  };

  # hl.dsp.exec_cmd runs its argument through `sh -c`.
  exec = command: "hl.dsp.exec_cmd(${builtins.toJSON command})";

  menu = "${lib.getExe config.programs.wofi.package} --show drun --normal-window";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  brightnessctl = lib.getExe pkgs.brightnessctl;
  playerctl = lib.getExe pkgs.playerctl;

  # Tearing the compositor out from under a uwsm-managed session skips the
  # ordered shutdown; `uwsm stop` brings the graphical session down properly.
  # https://wiki.hypr.land/Useful-Utilities/uwsm/
  exitCommand =
    if (osConfig != null && (osConfig.programs.hyprland.withUWSM or false)) then
      "uwsm stop"
    else
      "hyprctl dispatch 'hl.dsp.exit()'";

  # vim keys and arrows, same dispatchers.
  directions = {
    H = "left";
    J = "down";
    K = "up";
    L = "right";
    left = "left";
    down = "down";
    up = "up";
    right = "right";
  };

  focusBinds = lib.mapAttrsToList (
    key: direction:
    bind "${mod} + ${key}" ''hl.dsp.focus({ direction = "${direction}" })'' {
      description = "Focus ${direction}";
    }
  ) directions;

  moveBinds = lib.mapAttrsToList (
    key: direction:
    bind "${mod} + SHIFT + ${key}" ''hl.dsp.window.move({ direction = "${direction}" })'' {
      description = "Move window ${direction}";
    }
  ) directions;

  # 1..9 on their own keys, 10 on 0.
  workspaceBinds = lib.concatMap (
    index:
    let
      key = toString (lib.mod index 10);
      workspace = toString index;
    in
    [
      (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${workspace} })" {
        description = "Workspace ${workspace}";
      })
      (bind "${mod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${workspace} })" {
        description = "Move window to workspace ${workspace}";
      })
    ]
  ) (lib.range 1 10);
in
{
  options.hypr.binds = {
    enable = lib.mkEnableOption "Custom hyprland keybindings";

    modifier = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      example = "ALT";
      description = "Modifier every window-management bind hangs off.";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.bind = [
        # Launching
        (bind "${mod} + Return" (exec config.terminals.main) { description = "Terminal"; })
        (bind "${mod} + D" (exec menu) { description = "App launcher"; })
        (bind "${mod} + F1" (exec (
          if config.programs.zen-browser.enable or false then
            lib.getExe config.programs.zen-browser.finalPackage
          else
            "xdg-open about:blank"
        )) { description = "Browser"; })

        # Window management
        (bind "${mod} + SHIFT + Q" "hl.dsp.window.close()" { description = "Close window"; })
        (bind "${mod} + SPACE" "hl.dsp.window.float()" { description = "Toggle floating"; })
        (bind "${mod} + F" "hl.dsp.window.fullscreen()" { description = "Toggle fullscreen"; })
        (bind "${mod} + P" "hl.dsp.window.pseudo()" { description = "Toggle pseudotiling"; })
        (bind "${mod} + C" "hl.dsp.window.center()" { description = "Center window"; })
        (bind "${mod} + V" ''hl.dsp.layout("togglesplit")'' {
          description = "Flip dwindle split direction";
        })

        # Native groups: what hy3's tab groups used to be needed for.
        # https://wiki.hypr.land/Configuring/Core/Dispatchers/#grouped-tabbed-windows
        (bind "${mod} + G" "hl.dsp.group.toggle()" { description = "Toggle tab group"; })
        (bind "${mod} + Tab" "hl.dsp.group.next()" { description = "Next tab in group"; })
        (bind "${mod} + SHIFT + Tab" "hl.dsp.group.prev()" { description = "Previous tab in group"; })

        # Scratchpad
        (bind "${mod} + S" ''hl.dsp.workspace.toggle_special("magic")'' {
          description = "Toggle scratchpad";
        })
        (bind "${mod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'' {
          description = "Move window to scratchpad";
        })

        # Workspace scrolling
        (bind "${mod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'' {
          description = "Next workspace";
        })
        (bind "${mod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'' {
          description = "Previous workspace";
        })

        # Mouse drag/resize
        (bind "${mod} + mouse:272" "hl.dsp.window.drag()" {
          mouse = true;
          description = "Drag window";
        })
        (bind "${mod} + mouse:273" "hl.dsp.window.resize()" {
          mouse = true;
          description = "Resize window";
        })

        # Session
        (bind "${mod} + R" ''hl.dsp.submap("resize")'' { description = "Enter resize mode"; })
        (bind "${mod} + SHIFT + R" "hl.dsp.reload_config()" { description = "Reload config"; })
        (bind "${mod} + SHIFT + E" (exec exitCommand) { description = "Exit session"; })

        # Screenshots
        (bind "Print" (exec "${lib.getExe pkgs.hyprshot} --clipboard-only -m region") {
          description = "Screenshot region to clipboard";
        })
        (bind "SHIFT + Print" (exec "${lib.getExe pkgs.hyprshot} --clipboard-only -m window") {
          description = "Screenshot window to clipboard";
        })
        (bind "${mod} + Print" (exec "${lib.getExe pkgs.hyprshot} --clipboard-only -m output") {
          description = "Screenshot output to clipboard";
        })

        # Volume, brightness and media. `locked` keeps them working over the
        # lock screen, `repeating` makes them fire while held.
        (bind "XF86AudioRaiseVolume" (exec "${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+") {
          locked = true;
          repeating = true;
        })
        (bind "XF86AudioLowerVolume" (exec "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
          locked = true;
          repeating = true;
        })
        (bind "XF86AudioMute" (exec "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle") { locked = true; })
        (bind "XF86AudioMicMute" (exec "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle") {
          locked = true;
        })

        (bind "XF86MonBrightnessUp" (exec "${brightnessctl} -e4 -n2 set 5%+") {
          locked = true;
          repeating = true;
        })
        (bind "XF86MonBrightnessDown" (exec "${brightnessctl} -e4 -n2 set 5%-") {
          locked = true;
          repeating = true;
        })

        (bind "XF86AudioPlay" (exec "${playerctl} play-pause") { locked = true; })
        (bind "XF86AudioPause" (exec "${playerctl} play-pause") { locked = true; })
        (bind "XF86AudioNext" (exec "${playerctl} next") { locked = true; })
        (bind "XF86AudioPrev" (exec "${playerctl} previous") { locked = true; })
      ]
      ++ focusBinds
      ++ moveBinds
      ++ workspaceBinds;

      # A submap is a second keymap: everything inside it is only live while
      # the submap is active, and `onDispatch = "reset"` would drop back out
      # after a single key. https://wiki.hypr.land/Configuring/Core/Binds/Submaps/
      submaps.resize.settings.bind = [
        (bind "H" "hl.dsp.window.resize({ x = -40, y = 0, relative = true })" { repeating = true; })
        (bind "L" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })" { repeating = true; })
        (bind "K" "hl.dsp.window.resize({ x = 0, y = -40, relative = true })" { repeating = true; })
        (bind "J" "hl.dsp.window.resize({ x = 0, y = 40, relative = true })" { repeating = true; })
        (bind "left" "hl.dsp.window.resize({ x = -40, y = 0, relative = true })" { repeating = true; })
        (bind "right" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })" { repeating = true; })
        (bind "up" "hl.dsp.window.resize({ x = 0, y = -40, relative = true })" { repeating = true; })
        (bind "down" "hl.dsp.window.resize({ x = 0, y = 40, relative = true })" { repeating = true; })
        (bind "escape" ''hl.dsp.submap("reset")'' { })
        (bind "Return" ''hl.dsp.submap("reset")'' { })
      ];
    };
  };
}
