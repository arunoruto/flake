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
    ./media
    ./network
    ./programs
    ./security
    ./services
    ./system

    # ./pr.nix

    ./user.nix
  ];

  desktop-environment.enable = lib.mkDefault true;
  display-manager.enable = lib.mkDefault true;
  media.enable = lib.mkDefault false;
  programs.enable = lib.mkDefault true;

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # extraOptions = config.home-manager.users.${username}.nix.extraOptions;
  };
}
