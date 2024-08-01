{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./kde.nix
    ./sway.nix
  ];

  options = {
    desktop-environment.enable = lib.mkEnableOption "Enable desktop environment and window manager support";
  };

  config = lib.mkIf config.desktop-environment.enable {
    # gnome.enable = lib.mkForce false;
    # kde.enable = lib.mkForce false;
    # sway.enable = lib.mkForce false;
    # hyprland.enable = lib.mkForce false;

    gnome.enable = lib.mkDefault true;
    kde.enable = lib.mkDefault false;
    sway.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;

    services.xserver = {
      enable = true;
      xkb = {
        layout = "de";
        variant = "";
      };
      excludePackages = with pkgs; [
        xterm
      ];
    };
  };
}
