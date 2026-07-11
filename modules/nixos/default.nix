{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./desktop
    ./environment
    ./programs
    ./security
    ./services
    ./system

    ./users

  ];

  services.media.enable = lib.mkDefault false;

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
