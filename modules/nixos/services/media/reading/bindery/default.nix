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
      package = pkgs.bindery.overrideAttrs (
        final: prev: {
          src = pkgs.fetchFromGitHub {
            owner = "arunoruto";
            repo = "bindery";
            rev = "924618a458e5d2efe11728a8015eff8a1764d921";
            hash = "sha256-+R3R9hucbNdqrPFYM1X3WMyPwySKhYwvVDtFHcTi/t4=";
          };
          vendorHash = "sha256-cpwLh/JR0KFTQcglp7kn9Zaf6dJ+RlQ9Kdembub8q/s=";
        }
      );
      dataDir = "${config.services.media.dataDir}/bindery";
      openFirewall = lib.mkDefault config.services.media.openFirewall;

      environmentFiles = [
        (pkgs.writeTextFile {
          name = "bindery-env";
          text = ''
            BINDERY_LIBRARY_DIR=/mnt/flash/books
            BINDERY_DOWNLOAD_DIR=/mnt/flash/downloads/mirza-books
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
