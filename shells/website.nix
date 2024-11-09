{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    hugo
  ];

  shellHook = ''
    echo "Hugo start..."
  '';
}
