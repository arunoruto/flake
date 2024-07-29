{
  imports = [
    ./gdm.nix
    ./lightdm.nix
  ];

  gdm.enable = true;
  lightdm.enable = false;
}
