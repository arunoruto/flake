{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  options.darwin.homebrew = {
    enable = lib.mkEnableOption "Enable Homebrew integration via nix-homebrew";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User account that owns Homebrew";
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Homebrew casks to install";
    };

    enableRosetta = lib.mkEnableOption "Enable Rosetta 2 for Homebrew" // {
      default = true;
    };
  };

  config = lib.mkIf config.darwin.homebrew.enable {
    nix-homebrew = {
      enable = true;
      inherit (config.darwin.homebrew) enableRosetta;
      user = config.darwin.homebrew.user;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;
      casks = config.darwin.homebrew.casks;
    };
  };
}
