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
    ./sway.nix

    ./wayland.nix
  ];

  options.desktop-environment.enable = lib.mkEnableOption "Enable desktop environment and window manager support";

  config = lib.mkIf config.desktop-environment.enable {
    # DEs
    # cosmic.enable = lib.mkDefault false;
    gnome.enable = lib.mkDefault true;
    # kde.enable = lib.mkDefault false;

    # WMs
    sway.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;

    # Compositor
    wayland.enable = lib.mkDefault true;

    services.xserver = {
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
