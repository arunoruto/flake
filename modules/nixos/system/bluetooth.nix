{ lib, config, ... }:
{
  config = lib.mkIf config.hardware.facter.detected.bluetooth.enable {
    hardware.bluetooth.settings = {
      Policy = {
        AutoEnable = !(config.lib.tags.hasTag "laptop");
      };
    };
  };
}
