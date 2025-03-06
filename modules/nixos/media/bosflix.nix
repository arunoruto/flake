{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bosflix.enable = lib.mkEnableOption "Enable bosflix services";

  config = lib.mkIf config.bosflix.enable {
    services =
      let
        completedPath = "/mnt/hdd/complete";
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
            download_location = "/mnt/hdd/incomplete";
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
