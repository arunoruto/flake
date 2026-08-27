{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.hosts.amd.gpu;

  # nixos-hardware's AMD GPU module (modesetting, graphics stack, early KMS
  # via hardware.amdgpu.initrd), imported as a function so it can be gated on
  # our toggle. A plain `imports = [ ... ]` here would apply it to every host
  # in the shared module tree — its mkDefaults would e.g. pull mesa onto
  # headless servers — because imports cannot be conditional on config.
  # Caveat of the technique: only the file's `config` is consumed; if
  # upstream ever adds `imports` or `options` to it, revisit this.
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
        boot.kernelModules = [ "amdgpu" ];
        services.xserver.videoDrivers = [ "amdgpu" ];

        environment = {
          systemPackages = with pkgs; [
            amdgpu_top
            radeontop
            nvtopPackages.amd
            rocmPackages.amdsmi
          ];
          sessionVariables = {
            GSK_RENDERER = "gl";
          };
        };

        hardware = {
          amdgpu.opencl.enable = config.facter.detected.graphics.amd.enable;
          graphics = {
            enable = true;
            # driSupport = true;
            enable32Bit = true;
            extraPackages =
              (with pkgs; [
                # amdvlk
                # radv
              ])
              ++ (with pkgs.rocmPackages; [
                clr.icd
              ]);
          };
        };

        boot.kernelParams = lib.optionals config.services.ucodenix.enable [
          "microcode.amd_sha_check=off"
        ];
        # programs.nix-ld.libraries = config.hardware.graphics.extraPackages;
      }
    ]
  );
}
