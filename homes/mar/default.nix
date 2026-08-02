{
  config,
  lib,
  ...
}:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs config.hosts.desktop.enable {
      fish.enable = true;
      nushell.enable = true;
      zsh.enable = true;
    };

    devix = {
      lsps.nixd.config = {
        nixpkgs.expr = "import (builtins.getFlake ''${config.home.sessionVariables.NH_FLAKE}'').inputs.nixpkgs { }";
        formatting.command = [ "nix fmt" ];
        options = {
          nixos.expr = "(builtins.getFlake ''${config.home.sessionVariables.NH_FLAKE}'').nixosConfigurations.madara.options";
          home-manager.expr = "(builtins.getFlake ''${config.home.sessionVariables.NH_FLAKE}'').homeConfigurations.mar.options";
        };
        diagnostics = { };
      };
    };

    # Disable KDE/Plasma theming (mar uses GNOME)
    stylix.targets.kde.enable = false;
  };
}
