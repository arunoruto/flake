{ pkgs, lib, ... }:
{
  programs.helix = {
    languages.language-server.gpt = {
      command = "helix-gpt";
      args = [
        "--handler"
        "copilot"
      ];
    };

    extraPackages = with pkgs; [ helix-gpt ];
  };
}
