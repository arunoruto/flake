# yabai — BSP tiling window manager, plus the skhd hotkey daemon that drives it.
#
# The two live in one file because every skhd binding here is a `yabai -m`
# invocation; splitting them would only mean threading the modifier chord across
# a module boundary.
#
# Mechanism only — nothing here turns itself on. A host opts in with
# `services.yabai.enable = true` (see systems/aarch64-darwin/tensa/default.nix).
#
# Unlike AeroSpace, yabai tiles *within* native macOS Spaces, so Mission Control,
# Ctrl+arrow and the Spaces strip all keep working — which is the reason to pick
# it on a machine that still uses Desktops.
#
# The scripting addition stays OFF, so SIP is untouched. Per yabai(1) that costs
# exactly:
#
#   * space --create / --destroy / --move / --swap / --switch, and display --space
#   * window --toggle sticky|pip|shadow and scratchpads, --sub-layer, --opacity
#   * window shadows, transparency and animations
#
# Everything this config binds — `space --focus`, `window --space`, BSP tiling,
# `--toggle float|split|zoom-fullscreen` — is explicitly *not* SIP-gated.
#
# The practical consequence of losing `space --create`: the number of usable
# workspaces is however many Desktops exist in Mission Control. Bindings for
# spaces you have not created simply no-op.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The chord every binding hangs off, in skhd's "mod + mod - key" grammar.
  #
  # Deliberately not the plain `alt` that upstream's sample config uses. On this
  # machine that would collide twice:
  #
  #   * EurKEY is the default layout, and its whole accented-character layer
  #     hangs off right Option / AltGr (AltGr+a = ä, AltGr+e = €, …).
  #   * Ghostty binds alt+h, alt+l and alt+enter for tabs and fullscreen, and
  #     sets `macos-option-as-alt = "left"` precisely to keep AltGr free. A
  #     global hotkey beats the focused app, so `alt-h` would break tabs.
  #
  # Left Ctrl sits on the bottom-left corner key here thanks to
  # `system.keyboard.swapLeftCtrlAndFn`, which keeps this chord cheap to hit.
  #
  # skhd — unlike AeroSpace — can also address one side: `lalt` alone would give
  # single-modifier i3 ergonomics with AltGr untouched, at the cost of shadowing
  # Ghostty's own alt bindings unless those are dropped from its config too.
  mod = "ctrl + alt";

  spaces = map toString (lib.range 1 9);

  # ANSI virtual key codes. Symbol keys are given as codes rather than literals
  # because skhd's `mod - key` grammar makes a bare `-` or `=` ambiguous.
  keys = {
    minus = "0x1B";
    equal = "0x18";
    slash = "0x2C";
    comma = "0x2B";
  };

  directions = {
    h = "west";
    j = "south";
    k = "north";
    l = "east";
  };

  focusAndSwap = lib.concatStrings (
    lib.mapAttrsToList (key: dir: ''
      ${mod} - ${key} : yabai -m window --focus ${dir}
      ${mod} + shift - ${key} : yabai -m window --swap ${dir}
    '') directions
  );

  # `--focus` on a Space that does not exist just fails, so binding all nine is
  # harmless even with three Desktops.
  spaceBindings = lib.concatMapStrings (n: ''
    ${mod} - ${n} : yabai -m space --focus ${n}
    ${mod} + shift - ${n} : yabai -m window --space ${n} && yabai -m space --focus ${n}
  '') spaces;
in
{
  config = lib.mkIf config.services.yabai.enable {
    services.yabai = {
      package = lib.mkDefault pkgs.unstable.yabai;

      # The entire point of choosing yabai here was leaving SIP alone.
      enableScriptingAddition = lib.mkDefault false;

      config = {
        layout = "bsp";

        top_padding = 8;
        bottom_padding = 8;
        left_padding = 8;
        right_padding = 8;
        window_gap = 8;

        # New windows split the focused one, i3-style, instead of the parent.
        window_placement = "second_child";
        split_ratio = "0.50";
        auto_balance = "off";

        # Keyboard drives focus; the pointer resting over a window should not
        # steal it mid-retile.
        focus_follows_mouse = "off";
        mouse_follows_focus = "off";

        # Documented in yabai(1) as "only enable this if you do NOT use the
        # scripting addition" — which is exactly our case. Skips the macOS Space
        # animation when focusing a window on an inactive Space.
        skip_window_focus_animation = "on";

        # fn+drag to move, fn+right-drag to resize. Note `system.keyboard.swapLeftCtrlAndFn`
        # puts fn where Ctrl normally sits on this keyboard.
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
      };

      # Apps that are dialogs in all but name, or that resize badly under a
      # tiling layout. Mirrors the float rules the AeroSpace module carries.
      extraConfig = ''
        yabai -m rule --add app="^System Settings$"   manage=off
        yabai -m rule --add app="^Activity Monitor$"  manage=off
        yabai -m rule --add app="^Calculator$"        manage=off
        yabai -m rule --add app="^Photo Booth$"       manage=off
        yabai -m rule --add app="^zoom\.us$"          manage=off
        yabai -m rule --add app="^Finder$" title="Info$" manage=off
      '';
    };

    # yabai has no hotkey daemon of its own.
    services.skhd = {
      enable = true;
      package = lib.mkDefault pkgs.skhd;

      skhdConfig = ''
        # Generated from modules/darwin/services/window-manager/yabai.nix — edit there.
        # Chord: ${mod}   (that file explains why it is not plain alt)

        # --- focus / swap ---------------------------------------------------
        ${focusAndSwap}
        # --- spaces ---------------------------------------------------------
        # Only Spaces that exist in Mission Control respond; `space --create`
        # needs the scripting addition, so Desktops are made by hand.
        ${spaceBindings}
        # --- layout ---------------------------------------------------------
        ${mod} - ${keys.slash} : yabai -m space --layout bsp
        ${mod} - ${keys.comma} : yabai -m space --layout stack
        ${mod} - e : yabai -m window --toggle split
        ${mod} - f : yabai -m window --toggle zoom-fullscreen
        ${mod} - space : yabai -m window --toggle float
        ${mod} - r : yabai -m space --rotate 90
        ${mod} - y : yabai -m space --mirror y-axis
        ${mod} - 0 : yabai -m space --balance

        # --- resize ---------------------------------------------------------
        # Fall back to the opposite handle when the window has no neighbour on
        # the first one, so the binding works at either edge of the tree.
        ${mod} - ${keys.minus} : yabai -m window --resize right:-50:0 || yabai -m window --resize left:-50:0
        ${mod} - ${keys.equal} : yabai -m window --resize right:50:0 || yabai -m window --resize left:50:0

        # --- misc -----------------------------------------------------------
        ${mod} - return : open -na Ghostty
        ${mod} + shift - q : yabai -m window --close
        ${mod} + shift - r : launchctl kickstart -k gui/$(id -u)/org.nixos.yabai
      '';
    };

    # Restore the macOS default ("Displays have separate Spaces" ON). The
    # AeroSpace module turns this off, and `system.defaults` are write-only —
    # dropping the setting would leave the old value in place — so it is set
    # back explicitly here. Takes effect after a logout.
    system.defaults.spaces.spans-displays = lib.mkDefault false;
  };
}
