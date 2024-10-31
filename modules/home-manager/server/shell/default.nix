{ lib, ... }:
{
  imports = [
    # ./dprint
    ./nvim
    ./helix
    ./starship
    ./tmux
    ./bat.nix
    # ./btop.nix
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./nushell.nix
    ./serpl.nix
    ./yazi.nix
    ./zsh.nix
    ./zellij.nix
  ];

  bat.enable = lib.mkDefault true;
  helix.enable = lib.mkDefault true;
  serpl.enable = lib.mkDefault true;
  yazi.enable = lib.mkDefault true;
  zellij.enable = lib.mkDefault true;
}
