{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
