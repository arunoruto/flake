{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bosflix = {
    enable = lib.mkEnableOption "Enable bosflix services";

    drivePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/hdd";
      description = "The path to the HDD";
    };
  };

  config =
    let
      cfg = config.bosflix;
      # completedPath = "/media/86336459-5d8c-448e-93c3-f3e17c00d3b9" + "/complete";
      completedPath = builtins.toString (cfg.drivePath + "/complete");
      incompletedPath = builtins.toString (cfg.drivePath + "/incomplete");
    in
    lib.mkIf cfg.enable {
      services = {
        prowlarr = {
          enable = true;
          package = pkgs.unstable.prowlarr;
          # settings = {
          #   server = {
          #     urlbase = "/prowlarr";
          #     AuthenticationMethod = "Forms";
          #     AuthenticationRequired = "DisabledForLocalAddresses";
          #   };
          # };
        };

        flaresolverr = {
          enable = true;
          package = pkgs.nur.repos.xddxdd.flaresolverr-21hsmw;
          # package = pkgs.unstable.flaresolverr;
        };

        syncthing = {
          enable = true;

          settings = {
            devices = {
              lil-nas-x = {
                addresses = [
                  "dynamic"
                  "tcp://lil-nas-x"
                  "tcp://lil-nas-x:22000"
                  "quic://lil-nas-x:22000"
                ];
                id = "ARZDFKU-CFAXQEM-ZTBEVH6-DGU7E55-JNLRTVM-VKG7JW5-D6B25X3-IRPISQH";
              };
              kuchiki = {
                addresses = [
                  "dynamic"
                  "tcp://kuchiki"
                  "tcp://kuchiki:22000"
                  "quic://kuchiki:22000"
                ];
                id = "C4TO46K-P5LXFD6-NULLWDR-A5MYGJ2-EQDBNOC-CZHYJNJ-33DJHWA-SPQ6RQ7";
              };
            };
            folders."downloads shinji" = {
              enable = true;
              path = completedPath;
              devices = [
                "lil-nas-x"
                "kuchiki"
              ];
            };
          };
        };

        deluge = {
          enable = false;
          web.enable = true;
          # declarative = true;
          config = {
            # download_location = "${cfg.drivePath}/incomplete";
            download_location = incompletedPath;
            move_completed = true;
            move_completed_path = completedPath;

            enabled_plugins = [ "Label" ];
          };
        };

        # transmission = {
        #   enable = true;
        # };

        sabnzbd.enable = true;
      };

      systemd =
        let
          cfg = config.services.sabnzbd;
        in
        {
          services.sabnzbd.serviceConfig.ExecStart =
            # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${cfg.configFile} --inet_exposure 5 --disable-file-log --console";
            lib.mkForce
              "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${cfg.configFile} -s 0.0.0.0:8082 --inet_exposure 5";

          tmpfiles.settings = {
            "sabnzbd" = {
              "/var/lib/sabnzbd".Z = {
                mode = "0755";
                inherit (cfg) user;
                inherit (cfg) group;
              };
              # "/var/lib/sabnzbd/logs".Z = {
              #   mode = "0755";
              #   user = cfg.user;
              #   group = cfg.group;
              # };
              # "/var/lib/sabnzbd/Downloads".Z = {
              #   mode = "0755";
              #   user = cfg.user;
              #   group = cfg.group;
              # };
            };
            "drive" = {
              "${completedPath}".Z = {
                mode = "0777";
                user = "root";
                group = "root";
              };
              "${completedPath}/.stfolder".Z =
                let
                  cfg = config.services.syncthing;
                in
                {
                  mode = "0755";
                  inherit (cfg) user;
                  inherit (cfg) group;
                };
              "${incompletedPath}".Z = {
                mode = "0777";
                user = "root";
                group = "root";
              };
            };
          };
        };
      # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${cfg.configFile} --inet_exposure 5 --console";
      # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${cfg.configFile} --inet_exposure 5";

      # nixpkgs.config.permittedInsecurePackages = [
      #   "aspnetcore-runtime-6.0.36"
      #   "aspnetcore-runtime-wrapped-6.0.36"
      #   "dotnet-runtime-6.0.36"
      #   "dotnet-runtime-wrapped-6.0.36"
      #   "dotnet-sdk-6.0.428"
      #   "dotnet-sdk-wrapped-6.0.428"
      # ];

      # environment.systemPackages = with pkgs.unstable; [ qbittorrent ];
    };
}
