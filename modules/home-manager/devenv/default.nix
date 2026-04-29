# Home-manager integration for devenv language profiles
{ lib, ... }:
{
  imports = [
    ./languages.nix
    ./helix.nix
  ];

  options.devenv = {
    enable = lib.mkEnableOption "devenv language profiles in home-manager" // {
      default = false;
    };

    autoConfigureEditors = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically configure enabled editors (helix, etc.) for active languages.
        Set to false to manage editor configuration manually.
      '';
    };
  };
}
