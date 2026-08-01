{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.displayManager.gdm.enable {
    # The login screen must never suspend the machine — a headless-ish
    # desktop would drop offline at the greeter. Users in a session stay
    # free to suspend; the polkit rule below is scoped to the gdm user.
    services = {
      displayManager = {
        gdm = {
          autoSuspend = false;
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

    # Deny suspend/hibernate requests coming from the login screen only.
    # An unscoped rule here used to block the suspend button for every
    # logged-in user on every GDM host.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (subject.user == "gdm" &&
              (action.id == "org.freedesktop.login1.suspend" ||
               action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
               action.id == "org.freedesktop.login1.hibernate" ||
               action.id == "org.freedesktop.login1.hibernate-multiple-sessions"))
          {
              return polkit.Result.NO;
          }
      });
    '';
  };
}
