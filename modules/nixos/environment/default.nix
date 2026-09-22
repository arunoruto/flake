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

  programs.typst.enable = config.programs.latex.enable;

  environment.enableAllTerminfo = true;
}
