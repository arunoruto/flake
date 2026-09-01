{ inputs, ... }:
{
  imports = [
    # CPU/iGPU tuning (coffee-lake) is derived from facter.json — see
    # systems/hardware-profiles.nix. The NVIDIA driver flavour stays a
    # deliberate per-host choice.
    (inputs.nixos-hardware.outPath + "/common/gpu/nvidia/pascal")

    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
