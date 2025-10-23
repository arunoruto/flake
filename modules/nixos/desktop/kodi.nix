{
  config,
  pkgs,
  lib,
  flake,
  ...
}:
let
  kodi-user = "kodi";
in
{
  config = lib.mkIf config.services.xserver.desktopManager.kodi.enable {
    services = {
      xserver = {
        desktopManager.kodi = {
          package = pkgs.unstable.kodi.withPackages (
            kodiPkgs: with kodiPkgs; [
              jellycon
              netflix
              youtube

              pkgs.kodiPackages.elementum
            ]
          );
        };
        displayManager.lightdm.greeter.enable = false;
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = kodi-user;
        };
      };
    };

    # Define a user account
    users.extraUsers.${kodi-user}.isNormalUser = true;

    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };

    # environment.systemPackages = [ pkgs.elementum ];

    # systemd.services = {
    #   kodi-http-fix-plugin = {
    #     description = "Fix HTTPS to HTTP for Kodi addons";
    #     after = [ "network.target" ];
    #     wantedBy = [ "multi-user.target" ];
    #     serviceConfig = {
    #       Type = "oneshot";
    #       ExecStart = ''
    #         ${lib.getExe pkgs.bash} -c 'find /home/kodi/.kodi/addons/plugin.program.robinhood -type f -exec sed -i "s|https://robinhoodtv.com|http://robinhoodtv.com|g" {} +'
    #         ${lib.getExe pkgs.bash} -c 'find /home/kodi/.kodi/addons/plugin.program.robinhood -type f -exec sed -i "s|https://robinhoodtvpro.com|http://robinhoodtvpro.com|g" {} +'
    #       '';
    #       RemainAfterExit = true;
    #     };
    #   };
    #   kodi-http-fix-repository = {
    #     description = "Fix HTTPS to HTTP for Kodi addons";
    #     after = [ "network.target" ];
    #     wantedBy = [ "multi-user.target" ];
    #     serviceConfig = {
    #       Type = "oneshot";
    #       ExecStart = ''
    #         ${lib.getExe pkgs.bash} -c 'find /home/kodi/.kodi/addons/repository.robinhood.wizard -type f -exec sed -i "s|https://robinhoodtv.com|http://robinhoodtv.com|g" {} +'
    #       '';
    #       RemainAfterExit = true;
    #     };
    #   };
    # };

    # nixpkgs.pkgs = pkgs.extend flake.overlays.kodi;
  };
}
