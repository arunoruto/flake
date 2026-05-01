{
  lib,
  pkgs,
  config,
  osConfig ? null,
  ...
}@args:
let
  isFrameworkHost = osConfig != null && lib.hasAttrByPath [ "hardware" "framework" ] osConfig;
in
{
  config = lib.mkIf (config.hosts.desktop.enable) {
    services.easyeffects = {
      enable = pkgs.stdenv.hostPlatform.isLinux && isFrameworkHost;
      package = pkgs.unstable.easyeffects;
      extraPresets = {
        framework = builtins.fromJSON (builtins.readFile ./fw13-easy-effects.json);
      };
      preset = if isFrameworkHost then "framework" else "";
    };
  };
}
