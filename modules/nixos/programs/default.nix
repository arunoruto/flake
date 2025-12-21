{
  lib,
  config,
  ...
}:
{
  imports = [
    ./browsers
    ./matlab
    ./steam.nix
    ./packages.nix
  ];

  options.programs.enable = lib.mkEnableOption "Setup GUI Modules";

  config = lib.mkIf config.programs.enable {
    programs.packages.enable = lib.mkDefault true;

    browsers.enable = lib.mkDefault true;
    # TODO: make tag for gaming
    steam.enable = lib.mkDefault true;
  };
}
