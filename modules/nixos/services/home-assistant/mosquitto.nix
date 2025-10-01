{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.mosquitto.enable {
    package = pkgs.unstable.mosquitto;
  };
}
