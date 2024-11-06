{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  shell = "fish";
  fish.enable = true;
  nushell.enable = true;
  zsh.enable = true;
}
