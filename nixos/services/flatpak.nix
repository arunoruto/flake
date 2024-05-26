{
  config,
  lib,
  ...
}: {
  options = {
    flatpak.enable = lib.mkEnableOption "flatpak";
  };
  config = lib.mkIf config.flatpak.enable {
    # Flatpak for more package potions
    services.flatpak.enable = true;
  };
}
