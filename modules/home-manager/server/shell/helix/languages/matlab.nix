{
  config,
  lib,
  pkgs,
  ...
}: {
  options.helix.matlab.enable = lib.mkEnableOption "Helix Matlab config";

  config = lib.mkIf config.helix.matlab.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "matlab";
            scope = "source.m";
            file-types = ["m"];
            comment-token = "%";
            language-servers = ["matlab-ls"];
            # auto-format = true;
            # formatter.command = "";
          }
        ];
        language-server = {
          matlab-ls = {
            command = "matlab-language-server";
            args = ["--stdio"];
            config.MATLAB = {
              installPath = "/usr/local/MATLAB/R2022a";
              indexWorkspace = "true";
              matlabConnectionTiming = "onStart";
              telemetry = "false";
            };
          };
        };
      };
      extraPackages = with pkgs; [
        matlab-language-server
      ];
    };
  };
}
