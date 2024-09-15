{lib, ...}: {
  # Set hostname
  networking.hostName = lib.mkForce "isshin"; # Define your hostname.

  # Eanble fingerprint for framework laptop
  fingerprint.enable = true;

  amd.enable = true;

  # Framework specific kernel Params
  boot = {
    kernelParams = [
      #"quiet"
      #"splash"
      # "ahci.mobile_lpm_policy=3"
      # For Power consumption
      # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
      # "mem_sleep_default=deep"
    ];
    # initrd.kernelModules = ["i915"];
  };
}
