{ config, lib, ... }:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs (!config.hosts.tinypc.enable) {
      fish.enable = true;
      nushell.enable = true;
      zsh.enable = true;
    };

    # Disable KDE/Plasma theming (mar uses GNOME)
    stylix.targets.kde.enable = false;
  };
}
