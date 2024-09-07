{
  lib,
  config,
  ...
}: {
  imports = [
    ./dconf.nix
    ./theming.nix
  ];

  options.gnome.enable = lib.mkEnableOption "Enable custom GNOME config";

  config = lib.mkIf config.gnome.enable {
    gnome = {
      dconf.enable = lib.mkDefault true;
      theming.enable = lib.mkDefault true;
    };
  };
}
