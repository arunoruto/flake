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
          gdm = {
            enable = true;
            autoSuspend = !config.hosts.laptop.enable;
          };
        };
      };
      # displayManager.preStart = "sleep 1";
    };

    programs = {
      # ssh.askPassword = lib.mkForce "${pkgs.seahorse.out}/bin/seahorse";
      ssh.askPassword = lib.mkForce "${lib.getExe pkgs.seahorse}";
      dconf.profiles.gdm.databases = [
        {
          settings = {
            "org/gnome/settings-daemon/plugins/power" = {
              ambient-enabled = false;
              sleep-inactive-ac-timeout = lib.gvariant.mkUint32 0;
            };
            "org/gnome/login-screen" = {
              # enable-fingerprint-authentication = false;
              # enable-smartcard-authentication = false;
            };
          };
        }
      ];
    };

    # Disable auto suspend on login screen
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.login1.suspend" ||
              action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
              action.id == "org.freedesktop.login1.hibernate" ||
              action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
          {
              return polkit.Result.NO;
          }
      });
    '';
  };
}
