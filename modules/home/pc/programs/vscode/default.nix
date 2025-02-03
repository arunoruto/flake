{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.vscode.enable = lib.mkEnableOption "Enable Visual Studio Code, an electron based IDE";

  config = lib.mkIf config.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscodium;
      # package = pkgs.unstable.vscode;
      # extension = with pkgs.vscode-extensions; [
      #   julialang.language-julia
      # ];
    };
  };
}
