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
    in
    lib.mkIf cfg.enable {
      services =
        let
          # completedPath = "/media/86336459-5d8c-448e-93c3-f3e17c00d3b9" + "/complete";
          completedPath = builtins.toString (cfg.drivePath + "/complete");
          incompletedPath = builtins.toString (cfg.drivePath + "/incomplete");
        in
        {
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
            guiAddress = "0.0.0.0:8384";

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
              };
              folders."downloads shinji" = {
                enable = true;
                path = completedPath;
                devices = [ "lil-nas-x" ];
              };
            };
          };

          deluge = {
            enable = true;
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
        };

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
