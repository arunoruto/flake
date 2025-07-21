{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./recyclar.nix
    ./prowlarr.nix
  ];

  options.services.arr.enable = lib.mkEnableOption "Enable arr frameworks";

  config = lib.mkIf config.services.arr.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        bazarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.bazarr;
          # dataDir = lib.mkDefault "${cfg.dataDir}/bazarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
      };

    users.users = {
      bazarr.extraGroups = lib.optionals (config.users.groups ? "media") [
        config.users.groups.media.name
      ];
    };
  };
}
