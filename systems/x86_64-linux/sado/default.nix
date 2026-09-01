{ ... }:
{
  imports = [
    # CPU/iGPU tuning (alder-lake, for the N150) and pc/ssd are derived from
    # facter.json — see systems/hardware-profiles.nix.
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
