{ pkgs, lib, ... }:
let
  serve = pkgs.writeShellScriptBin "serve" ''
    exec ${lib.getExe pkgs.hugo} serve --openBrowser --buildDrafts --buildFuture
  '';

  git-submodule-init = pkgs.writeShellScriptBin "git-submodule-init" "${lib.getExe pkgs.git} submodule update --init --recursive";
  git-submodule-update = pkgs.writeShellScriptBin "git-submodule-update" "${lib.getExe pkgs.git} submodule update --remote --merge";
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    hugo
    blowfish-tools

    serve
    git-submodule-init
    git-submodule-update
  ];

  shellHook = ''
    echo "Hugo start..."
  '';
}
