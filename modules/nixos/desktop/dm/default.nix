{
  imports = [
    ./gdm.nix # applies whenever services.displayManager.gdm is on
    ./lightdm.nix # applies whenever services.xserver.displayManager.lightdm is on
  ];
}
