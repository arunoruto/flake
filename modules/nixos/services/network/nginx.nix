{
  config,
  lib,
  ...
}:
{
  # Traefik owns 80 and 443 wherever it runs (see ./traefik.nix). nginx then
  # moves its default listeners aside instead of failing to bind, and serves
  # its virtual hosts there -- directly on the LAN, or behind a Traefik router.
  # Backends that default to 8080 themselves have to move instead.
  config = lib.mkIf (config.services.nginx.enable && config.services.traefik.enable) {
    services.nginx = {
      defaultHTTPListenPort = lib.mkDefault 8080;
      defaultSSLListenPort = lib.mkDefault 8443;
    };
  };
}
