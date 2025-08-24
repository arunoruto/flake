{
  osConfig,
  lib,
  ...
}@args:
{
  imports = [
    ./background
    ./foreground
    ./media
    ./theming
  ];

  options = {
    hosts = {
      laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";
      tinypc.enable = lib.mkEnableOption "Sensible defaults for tinypcs";
    };
  };

  config = lib.mkIf (args ? nixosConfig) {
    hosts = {
      laptop.enable = lib.mkDefault (lib.elem "laptop" osConfig.system.tags);
      tinypc.enable = lib.mkDefault (lib.elem "tinypc" osConfig.system.tags);
    };
    foreground.enable = lib.mkDefault osConfig.programs.enable;

    # hostname = lib.mkDefault osConfig.networking.hostName;
    keyboard = {
      layout = lib.mkDefault osConfig.services.xserver.xkb.layout;
      variant = lib.mkDefault osConfig.services.xserver.xkb.variant;
    };
    theming = {
      enable = lib.mkDefault osConfig.programs.enable;
      image = lib.mkDefault osConfig.theming.image;
      scheme = lib.mkDefault osConfig.theming.scheme;
    };
  };
}
