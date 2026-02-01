{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}@args:
{
  config = lib.mkIf (!config.hosts.headless.enable) {
    services.easyeffects = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      package = pkgs.unstable.easyeffects;
      extraPresets = {
        # framework = builtins.fromJSON builtins.readFile ./fw13-easy-effects.json;
        framework = ./fw13-easy-effects.json |> builtins.readFile |> builtins.fromJSON;
      };
      preset =
        if (args ? nixosConfig) then
          (if osConfig.networking.hostName == "isshin" then "framework" else "")
        else
          "";
    };
  };
}
