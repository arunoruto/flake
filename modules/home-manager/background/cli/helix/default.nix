# https://github.com/helix-editor/helix/wiki/Migrating-from-Vim
{
  config,
  lib,
  pkgs,
  # inputs,
  ...
}@args:
let
  nightly = !config.hosts.tinypc.enable && (args ? nixosConfig);
in
# toml = pkgs.formats.toml { };
{
  imports = [
    ./keys.nix
    ./languages
    # ./unibear.nix
  ];

  config = lib.mkIf config.programs.helix.enable {
    programs.helix = {
      # package = if nightly then inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default else pkgs.unstable.helix;
      package = pkgs.unstable.helix;
      defaultEditor = true;
      settings = {
        theme = lib.mkForce "stylix-custom";
        editor = {
          true-color = true;
          bufferline = "always";
          line-number = "relative";
          rulers = [ 80 ];
          soft-wrap.enable = false;
          cursorline = true;
          color-modes = true;
          popup-border = "all";
          indent-guides = {
            render = true;
          };
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp = {
            auto-signature-help = false;
            display-messages = true;
          };
          file-picker = {
            hidden = false;
          };
        }
        // lib.optionalAttrs nightly {
          end-of-line-diagnostics = "warning";
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };
        };
      };
      ignores = [
        ".build/"
      ];
      themes = {
        stylix-custom = {
          # inherits styling and pallet from the default stylix helix theme
          inherits = "stylix";

          # Normal Mode Indicator at the bottom left background base0D with base00 text
          "ui.statusline.normal" = {
            fg = "base00";
            bg = "base0D";
          };

          # Makes the active buffer in the bufferline background base0D, foreground font is bold
          "ui.bufferline.active" = {
            fg = "base00";
            bg = "base0D";
            modifiers = [ "bold" ];
          };

          # Primary selection is base0D
          "ui.cursor.primary" = {
            fg = "base0D";
            modifiers = [ "reversed" ];
          };

          # Matching brackets/quotes are underlined with color base0A
          "ui.cursor.match" = {
            # fg = "base0A";
            # underline.style = "line";
            modifiers = [ "reversed" ];
          };
        };
      };
    };

    # home.file.".config/helix/themes/my-stylix.toml".source = toml.generate "my-stylix.toml" {
    #   inherits = "stylix";
    #   # "ui.selection" = {
    #   #   fg = "base0A";
    #   # };
    #   # "ui.selection.primary" = {
    #   #   fg = "base02";
    #   # };
    #   "ui.cursor" = {
    #     fg = "base0B";
    #     modifiers = [ "reversed" ];
    #   };
    #   "ui.cursor.primary" = {
    #     fg = "base0A";
    #     modifiers = [ "reversed" ];
    #   };
    #   "ui.cursor.match" = {
    #     fg = "base0A";
    #     modifiers = [ "underlined" ];
    #   };
    #   # ui.cursor = {
    #   #   fg = "base0B";
    #   #   modifiers = [ "reversed" ];
    #   #   primary = {
    #   #     fg = "base0A";
    #   #     modifiers = [ "reversed" ];
    #   #   };
    #   #   match = {
    #   #     fg = "base0A";
    #   #     modifiers = [ "underlined" ];
    #   #   };
    #   # };
    # };
  };
}
