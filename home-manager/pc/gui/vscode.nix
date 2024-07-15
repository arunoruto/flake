{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    # package = pkgs.unstable.vscode;
  };
}
