{
  config,
  pkgs,
  lib,
  ...
}: let
  kodi-user = "kodi";
in {
  options = {
    kodi.enable = lib.mkEnableOption "Use KODi as a desktop environment";
  };

  config = lib.mkIf config.kodi.enable {
    services = {
      xserver = {
        desktopManager.kodi = {
          enable = true;
          package = pkgs.kodi.withPackages (pkgs:
            with pkgs; [
              jellycon
              netflix
              youtube
            ]);
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
      allowedTCPPorts = [8080];
      allowedUDPPorts = [8080];
    };
  };
}
