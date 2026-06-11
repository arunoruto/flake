{ ... }:
{
  imports = [
    ../languages/python.nix
  ];

  development.languages.python = {
    enable = true;
  };
}
