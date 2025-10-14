{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
