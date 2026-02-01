{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.nix-serve.enable = lib.mkEnableOption "Configure nix-serve for standalone home-manager";

  config = lib.mkIf config.programs.nix-serve.enable {
    home.packages = with pkgs; [
      nix-serve
    ];
  };
}
