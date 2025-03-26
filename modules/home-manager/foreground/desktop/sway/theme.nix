{ pkgs, ... }:
let
  flavor = "Macchiato";
  catppuccin_sway = "";
in
# catppuccin_sway = builtins.fetchGit {
#   url = "https://github.com/catppuccin/i3";
#   ref = "main";
# };
{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      include catppuccin-macchiato
    '';
    # config = rec {
    #   colors = {
    #     focused = {
    #       background  = "$base";
    #       border      = "$lavender";
    #       childBorder = "$lavender";
    #       indicator   = "$rosewater";
    #       text        = "$text";
    #     };
    #     focusedInactive = {
    #       background  = "$base";
    #       border      = "$overlay0";
    #       childBorder = "$overlay0";
    #       indicator   = "$rosewater";
    #       text        = "$text";
    #     };
    #     unfocused = {
    #       background  = "$base";
    #       border      = "$overlay0";
    #       childBorder = "$overlay0";
    #       indicator   = "$overlay0";
    #       text        = "$text";
    #     };
    #     urgent = {
    #       background  = "$base";
    #       border      = "$peach";
    #       childBorder = "$peach";
    #       indicator   = "$overlay0";
    #       text        = "$peach";
    #     };
    #     placeholder = {
    #       background  = "$base";
    #       border      = "$overlay0";
    #       childBorder = "$overlay0";
    #       indicator   = "$overlay0";
    #       text        = "$text";
    #     };
    #     background = "$base";
    #   };
    #   bars = [
    #     {
    #       position = "top";
    #       mode = "dock";
    #       hiddenState = "hide";
    #       command = "${pkgs.waybar}/bin/waybar";
    #       #command = "${pkgs.sway}/bin/swaybar";
    #       #statusCommand = "${pkgs.i3status}/bin/i3status";
    #       workspaceButtons = true;
    #       workspaceNumbers = false;
    #       trayOutput = "primary";
    #       colors = {
    #         background         = "$base";
    #         statusline         = "$text";
    #         focusedStatusline = "$text";
    #         focusedSeparator  = "$base";
    #         focusedWorkspace  = {
    #           border      = "$base";
    #           background  = "$base";
    #           text        = "$green";
    #         };
    #         activeWorkspace    = {
    #           border      = "$base";
    #           background  = "$base";
    #           text        = "$blue";
    #         };
    #         inactiveWorkspace = {
    #           border      = "$base";
    #           background  = "$base";
    #           text        = "$surface1";
    #         };
    #         urgentWorkspace   = {
    #           border      = "$base";
    #           background  = "$base";
    #           text        = "$peach";
    #         };
    #         bindingMode       = {
    #           border      = "$base";
    #           background  = "$base";
    #           text        = "$surface1";
    #         };
    #       };
    #     }
    #   ];
    # };
  };

  # Catppuccin themes for sway
  # home.file.".config/sway/catppuccin-macchiato".source = "${catppuccin_sway}/themes/catppuccin-macchiato";
}
