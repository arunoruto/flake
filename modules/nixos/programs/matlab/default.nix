{ lib, config, ... }:
{
  imports = [ ./module.nix ];

  config = lib.mkIf config.programs.matlab.enable {
    programs.matlab = {
      licenseFile = config.sops.secrets."config/matlab".path;
      products = [
        "Symbolic_Math_Toolbox"
        "Parallel_Computing_Toolbox"
        "Image_Processing_Toolbox"
        "Hyperspectral_Imaging_Library_for_Image_Processing_Toolbox"
        "Statistics_and_Machine_Learning_Toolbox"
      ];
    };
    sops.secrets."config/matlab".mode = "0444";
  };
}
