{ inputs, ... }:
{
  imports = [
    (inputs.nixos-hardware.outPath + "/common/cpu/intel/coffee-lake")
    (inputs.nixos-hardware.outPath + "/common/gpu/nvidia/pascal")

    ./configuration.nix
    ./hardware-configuration.nix

    ../../modules/nixos
  ];
}
