{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.fortran.enable = lib.mkEnableOption "Helix Fortran config";

  config = lib.mkIf config.helix.fortran.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "fortran";
            scope = "source.f90";
            file-types = [ "f90" ];
            comment-token = "!";
            # language-servers = [ "matlab-ls" ];
            auto-format = true;
            formatter = {
              command = "fprettify";
              args = [
                "--silent"
                # "--stdout"
              ];
            };
            indent = {
              tab-width = 3;
              unit = " ";
            };
          }
        ];
        # language-server = {
        #   matlab-ls = {
        #     command = "matlab-language-server";
        #     args = [ "--stdio" ];
        #     config.MATLAB = {
        #       installPath = "/usr/local/MATLAB/R2022a";
        #       indexWorkspace = "true";
        #       matlabConnectionTiming = "onStart";
        #       telemetry = "false";
        #     };
        #   };
        # };
      };
      extraPackages = with pkgs; [
        fortls
        fprettify
      ];
    };

    home.packages = with pkgs; [
      fortls
      fprettify
    ];
  };
}
