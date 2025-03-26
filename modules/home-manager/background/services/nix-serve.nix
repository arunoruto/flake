{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.nix-serve.enable = lib.mkEnableOption "Configure nix-serve for standalone home-manager";

  config = lib.mkIf config.nix-serve.enable {
    home.packages = with pkgs; [
      nix-serve
    ];
  };
}
