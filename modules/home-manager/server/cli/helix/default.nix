# https://github.com/helix-editor/helix/wiki/Migrating-from-Vim
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  nightly = !config.hosts.tinypc.enable && (args ? nixosConfig);
  toml = pkgs.formats.toml { };
in
{
  imports = [
    ./keys.nix
    ./languages
  ];

  options.helix.enable = lib.mkEnableOption "Enable the Helix editor";

  config = lib.mkIf config.helix.enable {
    programs = {
      helix = {
        enable = true;
        package = if nightly then inputs.helix.packages.${pkgs.system}.default else pkgs.unstable.helix;
        # package = pkgs.helix;
        # package = pkgs.unstable.helix;
        # package = pkgs.unstable.evil-helix;
        settings = {
          theme = lib.mkForce "my-stylix";
          editor =
            {
              true-color = true;
              bufferline = "always";
              line-number = "relative";
              rulers = [ 80 ];
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
      };
      # zsh.shellAliases.vim = "hx";
    };

    home.file.".config/helix/themes/my-stylix.toml".source = toml.generate "my-stylix.toml" {
      inherits = "stylix";
      "ui.cursor.match" = {
        fg = "base08";
        modifiers = [ "reversed" ];
      };
    };
  };
}
