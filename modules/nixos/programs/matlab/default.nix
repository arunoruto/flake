{ lib, config, ... }:
{
  imports = [ ./module.nix ];

  config = lib.mkIf config.programs.matlab.enable {
    programs.matlab = {
      licenseFile = config.sops.secrets."config/matlab".path;
      products = {
        Symbolic_Math_Toolbox = "sha256-154gIbMXDCpph+YdyMCL5aji5QuK1MOw0WPEFgCCohs=";
        Parallel_Computing_Toolbox = "sha256-Uzcp1pvi9oFYU4rpNiqAnhtD7sz1YSCHFFQyeIthaJc=";
        Image_Processing_Toolbox = "sha256-2+S0Fb3g5BtvE731dkHAgV5fn4E9n8IhTlDLdDCicTw=";
        Hyperspectral_Imaging_Library_for_Image_Processing_Toolbox = "sha256-u4ilce4Cnu9Vg2yfJpuQn44oAtnWUvgLbUv9bzUyK/I=";
        Statistics_and_Machine_Learning_Toolbox = "sha256-qcMiZIqiSahb5fz/pIw9FlVW9f7iHuQM5WGZfJN8in8=";
      };
    };
    sops.secrets."config/matlab".mode = "0444";
  };
}
