{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./module.nix
    ./theme.nix
  ];

  programs.pi = {
    package = lib.mkDefault (pkgs.unstable.pi-coding-agent or pkgs.pi-coding-agent);
    settings = {
      thinking = "medium";
      transport = "auto";
      theme = "stylix";
    };
    rules = ../AGENTS.md;
  };
}
