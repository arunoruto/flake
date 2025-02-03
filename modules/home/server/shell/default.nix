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
  # imports = [
  #   ./starship

  #   ./fish.nix
  #   ./nushell.nix
  #   ./zsh.nix
  # ];

  options = {
    shell.main = lib.mkOption {
      type = lib.types.str;
      default = "bash";
      description = "Choose which shell should be configured for the user";
    };
    programs.bash.package = lib.mkPackageOption pkgs "bash" { };
  };

  config = {
    programs =
      {
        # starship.enable = lib.mkDefault true;
        starship.enable = true;
        # completion manager
        carapace.enable = false;
      }
      // lib.genAttrs shells (
        # loops over all terminal attributes defined above
        sh:
        lib.genAttrs [ "enable" ] (
          # for the enable attribute
          val:
          (
            if config.shell.main == sh then
              (lib.mkDefault true)
            else if config.hosts.tinypc.enable then
              (lib.mkForce false)
            else
              (lib.mkDefault false)
          )
        )
      );
  };
}
