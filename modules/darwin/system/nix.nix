{
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
      # NOTE: was `false` while Determinate Nix managed the daemon out-of-band.
      # With Determinate removed, nix-darwin must manage Nix itself — flip to
      # `true` if `tensa` should run stock, nix-darwin-managed Nix.
      enable = lib.mkDefault false;
      inherit settings;
    };
  };
}
