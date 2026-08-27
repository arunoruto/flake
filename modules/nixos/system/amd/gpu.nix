{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.hosts.amd.gpu;

  # nixos-hardware's AMD GPU module (modesetting driver, graphics stack incl.
  # 32-bit, early KMS via hardware.amdgpu.initrd), imported as a function so
  # it can be gated on our toggle. A plain `imports = [ ... ]` here would
  # apply it to every host in the shared module tree — its mkDefaults would
  # e.g. pull mesa onto headless servers — because imports cannot be
  # conditional on config. Caveat of the technique: only the file's `config`
  # is consumed; if upstream ever adds `imports` or `options` to it, revisit.
  nixos-hardware-amd = import (inputs.nixos-hardware.outPath + "/common/gpu/amd") {
    inherit config lib pkgs;
  };
in
{
  options.hosts.amd.gpu.enable = lib.mkEnableOption "Setup AMD GPU";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      nixos-hardware-amd.config

      {
        # ROCm OpenCL when the hardware report confirms an AMD GPU. The
        # upstream option installs the runtime and ICD (rocmPackages.clr);
        # nothing needs to be added to hardware.graphics manually.
        hardware.amdgpu.opencl.enable = config.facter.detected.graphics.amd.enable;

        # Fan curves, power limits and profiles (daemon + GUI)
        services.lact.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          amdgpu_top
          nvtopPackages.amd
          rocmPackages.amdsmi
        ];
      }
    ]
  );
}
