{ inputs, ... }:
{
  imports = [
    (inputs.nixos-hardware.outPath + "/common/cpu/intel/coffee-lake")
    (inputs.nixos-hardware.outPath + "/common/gpu/amd")

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
