{ ... }:
{
  imports = [
    # CPU/iGPU tuning (coffee-lake) is derived from facter.json — see
    # systems/hardware-profiles.nix.
    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
