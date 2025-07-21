lib: {
  traefikTailscaleConfig =
    serviceName: config:
    lib.optionalAttrs config.services.tailscale.enable {
      http = {
        routers."${serviceName}" =
          let
            host = config.networking.hostName;
            tailnet = config.services.tailscale.tailnet;
            tailurl = "${host}.${tailnet}.ts.net";
          in
          {
            rule = "(Host(`${tailurl}`) || Host(`${host}`)) && PathPrefix(`/${serviceName}`)";
            tls.certresolver = "ts";
            entrypoints = [ "websecure" ];
            service = serviceName;
          };
        services."${serviceName}".loadbalancer.servers = [
          {
            url = "http://localhost:${builtins.toString config.services.${serviceName}.settings.server.port}";
          }
        ];
      };
    };
  arrConfig =
    serviceName: config: pkgs:
    let
      cfg = config.services.media;
    in
    lib.attrsets.recursiveUpdate
      {
        services = {
          "${serviceName}" = {
            package = lib.mkDefault pkgs."${serviceName}";
            openFirewall = lib.mkDefault cfg.openFirewall;
            environmentFiles = lib.mkDefault [
              (pkgs.writeTextFile {
                name = "${serviceName}-env";
                text = ''
                  ${lib.strings.toUpper serviceName}__AUTH__METHOD=External
                  ${lib.strings.toUpper serviceName}__SERVER__URLBASE=/${serviceName}
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
          ])
          {
            services."${serviceName}" = {
              dataDir = lib.mkDefault "${cfg.dataDir}/${serviceName}";
            };

            users.users."${serviceName}".extraGroups = lib.optionals (config.users.groups ? "media") [
              config.users.groups.media.name
            ];

            sops.secrets."tokens/arr/${serviceName}" = {
              mode = "0666";
              inherit (config.services.recyclarr) group;
            };
          }
      );

}
