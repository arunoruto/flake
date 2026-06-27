{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./module.nix ];

  config = lib.mkIf config.services.bindery.enable {
    services.bindery = {
      package = pkgs.bindery;
      dataDir = "${config.services.media.dataDir}/bindery";
      openFirewall = lib.mkDefault config.services.media.openFirewall;

      environmentFiles = [
        (pkgs.writeTextFile {
          name = "bindery-env";
          text = ''
            BINDERY_LIBRARY_DIR=/mnt/flash/books
            BINDERY_DOWNLOAD_DIR=/mnt/flash/downloads/books
            BINDERY_CONTACT=mirza.arnaut45@gmail.com
          '';
        }).outPath
      ];
    };

    users.users.bindery.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
