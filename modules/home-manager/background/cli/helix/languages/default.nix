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
    ./grammar
    ./programming

    ./shells.nix
    ./latex.nix
    ./markdown.nix
    ./markup.nix
    ./nix.nix
    ./typst.nix
  ];

  helix = {
    codebook.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    shells.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    latex.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    ltex = {
      enable = lib.mkDefault (!config.hosts.tinypc.enable);
      ngram = lib.mkDefault (!config.hosts.tinypc.enable && args ? nixosConfig);
    };
    # markdown.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    markdown.enable = true;
    markup.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    nix.enable = lib.mkDefault true;
    typst.enable = lib.mkDefault (!config.hosts.tinypc.enable);
  };
}
