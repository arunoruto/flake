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
  ];

  options.hosts.amd.enable = lib.mkEnableOption "Setup amd tools";

  config = lib.mkIf config.hosts.amd.enable {
    hosts.amd = {
      gpu.enable = lib.mkDefault config.facter.detected.graphics.amd.enable;
      rocm.enable = lib.mkDefault false;
    };

    services = {
      ucodenix = {
        enable = lib.mkDefault true;
        # Narrow the microcode set to this CPU by handing ucodenix the
        # hardware report, which is where it reads the model ID from. Left
        # undefined when there is no report, so its own "auto" default applies
        # and every available binary is processed instead — facter.reportPath
        # is null in that case, and passing null through fails the build with
        # "cannot coerce null to a string" rather than falling back.
        cpuModelId = lib.mkIf (config.facter.reportPath != null) (lib.mkDefault config.facter.reportPath);
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
