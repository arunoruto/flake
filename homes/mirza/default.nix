{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs (!config.hosts.tinypc.enable) {
      fish.enable = true;
      nushell.enable = true;
      zsh.enable = pkgs.stdenv.hostPlatform.isDarwin;
    };
  };
}
