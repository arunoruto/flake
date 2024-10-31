{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.latex.enable = lib.mkEnableOption "Setup LaTeX for system";

  config = lib.mkIf config.latex.enable {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };
}
