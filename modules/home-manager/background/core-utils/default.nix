{
  lib,
  ...
}:
{
  imports = [
    ./bat.nix
    ./ls.nix
    ./top.nix
  ];

  config = {
    programs = {
      bat.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      lsd.enable = lib.mkDefault false;

      below.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;
      htop.enable = lib.mkDefault true;
    };
  };
}
