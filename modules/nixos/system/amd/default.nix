{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  disabledModules = [ "hardware/cpu/amd-microcode.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/hardware/cpu/amd-microcode.nix"
    inputs.ucodenix.nixosModules.default

    ./gpu.nix
    ./rocm.nix
    ./zluda.nix
  ];

  options.hosts.amd.enable = lib.mkEnableOption "Setup amd tools";

  config = lib.mkIf config.hosts.amd.enable {
    hosts.amd = {
      gpu.enable = lib.mkDefault config.facter.detected.graphics.amd.enable;
      rocm.enable = lib.mkDefault false;
      zluda.enable = lib.mkDefault false;
    };

    services = {
      ucodenix = {
        enable = lib.mkDefault true;
        cpuModelId = lib.mkDefault config.facter.reportPath;
        # cpuModelId = lib.mkDefault "auto";
      };
    };

    environment = {
      systemPackages = with pkgs; [
        clinfo
      ];
    };

    boot.kernelParams = lib.optionals config.services.ucodenix.enable [ "microcode.amd_sha_check=off" ];
    # programs.nix-ld.libraries = config.hardware.graphics.extraPackages;
  };
}
