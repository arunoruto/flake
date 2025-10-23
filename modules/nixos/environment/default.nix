{
  lib,
  config,
  ...
}:
{
  imports = [
    ./programming

    ./packages.nix
    ./cachix.nix
    ./fonts.nix
    ./latex.nix
    ./ld.nix
    ./typst.nix
  ];

  cachix.enable = lib.mkDefault false;
  latex.enable = lib.mkDefault false;
  programs.typst.enable = config.latex.enable;

  environment.enableAllTerminfo = true;
}
