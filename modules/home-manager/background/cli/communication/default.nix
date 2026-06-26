{ config, ... }:
{
  imports = [
    ./iamb.nix
    ./newsboat.nix
    ./pop.nix
  ];

  programs = {
    # pop.enable = config.hosts.development.enable;
  };
}
