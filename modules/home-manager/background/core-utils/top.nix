{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}@args:
{
  options.programs.below = {
    enable = lib.mkEnableOption "Enable below, a modern alternative to top/htop/btop.";
    package = lib.mkPackageOption pkgs "below" { };
  };

  config = lib.mkMerge [
    {
      programs = {
        htop = {
          # package = pkgs.unstable.htop;
          settings = { };
        };
        btop = {
          settings = {
            update_ms = 1000;
            vim_keys = true;
            graph_symbol = "braille";
          };
        }
        // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && (args ? osConfig)) {
          package =
            if osConfig.facter.detected.graphics.amd.enable then
              pkgs.btop-rocm
            else
              pkgs.btop.override {
                cudaSupport = osConfig.hosts.nvidia.enable;
              };
        };
      };
    }
    (lib.mkIf config.programs.below.enable {
      home.packages = [ config.programs.below.package ];
    })
  ];
}
