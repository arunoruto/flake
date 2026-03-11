{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./games
    ./git
    ./awscli.nix
    ./iamb.nix
    ./mods.nix
    ./newsboat.nix
    ./papis.nix
    ./pop.nix
    ./ty.nix
  ];

  programs = {
    awscli.enable = config.hosts.development.enable;
    iamb.enable = config.hosts.development.enable;
    mods.enable = config.hosts.development.enable;
    pop.enable = config.hosts.development.enable;
  };
  home.packages = with pkgs; [
    # bws
  ];
}
