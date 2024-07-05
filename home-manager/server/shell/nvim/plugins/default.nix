{pkgs, ...}: {
  imports = [
    ./coding
    # ./completion
    # ./debug
    # ./git
    # ./notes
    # ./lsp
    # ./research
    ./ui
    ./utils

    # ./auto-session.nix
    # ./linting.nix
    ./lz-n.nix
    # ./nvim-tree.nix
    # ./substitute.nix
    ./treesitter.nix
    # ./trouble.nix
  ];

  programs.nixvim = {
    plugins = {
      bufferline = {
        enable = true;
        mode = "tabs";
        separatorStyle = "slant";
      };
      #dressing.enable = true;
      surround.enable = true;
      #startup-nvim.enable = true;
      tmux-navigator.enable = true;
      # https://ejmastnak.com/tutorials/vim-latex/vimscript/
      # vimtex.enable = true;
      # nix.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      cheatsheet-nvim
      # plenary-nvim # Used by many plugins as dependency
    ];
  };
}
