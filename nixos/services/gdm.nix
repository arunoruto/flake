{lib, ...}: {
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
      displayManager.preStart = "sleep 3";
    };
  };
}
