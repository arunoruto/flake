{
  lib,
  ...
}:
{
  imports = [
    # ./dprint
    ./atuin.nix
    ./astral.nix
    ./fastfetch.nix
    ./helix
    ./tmux
    ./bat.nix
    ./btop.nix
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./serpl.nix
    ./yazi.nix
    ./zellij.nix
  ];

  config = {
    helix.enable = lib.mkDefault true;

    programs = {
      atuin.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      serpl.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;
    };
  };
}
