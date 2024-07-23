{
  # pkgs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./locale.nix
    ./nix-utils.nix
    ./secure-boot.nix
    ./security.nix
  ];

  nix-utils.enable = lib.mkDefault true;
  secureboot.enable = lib.mkDefault false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Auto updates
  # system.autoUpgrade = {
  #   enable = true;
  #   channel = "https://nixos.org/channels/nixos-${config.system.stateVersion}";
  # };

  # environment.systemPackages = with pkgs; [
  #   unstable.nh
  #   nix-tree
  #   nix-output-monitor
  #   nvd
  # ];
  #
  # # Auto clean system
  # nix = {
  #   settings = {
  #     # build in a sandbox
  #     sandbox = true;
  #     # auto-optimise-store = true;
  #     experimental-features = [
  #       "nix-command"
  #       "flakes"
  #     ];
  #     warn-dirty = false;
  #   };
  #   optimise = {
  #     automatic = true;
  #     dates = ["04:00"];
  #   };
  #   gc = {
  #     automatic = true;
  #     dates = "weekly";
  #     options = "--delete-older-than 7d";
  #   };
  # };
}
