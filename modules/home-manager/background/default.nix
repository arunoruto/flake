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
    ./services
    ./shell

    ./nix-utils.nix
    ./secrets.nix
    ./ssh.nix
    ./token.nix
  ];

  config = {
    nix-utils.enable = true;
    programs.ssh.enable = true;

    home = {
      packages =
        with pkgs;
        [
          dust
          dysk
          speedtest-cli
        ];
      file = {
        ".hushlogin".text = "";
      };
    };
  };
}
