{
  osConfig,
  lib,
  ...
}@args:
{
  imports = [
    ./media
    ./pc
    ./server
    ./theming
  ];

  options = {
    laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";
    tinypc.enable = lib.mkEnableOption "Sensible defaults for tinypcs";
  };

  config = lib.mkIf (args ? nixosConfig) {
    laptop.enable = lib.mkDefault osConfig.laptop.enable;
    tinypc.enable = lib.mkDefault osConfig.tinypc.enable;
    pc.enable = lib.mkDefault osConfig.gui.enable;

    hostname = lib.mkDefault osConfig.networking.hostName;
    keyboard = {
      layout = lib.mkDefault osConfig.services.xserver.xkb.layout;
      variant = lib.mkDefault osConfig.services.xserver.xkb.variant;
    };
    theming = {
      enable = lib.mkDefault osConfig.gui.enable;
      image = lib.mkDefault osConfig.theming.image;
      scheme = lib.mkDefault osConfig.theming.scheme;
    };
  };
}
