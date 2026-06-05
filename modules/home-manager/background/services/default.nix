{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./audio
    ./nix-serve.nix
    ./nixai.nix
  ];

  programs.nix-serve.enable = lib.mkDefault (
    config.hosts.desktop.enable && pkgs.stdenv.hostPlatform.isLinux
  );
}
