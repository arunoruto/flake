{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd

    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
