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
        # ROCm OpenCL, defaulted from the hardware report rather than from
        # this module's own toggle. The two can disagree: a host may enable
        # AMD GPU support without the report agreeing there is an AMD GPU —
        # kuchiki asks for it and has an ASPEED BMC chip — and a host with a
        # real card may simply have no report yet. mkDefault so either case
        # can be settled locally instead of erroring on a conflict.
        hardware.amdgpu.opencl.enable = lib.mkDefault config.facter.detected.graphics.amd.enable;

        # ...and say so when they disagree, because the failure is otherwise
        # invisible: yhwach ran without OpenCL from the rebuild that dropped
        # its stale report until someone happened to look.
        warnings = lib.optional (!config.facter.detected.graphics.amd.enable) ''
          hosts.amd.gpu.enable is set, but the hardware report does not list
          an AMD GPU, so ROCm/OpenCL is left off. Either the host has no
          facter report yet (`just facter`), or it genuinely has no AMD GPU
          and hosts.amd.gpu.enable is the thing to drop. To settle it by hand,
          set hardware.amdgpu.opencl.enable explicitly.
        '';

        # The note above the import is only true while that file stays a bare
        # `config`. Fail the build rather than silently dropping the rest.
        assertions = [
          {
            assertion = builtins.attrNames nixos-hardware-amd == [ "config" ];
            message =
              "nixos-hardware common/gpu/amd now exposes "
              + builtins.concatStringsSep ", " (builtins.attrNames nixos-hardware-amd)
              + "; this module consumes only its `config`, so anything else is "
              + "being dropped. See the note in modules/nixos/system/amd/gpu.nix.";
          }
        ];

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
