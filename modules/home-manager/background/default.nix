{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./cli
    ./core-utils
    ./programs
    ./services
    ./shell

    ./dev/module.nix
    ./dev

    ./nix-utils.nix
    ./secrets.nix
    ./ssh.nix
    ./token.nix
  ];

  config = {
    nix-utils.enable = true;
    programs.ssh.enable = true;

    home.packages =
      with pkgs;
      [
        dust
        dysk
        speedtest-cli
      ]
      ++ lib.optionals config.hosts.development.enable (
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
  };
}
