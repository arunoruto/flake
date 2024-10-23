{
  pkgs,
  lib,
  ...
}: {
  tinypc.enable = true;

  efi.enable = false;
  grub.enable = true;
  systemd-boot.enable = false;
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.efi.canTouchEfiVariables = false;
  # boot.loader = {
  #   systemd-boot.enable = false;
  #   grub = {
  #     enable = true;
  #     device = "/dev/sda";
  #     #useOSProber = true;
  #     efiSupport = false;
  #   };
  # };

  boot = {
    # kernelModules = ["amdgpu"];
    # kernelParams = [
    #   #"quiet"
    #   #"splash"
    #   "ahci.mobile_lpm_policy=3"
    #   # For Power consumption
    #   # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
    #   "mem_sleep_default=deep"
    # ];
    # initrd.kernelModules = ["i915"];
  };

  hardware = {
    # opengl.extraPackages = with pkgs; [
    #   # OpenCL
    #   rocmPackages.clr.icd
    #   # AMDVLK
    #   amdvlk
    # ];
  };
  # hardware.opengl = {
  #   enable = true;
  #   # package = pkgs.unstable.mesa.drivers;
  #   extraPackages = with pkgs; [
  #     intel-compute-runtime
  #     intel-ocl
  #     intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #     vaapiVdpau
  #     libvdpau-va-gl
  #     # https://nixos.wiki/wiki/Intel_Graphics
  #     unstable.vpl-gpu-rt
  #     intel-media-sdk
  #   ];
  # };
  # environment.sessionVariables = {
  #   LIBVA_DRIVER_NAME = "iHD";
  # }; # Force intel-media-driver
}
