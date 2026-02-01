{
  inputs,
  lib,
  config,
  username,
  ...
}:
{
  imports = [
    ./desktop
    ./display
    ./environment
    ./gaming
    ./media
    ./programs
    ./security
    ./services
    ./system

    ./users

    # ./pr.nix
  ];

  desktop-environment.enable = lib.mkDefault true;
  display-manager.enable = lib.mkDefault true;
  services.media.enable = lib.mkDefault false;
  programs.enable = lib.mkDefault true;

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # extraOptions = config.home-manager.users.${username}.nix.extraOptions;
  };
}
