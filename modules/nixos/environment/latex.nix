{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.programs.latex.enable = lib.mkEnableOption "LaTeX (texlive scheme-full) system-wide";

  config = lib.mkIf config.programs.latex.enable {
    environment.systemPackages = with pkgs; [ texlive.combined.scheme-full ];
  };
}
