{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = lib.mkDefault false;
    package = pkgs.unstable.vscodium;
    # package = pkgs.unstable.vscode;
    # extension = with pkgs.vscode-extensions; [
    #   julialang.language-julia
    # ];
  };
}
