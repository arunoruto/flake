{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  shell.main = "fish";
  fish.enable = true;
  nushell.enable = true;
  zsh.enable = true;
}
