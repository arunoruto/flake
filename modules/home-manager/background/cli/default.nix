{
  lib,
  ...
}:
{
  imports = [
    # ./dprint
    ./ai
    ./cloud
    ./communication
    ./documents
    ./games
    ./git
    ./herdr

    ./atuin.nix
    ./astral.nix
    ./fastfetch.nix
    ./tmux
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./serpl.nix
    ./yazi.nix
    ./zellij.nix
  ];

  config = {

    programs = {
      atuin.enable = lib.mkDefault true;
      herdr.enable = lib.mkDefault false;
      serpl.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault false;
    };
  };
}
