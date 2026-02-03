{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}@args:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  hasNiri = isLinux && (osConfig != null) && osConfig.programs.niri.enable;
in
{
  config = lib.mkIf hasNiri {
    xdg.configFile = {
      "niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/flake/modules/home-manager/foreground/desktop/niri/config.kdl";
    };
  };
}
