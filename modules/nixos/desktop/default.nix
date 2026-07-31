{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dm

    ./gnome.nix
    ./hyprland.nix
    ./kodi.nix
    ./sway.nix
    ./niri.nix

    ./wayland.nix
  ];

  options.desktop-environment.enable = lib.mkEnableOption "Enable desktop environment and window manager support";

  config = lib.mkIf config.desktop-environment.enable {
    # DEs
    services.desktopManager = {
      gnome.enable = lib.mkDefault true;
      cosmic.enable = lib.mkDefault false;
      plasma6.enable = lib.mkDefault false;
    };

    # WMs
    programs = {
      sway.enable = lib.mkDefault false;
      hyprland.enable = lib.mkDefault false;
    };

    # Compositor
    wayland.enable = lib.mkDefault true;

    services.xserver = {
      desktopManager = {
        kodi.enable = lib.mkDefault false;
      };

      enable = true;
      xkb = {
        layout = "de";
        variant = "us";
        # layout = "us";
        # variant = "altgr-intl";
      };
      excludePackages = with pkgs; [
        xterm
      ];
      exportConfiguration = true;
    };
  };
}
