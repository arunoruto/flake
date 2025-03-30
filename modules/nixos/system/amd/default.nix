{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.ucodenix.nixosModules.default

    ./rocm.nix
    ./zluda.nix
  ];

  options.hosts.amd.enable = lib.mkEnableOption "Setup amd tools";

  config = lib.mkIf config.hosts.amd.enable {
    hosts.amd = {
      rocm.enable = lib.mkDefault false;
      zluda.enable = lib.mkDefault false;
    };

    services = {
      xserver.videoDrivers = [ "amdgpu" ];
      ucodenix = {
        enable = lib.mkDefault true;
        cpuModelId = lib.mkDefault config.facter.reportPath;
        # cpuModelId = lib.mkDefault "auto";
      };
    };

    environment = {
      systemPackages = with pkgs; [
        amdgpu_top
        clinfo
        nvtopPackages.amd
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
            amdvlk
          ])
          ++ (with pkgs.rocmPackages; [
            clr.icd
          ]);
      };
    };

    boot.kernelParams = lib.optionals config.services.ucodenix.enable [ "microcode.amd_sha_check=off" ];
    # programs.nix-ld.libraries = config.hardware.graphics.extraPackages;
  };
}
