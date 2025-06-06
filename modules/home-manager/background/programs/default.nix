{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./newsboat.nix
    ./papis.nix
    ./pop.nix
  ];

  programs.pop.enable = !config.hosts.tinypc.enable;
  home.packages = with pkgs; [
    # bws
  ];
}
