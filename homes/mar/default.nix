{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  shell = "zsh";
  nushell.enable = true;
  fish.enable = true;
}
