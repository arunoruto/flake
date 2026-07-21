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

  # NAS config follows the `nas` tag rather than a separate enable option.
  config = lib.mkIf (config.lib.tags.hasTag "nas") {
    drives.enable = lib.mkDefault true;
    nfs.enable = lib.mkDefault false;
    services.samba.enable = lib.mkDefault true;
  };
}
