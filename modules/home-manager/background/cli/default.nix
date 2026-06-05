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
    ./atuin.nix
    ./astral.nix
    ./fastfetch.nix
    ./helix
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
      helix.enable = lib.mkDefault true;

      atuin.enable = lib.mkDefault true;
      serpl.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault false;
    };
  };
}
