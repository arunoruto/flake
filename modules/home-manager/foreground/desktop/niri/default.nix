{
  config,
  lib,
  osConfig,
  ...
}@args:
{
  config = lib.optionalAttrs ((args ? nixosConfig) && osConfig.programs.niri.enable) {
    xdg.configFile = {
      "niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/flake/modules/home-manager/foreground/desktop/niri/config.kdl";
    };
  };
}
