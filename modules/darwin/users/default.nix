{
  config,
  lib,
  pkgs,
  ...
}:
let
  primaryUser = config.users.primaryUser;
in
{
  options.users.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = "Primary user for this system (works on both NixOS and Darwin)";
  };

  config = {
    # Define the primary user
    users.users.${primaryUser} = {
      name = primaryUser;
      home = "/Users/${primaryUser}";
    };

    # System primary user (for nix-darwin)
    system.primaryUser = primaryUser;

    # Enable home-manager for all users with home configs
    homes.enable = lib.mkDefault true;

    # Configure home-manager for primary user by default
    homes.users = lib.mkDefault [ primaryUser ];
  };
}
