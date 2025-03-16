# setup for multiple languages:
# https://freedium.cfd/https://alpha2phi.medium.com/helix-languages-7cf3263ed7c5
{
  config,
  lib,
  ...
}@args:
{
  imports = [
    ./ai
    ./programming

    ./shells.nix
    ./latex.nix
    ./ltex.nix
    ./markdown.nix
    ./markup.nix
    ./nix.nix
  ];

  helix = {
    shells.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    julia.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    latex.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    ltex = {
      enable = lib.mkDefault (!config.hosts.tinypc.enable);
      ngram = lib.mkDefault (!config.hosts.tinypc.enable && args ? nixosConfig);
    };
    fortran.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    go.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    matlab.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    # markdown.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    markdown.enable = true;
    markup.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    nix.enable = lib.mkDefault true;
    python.enable = lib.mkDefault (!config.hosts.tinypc.enable);
  };
}
