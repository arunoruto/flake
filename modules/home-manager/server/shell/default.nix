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
    ./starship

    ./fish.nix
    ./nushell.nix
    ./zsh.nix
  ];

  options = {
    shell.main = lib.mkOption {
      type = lib.types.str;
      default = "bash";
      description = "Choose which shell should be configured for the user";
    };
    programs.bash.package = lib.mkPackageOption pkgs "bash" { };
  };

  config =
    {
      shell.starship.enable = lib.mkDefault true;
    }
    // lib.genAttrs shells (
      sh: lib.genAttrs [ "enable" ] (val: lib.mkDefault (if config.shell.main == sh then true else false))
    );
}
