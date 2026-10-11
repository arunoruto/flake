# Go development shell.
#
#   nix develop .#go       # toolchain, linters, debugger, task runner
#   nix develop .#go-lsp   # the same plus language servers (gopls, …)
#
# Language servers come from devix (modules/devix/languages/go.nix), so the
# shell and the editors always agree on which servers and formatters to use.
{
  pkgs,
  lib,
  withLsp ? false,
  ...
}:
let
  devixGo = import ../modules/devix/languages/go.nix { inherit lib pkgs; };
  enabled = lib.filterAttrs (_: v: v.enable or true);
  lspPackages = lib.mapAttrsToList (_: v: v.package) (enabled devixGo.lsps);
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      go
      gotools # goimports, godoc, …
      golangci-lint
      delve
      just
    ]
    ++ lib.optionals withLsp lspPackages;

  shellHook = "";
}
