# setup for multiple languages:
# https://freedium.cfd/https://alpha2phi.medium.com/helix-languages-7cf3263ed7c5
{
  config,
  lib,
  ...
}:
{
  imports = [
    ./gpt.nix
    ./julia.nix
    ./matlab.nix
    ./markdown.nix
    ./markup.nix
    ./nix.nix
    ./python.nix
  ];

  helix = {
    julia.enable = lib.mkDefault (!config.tinypc.enable);
    matlab.enable = lib.mkDefault (!config.tinypc.enable);
    markdown.enable = lib.mkDefault (!config.tinypc.enable);
    markup.enable = lib.mkDefault (!config.tinypc.enable);
    nix.enable = lib.mkDefault true;
    python.enable = lib.mkDefault (!config.tinypc.enable);
  };
}
