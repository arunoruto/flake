{
  pkgs,
  lib,
  osConfig,
  ...
}@args:
{
  programs.btop =
    {
      enable = true;
      settings = {
        update_ms = 1000;
        vim_keys = true;
        graph_symbol = "braille";
      };
    }
    // lib.optionals (args ? nixosConfig) {
      package =
        if osConfig.facter.detected.graphics.amd.enable then
          pkgs.btop-rocm
        else
          pkgs.btop.override {
            cudaSupport = osConfig.hosts.nvidia.enable;
          };
    };

  # home.file.".config/btop/themes/catppuccin".source = pkgs.fetchFromGitHub {
  #   owner = "catppuccin";
  #   repo = "btop";
  #   rev = "1.0.0";
  #   sha256 = "sha256-J3UezOQMDdxpflGax0rGBF/XMiKqdqZXuX4KMVGTxFk=";
  # };
}
