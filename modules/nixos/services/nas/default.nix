{
  config,
  lib,
  ...
}:
{
  imports = [
    ./drives.nix
    ./nfs.nix
  ];

  options.nas.enable = lib.mkEnableOption "NAS utilities and config";

  config = lib.mkIf config.nas.enable {
    drives.enable = lib.mkDefault true;
    nfs.enable = lib.mkDefault false;
  };
}
