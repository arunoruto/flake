{
  config,
  lib,
  ...
}:
{
  # imports = [
  #   ./gdm.nix
  #   ./lightdm.nix
  # ];

  options = {
    display-manager.enable = lib.mkEnableOption "Enable display manager support";
  };

  config = lib.mkIf config.display-manager.enable {
    # gdm.enable = lib.mkForce false;
    # lightdm.enable = lib.mkForce false;
    gdm.enable = lib.mkDefault true;
    lightdm.enable = lib.mkDefault false;
  };
}
