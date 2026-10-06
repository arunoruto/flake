{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.steamix.nixosModules.default

    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
