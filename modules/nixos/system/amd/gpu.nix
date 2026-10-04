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
  # is consumed, and anything upstream adds next to it has to be handled by
  # hand (see knownImports and the assertion below).
  amdDir = inputs.nixos-hardware.outPath + "/common/gpu/amd";
  nixos-hardware-amd = import amdDir { inherit config lib pkgs; };

  # The one thing upstream's file imports besides its own config, as of
  # nixos-hardware 0953bb1a (2026-10-02, PR #1992): typed options for the
  # amdgpu.dcdebugmask kernel parameter (hardware.amdgpu.dcDebugMask.*). It is
  # pure option declarations plus a mkIf on them, so importing it for every
  # host costs nothing and keeps the option available regardless of the
  # toggle — options cannot be gated anyway. Older pins do not have the file,
  # hence the existence check; `inputs` is a specialArg, so this is safe to
  # use from `imports`.
  dcDebugMask = amdDir + "/dc-debug-mask.nix";
  knownImports = lib.optional (builtins.pathExists dcDebugMask) dcDebugMask;
in
{
  imports = knownImports;

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
        hardware.amdgpu.opencl.enable = lib.mkDefault config.hardware.facter.detected.graphics.amd.enable;

        # ...and say so when they disagree, because the failure is otherwise
        # invisible: yhwach ran without OpenCL from the rebuild that dropped
        # its stale report until someone happened to look.
        warnings = lib.optional (!config.hardware.facter.detected.graphics.amd.enable) ''
          hosts.amd.gpu.enable is set, but the hardware report does not list
          an AMD GPU, so ROCm/OpenCL is left off. Either the host has no
          facter report yet (`just facter`), or it genuinely has no AMD GPU
          and hosts.amd.gpu.enable is the thing to drop. To settle it by hand,
          set hardware.amdgpu.opencl.enable explicitly.
        '';

        # The import-as-function trick only sees what it is told to look at:
        # the file's `config`, plus the imports mirrored in knownImports. Fail
        # the build when upstream grows anything else rather than silently
        # dropping it. Paths are compared as strings because upstream's
        # `./dc-debug-mask.nix` is a path while ours is built from outPath.
        assertions = [
          {
            assertion =
              lib.all (
                name:
                lib.elem name [
                  "config"
                  "imports"
                ]
              ) (builtins.attrNames nixos-hardware-amd)
              && map toString (nixos-hardware-amd.imports or [ ]) == map toString knownImports;
            message =
              "nixos-hardware common/gpu/amd now exposes "
              + builtins.concatStringsSep ", " (builtins.attrNames nixos-hardware-amd)
              + (lib.optionalString (nixos-hardware-amd ? imports) (
                " with imports " + builtins.concatStringsSep ", " (map toString nixos-hardware-amd.imports)
              ))
              + "; this module consumes its `config` and the imports listed in "
              + "knownImports, so anything else is being dropped. See the note in "
              + "modules/nixos/system/amd/gpu.nix.";
          }
        ];

        # LACT tunes the GPU: fan curves, power limits, clocks. The nixpkgs
        # module installs its GTK front-end alongside the daemon
        # (environment.systemPackages = [ cfg.package ]), so defaulting it on
        # for every AMD GPU hands a headless box a desktop app it can never
        # open — kuchiki is a NAS whose GPU is switched off in the BIOS and
        # was getting one. Default it on where someone sits at the machine.
        #
        # Not gated on gui.enable: that only defaults true from the desktop
        # tag, so it would drop laptops that plainly do have a screen. A
        # headless host wanting the daemon for fan control can still say so.
        services.lact.enable = lib.mkDefault (
          config.lib.tags.hasTag "desktop" || config.lib.tags.hasTag "laptop"
        );

        environment.systemPackages = with pkgs; [
          amdgpu_top
          nvtopPackages.amd
          rocmPackages.amdsmi
        ];
      }
    ]
  );
}
