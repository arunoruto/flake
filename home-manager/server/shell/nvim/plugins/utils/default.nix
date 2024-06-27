{
  imports = [
    ./actions-preview.nix
    ./comment.nix
    ./hardtime.nix
    ./indent-blankline.nix
    ./leap.nix
    ./telescope.nix
    ./ufo.nix
    ./which-key.nix
  ];

  programs.nixvim = {
    plugins = {
      # undotree.enbale = true;
    };
  };
}
