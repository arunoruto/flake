# Node.js development shell (TypeScript, Decky plugins, …).
#
#   nix develop .#node       # Node.js LTS, pnpm, just
#   nix develop .#node-lsp   # the same plus language servers
#
# devix has no JavaScript/TypeScript entry yet, so the servers are listed here.
{
  pkgs,
  lib,
  withLsp ? false,
  ...
}:
pkgs.mkShell {
  packages =
    with pkgs;
    [
      nodejs # current LTS
      pnpm
      just
    ]
    ++ lib.optionals withLsp [
      typescript
      typescript-language-server
      vscode-langservers-extracted # eslint, json, css, html
    ];

  shellHook = "";
}
