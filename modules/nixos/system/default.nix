{
  inputs,
  pkgs,
  lib,
  config,
  # image,
  # scheme,
  ...
}:
{
  imports = [
    ./boot
    ./types
    ./bluetooth.nix
    ./deployment.nix
    ./locale.nix
    ./nix-utils.nix
    ./secure-boot.nix
    ./systemd.nix
    ./theming.nix
    ./upgrade.nix

    ./amd
    ./intel
    ./nvidia
  ];

  options.system.tags = lib.mkOption {
    # type = lib.types.listOf lib.types.str;
    type = with lib.types; listOf str;
    default = [ ];
    description = ''
      List of tags for this system. This can be used to identify
      this system in scripts or other tools.
    '';
  };

  config =
    {
      nix-utils.enable = lib.mkDefault true;
      secureboot.enable = lib.mkDefault false;
      upgrades.enable = lib.mkDefault false;

      hosts = {
        amd.enable = lib.mkDefault false;
        intel.enable = lib.mkDefault false;
        nvidia.enable = lib.mkDefault false;
      };

      environment.systemPackages = with pkgs; [
        deploy-rs
        lsof
        lshw
        tree
      ];

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.11"; # Did you read the comment?
    }
    // lib.optionalAttrs (inputs ? colmena) {
      colmena.deployment.tags = config.system.tags;
      environment.systemPackages = [ inputs.colmena.packages.${pkgs.system}.colmena ];
    };
}
