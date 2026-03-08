{
  config,
  lib,
  ...
}:
let
  settings = {
    warn-dirty = lib.mkDefault false;
    accept-flake-config = lib.mkDefault true;
    trusted-users = lib.mkDefault [
      "root"
      "@admin"
    ];
    extra-experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };
in
{
  config = {
    nix = {
      enable = lib.mkDefault false;
      inherit settings;
    };
  }
  // lib.mkIf (config ? determinateNix) {
    determinateNix.customSettings = settings;
  };
}
