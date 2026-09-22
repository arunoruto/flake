{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.cachix.enable = lib.mkEnableOption "cachix, to manage nix caches for packages";

  config = lib.mkIf config.programs.cachix.enable {
    environment.systemPackages = with pkgs; [
      cachix
    ];

    nix.settings.trusted-users = [
      "root"
      config.users.primaryUser
    ];
  };
}
