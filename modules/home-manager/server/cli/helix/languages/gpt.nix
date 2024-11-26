{ pkgs, lib, ... }:
{
  programs.helix = {
    languages = {
      language-server = {
        gpt = {
          command = "${lib.getExe pkgs.helix-gpt}";
          args = [
            "--handler"
            "copilot"
          ];
        };
      };
    };
  };
}
