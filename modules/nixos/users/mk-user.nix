# Define an admin user. Takes effect only on hosts where this user is the
# primary user. mirza.nix / mar.nix are one-line applications of this.
username:
{ config, lib, ... }:
{
  config = lib.mkIf (config.users.primaryUser == username) {
    users.users.${username} = {
      isAdmin = true;
      extraGroups = [
        "wheel"
      ]
      ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirtd" ]
      ++ lib.optionals config.virtualisation.incus.enable [ "incus-admin" ]
      ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
      ++ lib.optionals config.virtualisation.podman.enable [ "podman" ];
    };
  };
}
