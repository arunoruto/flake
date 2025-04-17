{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.programs.typst.enable = lib.mkEnableOption "Setup Typst for system";

  config = lib.mkIf config.programs.typst.enable {
    environment.systemPackages = with pkgs.unstable; [
      typst
      tinymist
    ];
  };
}
