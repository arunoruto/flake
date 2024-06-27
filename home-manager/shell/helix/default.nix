# https://github.com/helix-editor/helix/wiki/Migrating-from-Vim
{
  imports = [
    ./keys.nix
    ./languages
  ];

  programs = {
    helix = {
      enable = true;
      settings = {
        # theme = "catppuccin_macchiato";
        # theme = "base16_transparent";
        editor = {
          true-color = true;
          bufferline = "always";
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          indent-guides = {
            render = true;
          };
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp.display-messages = true;
        };
      };
      ignores = [
        ".build/"
      ];
    };
    # zsh.shellAliases.vim = "hx";
  };
}
