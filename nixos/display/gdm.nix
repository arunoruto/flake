{
  pkgs,
  lib,
  ...
}: {
  options = {
    gdm.enable = lib.mkEnableOption "Use gnome display manager";
  };

  config = {
    services = {
      xserver = {
        displayManager = {
          gdm.enable = true;
        };
      };
      displayManager.preStart = "sleep 1";
    };

    programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse.out}/bin/seahorse";
  };
}
