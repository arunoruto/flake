{
  lib,
  ...
}:
{
  imports = [
    # ./dprint
    # ./nvim
    ./helix
    ./tmux
    ./bat.nix
    ./btop.nix
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./serpl.nix
    ./skim.nix
    ./yazi.nix
    ./zellij.nix
  ];

  config = {
    bat.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    serpl.enable = lib.mkDefault true;
    skim.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
  };
}
