{
  imports = [
    ./gdm.nix
    ./lightdm.nix
  ];

  gdm.enbale = false;
  lightdm.enable = true;
}
