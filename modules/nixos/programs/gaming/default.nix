{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./chess
    ./steam.nix
  ];
}
