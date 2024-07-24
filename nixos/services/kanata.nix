{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    kanata.enable = lib.mkEnableOption "Enable kanata for keyboard remapping";
  };

  config = lib.mkIf config.kanata.enable {
    services.kanata = {
      enable = true
    };
  };
}
