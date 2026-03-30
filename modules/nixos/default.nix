{
  inputs,
  lib,
  config,
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

  services.media.enable = lib.mkDefault false;

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
