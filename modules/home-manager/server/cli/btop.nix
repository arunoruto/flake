{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}@args:
{
  programs.btop =
    {
      enable = true;
    }
    // lib.optionals (args ? nixosConfig) {
      package = pkgs.btop.override {
        rocmSupport = config.facter.detected.graphics.amd.enable;
        cudaSupport = config.hosts.nvidia.enable;
      };
    };

  # home.file.".config/btop/themes/catppuccin".source = pkgs.fetchFromGitHub {
  #   owner = "catppuccin";
  #   repo = "btop";
  #   rev = "1.0.0";
  #   sha256 = "sha256-J3UezOQMDdxpflGax0rGBF/XMiKqdqZXuX4KMVGTxFk=";
  # };
}
