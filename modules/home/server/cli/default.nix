{
  lib,
  ...
}:
{
  # imports = [
  #   # ./dprint
  #   ./helix
  #   ./tmux
  #   ./bat.nix
  #   ./btop.nix
  #   ./editorconfig.nix
  #   ./fzf.nix
  #   ./misc.nix
  #   ./ruff.nix
  #   ./serpl.nix
  #   ./yazi.nix
  #   ./zellij.nix
  # ];

  config = {
    bat.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    serpl.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
  };
}
