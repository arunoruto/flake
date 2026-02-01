{
  config,
  lib,
  ...
}:
let
  username = "mirza";
in
{
  config = lib.mkIf (config.username == username) {
    users.users.${username} = {
      isAdmin = true;
      extraGroups = lib.mkIf (config.users.users.${username}.isAdmin or false) (
        [ "wheel" ]
        ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirtd" ]
        ++ lib.optionals config.virtualisation.incus.enable [ "incus-admin" ]
        ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
        ++ lib.optionals config.virtualisation.podman.enable [ "podman" ]
      );
    };
  };
}
