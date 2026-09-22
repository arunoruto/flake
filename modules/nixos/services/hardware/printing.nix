# Brother drivers, applied whenever `services.printing` (CUPS) is on.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.printing.enable {
    services.printing.drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };
}
