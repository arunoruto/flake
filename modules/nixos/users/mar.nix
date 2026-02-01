{
  config,
  lib,
  ...
}:
let
  primaryUserName = config.users.primaryUser;
in
{
  # Define the mar user with admin privileges (only if mar is the primary user)
  config = lib.mkIf (primaryUserName == "mar") {
    users.users.mar = {
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
