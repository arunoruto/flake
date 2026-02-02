{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Stub dconf module for Darwin to satisfy Stylix dependencies
  # Stylix's gnome-text-editor target expects dconf.settings to exist
  # This provides a no-op implementation for Darwin where dconf doesn't work
  home-manager.sharedModules = [
    {
      options.dconf = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "dconf" // {
              default = false;
            };
            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
              description = "dconf settings (no-op on Darwin)";
            };
          };
        };
        default = { };
        description = "dconf configuration stub for Darwin compatibility";
      };

      config.dconf = {
        enable = lib.mkDefault false;
        settings = lib.mkDefault { };
      };
    }
  ];
}
