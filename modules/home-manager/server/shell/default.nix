{
  lib,
  pkgs,
  config,
  ...
}:
let
  shells = [
    # "bash"
    "fish"
    "nushell"
    "zsh"
  ];
in
{
  imports = [
    # ./dprint
    # ./nvim
    ./helix
    ./starship
    ./tmux
    ./bat.nix
    # ./btop.nix
    ./editorconfig.nix
    ./fzf.nix
    ./misc.nix
    ./serpl.nix
    ./skim.nix
    ./yazi.nix
    ./zellij.nix

    ./fish.nix
    ./nushell.nix
    ./zsh.nix
  ];

  options = {
    shell = lib.mkOption {
      type = lib.types.str;
      default = "bash";
      description = "Choose which shell should be configured for the user";
    };
    programs.bash.package = lib.mkPackageOption pkgs "bash" { };
  };

  config =
    {
      bat.enable = lib.mkDefault true;
      helix.enable = lib.mkDefault true;
      serpl.enable = lib.mkDefault true;
      skim.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault true;
      zellij.enable = lib.mkDefault true;

      # fish.enable = lib.mkDefault (if config.shell == "fish" then true else false);
      # nushell.enable = lib.mkDefault (if config.shell == "nushell" then true else false);
      # zsh.enable = lib.mkDefault (if config.shell == "zsh" then true else false);
    }
    // lib.genAttrs shells (
      sh: lib.genAttrs [ "enable" ] (val: lib.mkDefault (if config.shell == sh then true else false))
    );
}
