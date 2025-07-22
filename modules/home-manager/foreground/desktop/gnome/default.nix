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

    dconf.enable = lib.mkForce config.gnome.dconf.enable;

    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    home.packages =
      with pkgs.gnomeExtensions;
      [
        appindicator
        blur-my-shell
        emoji-copy
        framework-fan-control
        # focus
        forge
        pip-on-top
        tactile
        tiling-shell
        tophat
        # transparent-top-bar
        transparent-top-bar-adjustable-transparency
      ]
      ++ (with pkgs.unstable.gnomeExtensions; [
        # pip-on-top
        tailscale-status
        tailscale-qs
        # tiling-shell
      ]);
  };
}
