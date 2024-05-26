{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    printing.enable = lib.mkEnableOption "Enable printing support";
  };

  config = lib.mkIf config.printing.enable {
    # Enable the printing service
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cpuswrapper
      ];
    };
  };
}
