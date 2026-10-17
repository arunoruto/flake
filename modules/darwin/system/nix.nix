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
    # Same as on NixOS: our own cache for other flakes than this one.
    extra-substituters = lib.mkDefault [ "https://arunoruto.cachix.org" ];
    extra-trusted-public-keys = lib.mkDefault [
      "arunoruto.cachix.org-1:GQVw1YDtjt0+ElmQifxEI52a0pRVe9/gdcNEr8v8G14="
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
