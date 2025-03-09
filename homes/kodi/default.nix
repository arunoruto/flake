{ config, lib, ... }:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs (!config.hosts.tinypc.enable) {
      fish.enable = true;
      nushell.enable = true;
      zsh.enable = true;
    };
  };
}
