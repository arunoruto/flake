# Shared by NixOS and Darwin: the `users.primaryUser` option. The one human a
# machine belongs to — receives home-manager, SSH keys, theming, etc. The
# platform user modules build the actual account from it.
{ lib, ... }:
{
  options.users.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = ''
      Name of the primary user for this system. Required — must be set in the
      host configuration (there is no default).
    '';
  };
}
