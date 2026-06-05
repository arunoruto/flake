{ config, ... }:
{
  imports = [
    ./awscli.nix
  ];

  programs.awscli.enable = config.hosts.development.enable;
}
