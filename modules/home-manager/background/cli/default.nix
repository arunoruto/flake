{
  lib,
  ...
}:
{
  imports = [
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
    ./tuios
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./serpl.nix
    ./superfile
    ./yazi.nix
    ./zellij.nix
  ];

  config = {

    programs = {
      atuin.enable = lib.mkDefault true;
      herdr.enable = lib.mkDefault true;
      serpl.enable = lib.mkDefault false;
      superfile.enable = lib.mkDefault true;
      tuios.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault false;
      zellij.enable = lib.mkDefault false;
    };
  };
}
