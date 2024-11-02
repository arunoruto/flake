{
  lib,
  pkgs,
  config,
  ...
}:
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
    ./skim.nix
    ./yazi.nix
    ./zsh.nix
    ./zellij.nix
  ];

  options = {
    shell = lib.mkOption {
      type = lib.types.str;
      default = "bash";
      description = "Choose which shell should be configured for the user";
    };
    programs.bash.package = lib.mkPackageOption pkgs "bash" { };
  };

  config = {
    bat.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    serpl.enable = lib.mkDefault true;
    skim.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;

    nushell.enable = lib.mkDefault (if config.shell == "nushell" then true else false);
    zsh.enable = lib.mkDefault (if config.shell == "zsh" then true else false);
  };
}
