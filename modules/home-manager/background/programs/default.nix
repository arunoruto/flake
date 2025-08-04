{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./mods.nix
    ./newsboat.nix
    ./papis.nix
    ./pop.nix
  ];

  programs.mods.enable = !config.hosts.tinypc.enable;
  programs.pop.enable = !config.hosts.tinypc.enable;
  home.packages = with pkgs; [
    # bws
  ];
}
