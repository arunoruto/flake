{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  shell = "zsh";
  fish.enable = true;
  nushell.enable = true;
  # shell = "nushell";
  # zsh.enable = true;
}
