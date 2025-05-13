{ pkgs, ... }:
{
  programs.helix = {
    languages.language-server.sourcery = {
      command = "sourcery";
      args = [ "lsp" ];
    };

    extraPackages = with pkgs.unstable; [ sourcery ];
  };

  home.packages = with pkgs.unstable; [ sourcery ];
}
