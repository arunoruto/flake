{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    gdm.enable = lib.mkEnableOption "Use gnome display manager";
  };

  config = lib.mkIf config.gdm.enable {
    services = {
      xserver = {
        displayManager = {
          gdm.enable = true;
        };
      };
      # displayManager.preStart = "sleep 1";
    };

    programs = {
      ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse.out}/bin/seahorse";
      dconf.profiles.gdm.databases = [
        {
          settings = {
            "org/gnome/settings-daemon/plugins/power" = {
              ambient-enabled = false;
            };
            "org/gnome/login-screen" = {
              # enable-fingerprint-authentication = false;
              # enable-smartcard-authentication = false;
            };
          };
        }
      ];
    };
  };
}
