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
    ./tags
    ./boot
    ./bluetooth.nix
    ./deployment.nix
    ./locale.nix
    ./nix-utils.nix
    ./systemd.nix
    ./theming.nix
    ./upgrade.nix
    ./zfs.nix

    ./amd
    ./intel
    ./nvidia
  ];

  config = {
    nix-utils.enable = lib.mkDefault true;
    secureboot.enable = lib.mkDefault false;

    environment.systemPackages = with pkgs; [
      lsof
      lshw
      tree
    ];

    # stateVersion is a per-host, install-time fact: it pins the defaults of
    # stateful services (database layouts, file locations) to the release the
    # machine was first installed with, and should then never change. This is
    # only the fallback for the oldest hosts — a host installed on a later
    # release must set its own value in its configuration.nix.
    system.stateVersion = lib.mkDefault "23.11";
  };
}
