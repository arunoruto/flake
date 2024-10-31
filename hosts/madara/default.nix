{ inputs, ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix

    ../../modules/nixos
  ];
}
