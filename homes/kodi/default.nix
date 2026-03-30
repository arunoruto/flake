{ config, lib, ... }:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs (config.hosts.desktop.enable) {
      fish.enable = true;
      nushell.enable = false;
      zsh.enable = false;
    };
  };
}
