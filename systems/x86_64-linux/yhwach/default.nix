{ inputs, ... }:
{
  imports = [
    # CPU/iGPU tuning (coffee-lake) is derived from facter.json — see
    # systems/hardware-profiles.nix. AMD GPU support comes from
    # hosts.amd.gpu.enable, which pulls in nixos-hardware's common/gpu/amd
    # (see modules/nixos/system/amd/gpu.nix).

    # Steamix, the Steam-machine module (github.com/arunoruto/steamix). Only
    # this host imports it; our policy for it lives in
    # modules/nixos/programs/gaming/steamix.nix and applies wherever it is
    # imported. Its packages come from the steamix overlay, which every host's
    # pkgs carries.
    inputs.steamix.nixosModules.default

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
