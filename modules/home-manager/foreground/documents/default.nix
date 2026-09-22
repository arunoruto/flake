{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./libreoffice.nix
  ];

  config = lib.mkIf (config.foreground.enable && pkgs.stdenv.hostPlatform.isLinux) {
    programs = {
      libreoffice.enable = lib.mkDefault true;
      onlyoffice.enable = lib.mkDefault false;
    };
  };
}
