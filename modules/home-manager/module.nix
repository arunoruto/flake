{osConfig, ...}: {
  # imports = [
  #   ./standalone.nix
  # ];

  hostname = osConfig.networking.hostName;
  keyboard = {
    layout = osConfig.services.xserver.xkb.layout;
    variant = osConfig.services.xserver.xkb.variant;
  };
}
