{
  config,
  lib,
  ...
}: {
  options.touchpad.enable = lib.mkEnableOption "Configuration for touchpad";

  config = lib.mkIf config.touchpad.enable {
    services = {
      libinput.enable = true;
      touchegg = {
        enable = true;
      };
    };
  };
}
