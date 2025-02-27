{ pkgs, ... }:
{
  programs.helix = {
    languages.language-server.copilot = {
      command = "copilot-language-server";
      args = [ "--stdio" ];
    };

    extraPackages = with pkgs.unstable; [ copilot-language-server ];
  };
}
