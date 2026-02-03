{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  config = {
    nix-homebrew = {
      enable = lib.mkDefault config.homebrew.enable;
      enableRosetta = lib.mkDefault true;
      user = lib.mkDefault config.homebrew.user;
      autoMigrate = true;
    };

    homebrew = {
      # enable = true;
      # casks = config.darwin.homebrew.casks;
      masApps = lib.optionalAttrs config.services.tailscale.enable { Tailscale = 1475387142; };
      user = lib.mkDefault config.users.primaryUser;
    };
  };
}
