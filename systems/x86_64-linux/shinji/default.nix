{ inputs, ... }:
{
  imports = [
    (inputs.nixos-hardware.outPath + "/common/cpu/intel/coffee-lake")
    ./configuration.nix
    # ./disk.nix
    ./hardware-configuration.nix

    ../../modules/nixos
  ];
}
