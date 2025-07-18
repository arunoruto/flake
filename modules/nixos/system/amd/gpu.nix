{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hosts.amd.gpu.enable = lib.mkEnableOption "Setup AMD GPU";

  config = lib.mkIf config.hosts.amd.gpu.enable {
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
