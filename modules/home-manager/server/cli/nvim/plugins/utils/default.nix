{
  imports = [
    ./actions-preview.nix
    ./comment.nix
    # ./hardtime.nix
    ./indent-blankline.nix
    ./leap.nix
    ./startuptime.nix
    ./telescope.nix
    # ./ufo.nix
    ./which-key.nix
    ./vim-maximizer.nix
  ];

  programs.nixvim = {
    plugins = {
      # undotree.enbale = true;
    };
  };
}
