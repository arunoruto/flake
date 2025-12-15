{
  lib,
  ...
}:
{
  imports = [
    ./bat.nix
    ./btop.nix
    ./ls.nix
  ];

  config = {
    programs = {
      bat.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      lsd.enable = lib.mkDefault false;
    };
  };
}
