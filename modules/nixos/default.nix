{lib, ...}: {
  imports = [
    ./desktop
    ./display
    ./environment
    ./media
    ./network
    ./services
    ./system

    # ./pr.nix

    ./user.nix
  ];

  desktop-environment.enable = lib.mkDefault true;
  display-manager.enable = lib.mkDefault true;
  media.enable = lib.mkDefault false;
  gui.enable = lib.mkDefault true;
}
