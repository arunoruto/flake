{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  shell.main = "zsh";
  nushell.enable = true;
  fish.enable = true;
}
