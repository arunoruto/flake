{
  lib,
  ...
}:
{
  imports = [
    ./bat.nix
    ./btop.nix
  ];

  config = {
    programs = {
      bat.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      lsd.enable = lib.mkDefault false;
    };
  };
}
