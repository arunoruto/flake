{
  config,
  lib,
  ...
}:
{
  imports = [
    ./drives.nix
    ./hd-idle.nix
    ./homepage.nix
    ./nfs.nix

    ./scrutiny
  ];

  options.nas.enable = lib.mkEnableOption "NAS utilities and config";

  config = lib.mkIf config.nas.enable {
    drives.enable = lib.mkDefault true;
    nfs.enable = lib.mkDefault false;

    services = {
      # scrutiny.enable = false;
      # hd-idle.enable = true;
    };
  };
}
