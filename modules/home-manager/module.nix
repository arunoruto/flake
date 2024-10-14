args @ {
  osConfig,
  lib,
  ...
}: {
  # imports = [
  #   ./standalone.nix
  # ];
  config = lib.mkIf (args ? nixosConfig) {
    hostname = osConfig.networking.hostName;
    keyboard = {
      layout = osConfig.services.xserver.xkb.layout;
      variant = osConfig.services.xserver.xkb.variant;
    };
    theming = {
      image = osConfig.theming.image;
      scheme = osConfig.theming.scheme;
    };
  };
}
