{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  # Platform and nixpkgs configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = [
      self.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    helix
    nh
  ];

  # Networking
  services.tailscale.enable = true;
  networking.hostName = "tensa";

  # Primary user configuration (shared between NixOS and Darwin)
  users.primaryUser = "mirza";

  # Stylix theming configuration
  stylix = {
    image = ../../../modules/home-manager/theming/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";
  };

  # Darwin-specific modules configuration
  darwin = {
    homebrew = {
      enable = true;
      user = "mirza";
      casks = [ "zoom" ];
    };

    security.touchid.enable = true;

    system = {
      defaults.enable = true;
      nix.enable = true;
    };
  };

  # State version
  system.stateVersion = 6;
}
