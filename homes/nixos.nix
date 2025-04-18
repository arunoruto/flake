{
  # inputs',
  # self',
  # self,
  # config,
  inputs,
  config,
  lib,
  pkgs,
  flake,
  ...
}:
let
  # inherit (self) inputs;
  # inherit (lib.modules) mkIf;
  # inherit (lib.attrsets) genAttrs;
  # inherit (config) modules;
  # env = modules.usrEnv;
  # sys = modules.system;
  # defaults = sys.programs.default;
  # specialArgs = {inherit theme image inputs self inputs' self' defaults;};
  username = config.username;
  specialArgs = {
    inherit inputs;
    # user = username;
  };
  host-home-config = ../systems/${config.networking.hostName}/home.nix;
in
{
  # home-manager = mkIf env.useHomeManager {
  home-manager = {
    # tell home-manager to be as verbose as possible
    verbose = true;

    # use the system configuration’s pkgs argument
    # this ensures parity between nixos' pkgs and hm's pkgs
    useGlobalPkgs = true;

    # enable the usage user packages through
    # the users.users.<name>.packages option
    useUserPackages = true;

    # move existing files to the .hm.old suffix rather than failing
    # with a very long error message about it
    backupFileExtension = "hm.old";

    # extra specialArgs passed to Home Manager
    # for reference, the config argument in nixos can be accessed
    # in home-manager through osConfig without us passing it
    extraSpecialArgs = specialArgs;

    # per-user Home Manager configuration
    # the genAttrs function generates an attribute set of users
    # as `user = ./user` where user is picked from a list of
    # users in modules.system.users
    # the system expects user directories to be found in the present
    # directory, or will exit with directory not found errors
    # users.${username} = import ../modules/home-manager/home.nix;
    # users.${username} = (import ./${username}) // (import ../modules/home-manager/home.nix);
    users.${username} =
      # (import ./${username} { inherit config lib; })
      lib.optionalAttrs (builtins.pathExists host-home-config) (
        import host-home-config {
          inherit lib;
          inherit pkgs;
        }
      )
      // {
        imports = [
          ./${username}
          flake.homeManagerModules.default
        ];
        options.user = lib.mkOption {
          type = lib.types.str;
          default = username;
        };
      };

    # users = genAttrs config.modules.system.users (name: ./${name});
  };
}
