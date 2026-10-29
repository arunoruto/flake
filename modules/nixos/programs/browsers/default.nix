{
  imports = [
    ./chromium.nix # applies whenever programs.chromium.enable is on
    ./firefox.nix # applies whenever programs.firefox.enable is on
  ];
}
