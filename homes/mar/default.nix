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

    # Configure Zen browser profile for stylix theming
    stylix.targets.zen-browser.profileNames = [ "default" ];
  };
}
