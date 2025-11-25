{
  config,
  lib,
  ...
}:
{
  imports = [
    ./gdm.nix
    ./lightdm.nix
  ];

  options = {
    display-manager.enable = lib.mkEnableOption "Enable display manager support";
  };

  config = lib.mkIf config.display-manager.enable {
    # gdm.enable = lib.mkForce false;
    # lightdm.enable = lib.mkForce false;
    services = {
      displayManager.gdm.enable = lib.mkDefault true;
      xserver.displayManager.lightdm.enable = lib.mkDefault false;
    };
  };
}
