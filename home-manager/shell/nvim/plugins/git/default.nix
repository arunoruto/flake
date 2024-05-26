{
  imports = [
    ./gitsigns.nix
    # ./lazygit.nix
    # ./neogit.nix
  ];

  programs.nixvim = {
    plugins = {
      # lazygit.enable = true;
      neogit.enable = true;
    };
  };
}
