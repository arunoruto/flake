lib: rec {
  # Per-service opt-in Traefik exposure. Import the returned module into a
  # service module to get `services.<serviceName>.traefik.{enable,url,path,cert}`
  # options and, once enabled, the matching `services.traefik.dynamicConfigOptions`
  # wiring via `traefikConfig` below.
  mkTraefikModule =
    {
      serviceName,
      port, # function: config -> port number, since the port's path differs per service
      url, # default hostname(s) to route to this service; string or list of strings
      path ? "/",
      cert ? "cf",
    }:
    { config, lib, ... }:
    let
      cfg = config.services.${serviceName}.traefik;
    in
    {
      options.services.${serviceName}.traefik = {
        enable = lib.mkEnableOption "Traefik reverse proxy exposure for ${serviceName}";
        url = lib.mkOption {
          type = with lib.types; either str (listOf str);
          default = url;
          description = "Hostname(s) Traefik should route to ${serviceName} on.";
        };
        path = lib.mkOption {
          type = lib.types.str;
          default = path;
          description = "PathPrefix Traefik should route to ${serviceName} on.";
        };
        cert = lib.mkOption {
          type = lib.types.str;
          default = cert;
          description = "Traefik certresolver to use for ${serviceName}.";
        };
      };

      config.services.traefik.dynamicConfigOptions = lib.mkIf cfg.enable (traefikConfig {
        inherit serviceName;
        inherit (cfg) url path cert;
        port = port config;
      });
    };

  traefikConfig =
    {
      serviceName,
      url,
      port,
      path ? "/",
      cert ? "cf",
    }:
    let
      host =
        if (builtins.isList url) then
          lib.strings.concatStringsSep " || " (lib.lists.forEach url (x: "Host(`${x}`)"))
        else
          "Host(`${url}`)";
    in
    {
      http = {
        routers."${serviceName}" = {
          rule = "(${host}) && PathPrefix(`${path}`)";
          tls.certresolver = cert;
          entrypoints = [ "websecure" ];
          service = serviceName;
        };
        services."${serviceName}".loadbalancer.servers = [
          {
            url = "http://localhost:${builtins.toString port}";
          }
        ];
      };
    };
}
