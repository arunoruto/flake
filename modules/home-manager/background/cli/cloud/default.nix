{ config, ... }:
{
  imports = [
    ./awscli.nix
  ];

  programs.awscli.enable = false;
}
