{
  pkgs,
  lib,
  ...
}: {
  options = {
    lightdm.enable = lib.mkEnableOption "Use light display manager";
  };

  config = {
    services = {
      xserver = {
        displayManager = {
          lightdm.enable = true;
        };
      };
      # displayManager.preStart = "sleep 1";
    };

    programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse.out}/bin/seahorse";
  };
}
