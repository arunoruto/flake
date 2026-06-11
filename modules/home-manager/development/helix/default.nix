{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  nightly = config.hosts.desktop.enable && (args ? osConfig);
in
{
  imports = [ ./keys.nix ];

  config = lib.mkIf config.programs.helix.enable {
    programs.helix = {
      package = lib.mkDefault pkgs.helix;
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
          indent-guides.render = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp = {
            auto-signature-help = false;
            display-messages = true;
          };
          file-picker.hidden = false;
        }
        // lib.optionalAttrs (config.programs.helix.package.pname == "steelix") {
          insecure = true;
        }
        // lib.optionalAttrs nightly {
          end-of-line-diagnostics = "warning";
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };
        };
      };

      ignores = [ ".build/" ];

      themes = {
        stylix-custom = {
          inherits = "stylix";

          "ui.statusline.normal" = {
            fg = "base00";
            bg = "base0D";
          };

          "ui.bufferline.active" = {
            fg = "base00";
            bg = "base0D";
            modifiers = [ "bold" ];
          };

          "ui.cursor.primary" = {
            fg = "base0D";
            modifiers = [ "reversed" ];
          };

          "ui.cursor.match" = {
            modifiers = [ "reversed" ];
          };
        };
      };
    };
  };
}
