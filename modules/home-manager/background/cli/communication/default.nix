{ config, ... }:
{
  imports = [
    ./iamb.nix
    ./newsboat.nix
    ./pop.nix
  ];

  programs = {
    iamb.enable = config.hosts.development.enable;
    pop.enable = config.hosts.development.enable;
  };
}
