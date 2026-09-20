lib: {
  # The servarr modules expose their port as `settings.server.port`; services
  # that live in the same family without sharing that base -- bazarr -- use a
  # plain `listenPort`. Resolve either, so callers never have to know which
  # flavour of module they are pointing traefik at.
  servicePort =
    serviceName: config:
    let
      cfg = config.services.${serviceName};
    in
    cfg.settings.server.port or cfg.listenPort;

  traefikTailscaleConfig =
    serviceName: config:
    lib.optionalAttrs config.services.tailscale.enable {
      http = {
        routers."${serviceName}" =
          let
            host = config.networking.hostName;
            inherit (config.services.tailscale) tailnet;
            tailurl = "${host}.${tailnet}.ts.net";
          in
          {
            # rule = "(Host(`${tailurl}`) || Host(`${host}`)) && PathPrefix(`/${serviceName}`)";
            rule = "Host(`${tailurl}`) && PathPrefix(`/${serviceName}`)";
            tls.certresolver = "ts";
            entrypoints = [ "websecure" ];
            service = serviceName;
          };
        services."${serviceName}".loadbalancer.servers = [
          {
            url = "http://localhost:${builtins.toString (lib.arr.servicePort serviceName config)}";
          }
        ];
      };
    };

  # The path every service is served under, both by the traefik router above and
  # by the service's own base-url setting. Keeping the two derived from one
  # place is what makes the subpath actually work: a router without a matching
  # base url serves an app that requests its assets from `/`.
  urlBase = serviceName: "/${serviceName}";

  arrConfig =
    serviceName: config: pkgs:
    let
      cfg = config.services.media;
      # servarr takes its url base from an environment file. bazarr has no such
      # option, but reads the same kind of setting straight from the process
      # environment via Dynaconf -- see `services.bazarr.environment`, which is
      # where its half of `urlBase` is applied.
      configurableViaEnvironment = config.services.${serviceName} ? environmentFiles;
    in
    lib.attrsets.recursiveUpdate
      {
        services = {
          "${serviceName}" = {
            package = lib.mkDefault pkgs."${serviceName}";
            openFirewall = lib.mkDefault cfg.openFirewall;
          }
          // lib.optionalAttrs configurableViaEnvironment {
            environmentFiles = lib.mkDefault [
              (pkgs.writeTextFile {
                name = "${serviceName}-env";
                text = ''
                  ${lib.strings.toUpper serviceName}__AUTH__METHOD=External
                  ${lib.strings.toUpper serviceName}__SERVER__URLBASE=${lib.arr.urlBase serviceName}
                '';
              }).outPath
            ];
          };
          traefik.dynamicConfigOptions = lib.arr.traefikTailscaleConfig serviceName config;
        };
      }

      (
        lib.optionalAttrs
          (builtins.elem serviceName [
            "radarr"
            "sonarr"
            "lidarr"
          ])
          {
            services."${serviceName}" = {
              dataDir = lib.mkDefault "${cfg.dataDir}/${serviceName}";
            };

            users.users."${serviceName}".extraGroups =
              (lib.optionals (config.users.groups ? "media") [
                config.users.groups.media.name
              ])
              ++ (lib.optionals config.services.syncthing.enable [ config.services.syncthing.group ]);
          }
        //
          lib.optionalAttrs
            (builtins.elem serviceName [
              "radarr"
              "sonarr"
            ])
            {
              sops.secrets."tokens/arr/${serviceName}" = {
                mode = "0666";
                inherit (config.services.recyclarr) group;
              };
            }
      );

}
