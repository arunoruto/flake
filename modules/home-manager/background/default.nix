{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./cli
    ./programs
    ./services
    ./shell

    ./nix-utils.nix
    ./secrets.nix
    ./ssh.nix
    ./token.nix
  ];

  nix-utils.enable = true;
  ssh.enable = true;

  home.packages =
    with pkgs;
    [
      dust
      dysk
      speedtest-cli
    ]
    ++ lib.optionals (!config.hosts.tinypc.enable) (
      with pkgs;
      [
        glow
        hexyl
        miller
        ncdu
        ouch
        slides
      ]
    );
}
