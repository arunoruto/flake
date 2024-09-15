{
  pkgs,
  lib,
  config,
  ...
}: {
  options.cachix.enable = lib.mkEnableOption "Use cachix to manage nix caches for packages";

  config = lib.mkIf config.cachix.enable {
    environment.systemPackages = with pkgs; [
      cachix
    ];
  };
}
