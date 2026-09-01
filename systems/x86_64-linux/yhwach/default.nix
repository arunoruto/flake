{ inputs, ... }:
{
  imports = [
    # CPU/iGPU tuning (coffee-lake) is derived from facter.json — see
    # systems/hardware-profiles.nix. AMD GPU support comes from
    # hosts.amd.gpu.enable, which pulls in nixos-hardware's common/gpu/amd
    # (see modules/nixos/system/amd/gpu.nix).

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
