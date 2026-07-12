{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./system
    ./security
    ./services
    ./homebrew
    ./users
    # home-manager glue (../../homes/nixos.nix) is added by the host builder in
    # systems/default.nix, symmetrically with NixOS hosts.
  ];

  environment = {
    shellInit = ''
      # Increase the limit of open files for all interactive shells
      ulimit -n 4096 2>/dev/null
    '';
    systemPackages = with pkgs; [
      tree
    ];
  };
}
