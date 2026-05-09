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
    ../../homes/nixos.nix
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
