# setup for multiple languages:
# https://freedium.cfd/https://alpha2phi.medium.com/helix-languages-7cf3263ed7c5
{
  config,
  lib,
  ...
}@args:
{
  imports = [
    ./gpt.nix
    ./julia.nix
    ./ltex.nix
    ./lsp-ai.nix
    ./matlab.nix
    ./markdown.nix
    ./markup.nix
    ./nix.nix
    ./python.nix
  ];

  helix = {
    julia.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    ltex = {
      enable = lib.mkDefault (!config.hosts.tinypc.enable);
      ngram = lib.mkDefault (!config.hosts.tinypc.enable && args ? nixosConfig);
    };
    matlab.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    # markdown.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    markdown.enable = true;
    markup.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    nix.enable = lib.mkDefault true;
    python.enable = lib.mkDefault (!config.hosts.tinypc.enable);
  };
}
