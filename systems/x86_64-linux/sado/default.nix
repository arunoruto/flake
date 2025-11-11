{ inputs, ... }:
{
  imports = [
    # inputs.nixos-hardware.nixosModules.common.cpu.intel.alder-lake
    "${inputs.nixos-hardware.outPath}/common/cpu/intel/alder-lake"
    "${inputs.nixos-hardware.outPath}/common/gpu/intel/alder-lake"
    "${inputs.nixos-hardware.outPath}/common/pc/ssd"
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
