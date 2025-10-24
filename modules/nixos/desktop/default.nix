{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # ./cosmic.nix
    ./gnome.nix
    ./hyprland.nix
    # ./kde.nix
    ./kodi.nix
    ./sway.nix
    ./niri.nix

    ./wayland.nix
  ];

  options.desktop-environment.enable = lib.mkEnableOption "Enable desktop environment and window manager support";

  config = lib.mkIf config.desktop-environment.enable {
    # DEs
    services.desktopManager = {
      cosmic.enable = lib.mkDefault true;
      plasma6.enable = lib.mkDefault false;
    };

    # WMs
    programs = {
      sway.enable = lib.mkDefault false;
      hyprland.enable = lib.mkDefault true;
    };

    # Compositor
    wayland.enable = lib.mkDefault true;

    services.xserver = {
      desktopManager = {
        gnome.enable = lib.mkDefault true;
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
