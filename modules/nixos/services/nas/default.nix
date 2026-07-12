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
    ./samba.nix

    ./scrutiny
  ];

  options.nas.enable = lib.mkEnableOption "NAS utilities and config";

  config = lib.mkMerge [
    (lib.mkIf config.nas.enable {
      drives.enable = lib.mkDefault true;
      nfs.enable = lib.mkDefault false;

      services = {
        # scrutiny.enable = false;
        # hd-idle.enable = true;
      };
    })
    (lib.mkIf (config.lib.tags.hasTag "nas") {
      services.samba.enable = lib.mkDefault true;
    })
  ];
}
