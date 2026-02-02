{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.darwin.system.nix = {
    enable = lib.mkEnableOption "Enable Nix daemon configuration" // {
      default = true;
    };
  };

  config = lib.mkIf config.darwin.system.nix.enable {
    nix = {
      enable = lib.mkDefault false;
      settings = {
        warn-dirty = lib.mkDefault false;
        accept-flake-config = lib.mkDefault true;
        trusted-users = lib.mkDefault [
          "root"
          "@wheel"
        ];
        extra-experimental-features = lib.mkDefault [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
    };
  };
}
