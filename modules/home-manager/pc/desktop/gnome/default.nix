{
  lib,
  pkgs,
  config,
  ...
}:
{
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

    home.packages =
      (with pkgs.gnomeExtensions; [
        appindicator
        emoji-copy
        # focus
        tailscale-status
        # tiling-shell
        # transparent-top-bar
        transparent-top-bar-adjustable-transparency
      ])
      ++ (with pkgs.unstable.gnomeExtensions; [
        pip-on-top
        tiling-shell
      ]);
  };
}
