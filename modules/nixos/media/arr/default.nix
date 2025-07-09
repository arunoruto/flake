{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
  ];

  options.services.arr.enable = lib.mkEnableOption "Enable arr frameworks";

  config = lib.mkIf config.services.arr.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        arr = {
          radarr.enable = lib.mkDefault true;
          sonarr.enable = lib.mkDefault true;
        };
        bazarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.bazarr;
          # dataDir = lib.mkDefault "${cfg.dataDir}/bazarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
        recyclarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.recyclarr;
        };
      };

    users.users = {
      bazarr.extraGroups = [ config.users.groups.media.name ];
      recyclarr.extraGroups = [ config.users.groups.media.name ];
    };
  };
}
