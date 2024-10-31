{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    ../..
  ];

  # Set hostname
  networking.hostName = lib.mkForce "zangetsu"; # Define your hostname.

  # Eanble fingerprint for framework laptop
  fingerprint.enable = true;

  # Framework specific kernel Params
  boot = {
    kernelParams = [
      #"quiet"
      #"splash"
      "ahci.mobile_lpm_policy=3"
      # For Power consumption
      # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
      "mem_sleep_default=deep"
    ];
    initrd.kernelModules = [ "i915" ];
  };

  # Enable TLP and powertop for better battery life
  services = {
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        PCIE_ASPM_ON_BAT = "powersupersave";
        RESTORE_DEVICE_STATE_ON_STARTUP = 1;
        RUNTIME_PM_ON_BAT = "auto";
      };
    };
  };
  powerManagement.powertop.enable = true;

  # nixpkgs.config.packageOverrides = pkgs: {
  #   intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  # };

  hardware.opengl = {
    enable = true;
    # package = pkgs.unstable.mesa.drivers;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-ocl
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
      # https://nixos.wiki/wiki/Intel_Graphics
      unstable.vpl-gpu-rt
      intel-media-sdk
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver
}
