{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.virtualisation.podman.enable {
    environment = {
      systemPackages = [ pkgs.podman-compose ];
      variables = {
        PODMAN_COMPOSE_WARNING_LOGS = "false";
      };
    };
  };
}
