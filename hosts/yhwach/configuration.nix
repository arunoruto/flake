{
  pkgs,
  lib,
  ...
}: {
  # imports = [
  #   ../../modules/nixos
  # ];

  # Set hostname
  networking.hostName = lib.mkForce "yhwach"; # Define your hostname.

  # Eanble fingerprint for framework laptop
  # fingerprint.enable = true;

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
