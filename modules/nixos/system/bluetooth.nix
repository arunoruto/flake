{ lib, config, ... }:
{
  config = lib.mkIf config.facter.detected.bluetooth.enable {
    hardware.bluetooth.settings = {
      Policy = {
        AutoEnable = !(lib.elem "laptop" config.system.tags);
      };
    };
  };
}
