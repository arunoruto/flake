{ inputs, ... }:
{
  imports = [
    (inputs.nixos-hardware.outPath + "/common/cpu/intel/coffee-lake")
    # AMD GPU support comes from hosts.amd.gpu.enable, which pulls in
    # nixos-hardware's common/gpu/amd (see modules/nixos/system/amd/gpu.nix)

    ./configuration.nix
    ./display.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
