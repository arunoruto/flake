{
  lib,
  pkgs,
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
      # ARM Linux hosts are small boards (the Pi); they get plain tmux, which
      # is enabled everywhere and shares herdr's keybindings. The Mac is
      # aarch64 too, hence pkgs.stdenv.hostPlatform.isLinux.
      herdr.enable = lib.mkDefault (
        !(pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64)
      );
      serpl.enable = lib.mkDefault false;
      superfile.enable = lib.mkDefault true;
      tuios.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault false;
      zellij.enable = lib.mkDefault false;
    };
  };
}
