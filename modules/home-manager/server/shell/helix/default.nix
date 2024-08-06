# https://github.com/helix-editor/helix/wiki/Migrating-from-Vim
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./keys.nix
    ./languages
  ];

  options.helix.enable = lib.mkEnableOption "Enable the Helix editor";

  config = lib.mkIf config.helix.enable {
    programs = {
      helix = {
        enable = true;
        package = pkgs.unstable.helix;
        # package = pkgs.unstable.evil-helix;
        settings = {
          # theme = "catppuccin_macchiato";
          # theme = "base16_transparent";
          editor = {
            true-color = true;
            bufferline = "always";
            line-number = "relative";
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
            # inline-diagnostics = {
            #   cursor-line = "hint";
            #   other-lines = "error";
            # };
            lsp.display-messages = true;
          };
        };
        ignores = [
          ".build/"
        ];
      };
      # zsh.shellAliases.vim = "hx";
    };
  };
}
