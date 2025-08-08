{ inputs, ... }:
{
  imports = [
    # inputs.nixos-hardware.nixosModules.common.cpu.intel.alder-lake
    "${inputs.nixos-hardware.outPath}/common/cpu/intel/alder-lake"
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
