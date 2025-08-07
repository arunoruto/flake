{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.services.paperless.openFirewall = lib.mkEnableOption "Open firewall for Paperless";
  config = lib.mkIf config.services.paperless.enable {
    services =
      let
        url = "${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net";
      in
      {
        paperless =
          let
            cfg = config.services.media;
          in
          {
            package = lib.mkDefault pkgs.unstable.paperless-ngx;
            dataDir = lib.mkDefault "${cfg.dataDir}/paperless";
            configureTika = lib.mkDefault true;
            address = if config.services.paperless.openFirewall then "0.0.0.0" else "127.0.0.1";
            openFirewall = lib.mkDefault cfg.openFirewall;
            settings = {
              PAPERLESS_URL = "https://${url}";
              PAPERLESS_FORCE_SCRIPT_NAME = lib.mkDefault "/paperless";
              PAPERLESS_APPS = lib.mkDefault "allauth.socialaccount.providers.openid_connect";
              PAPERLESS_SOCIALACCOUNT_PROVIDERS = lib.mkDefault (
                builtins.toJSON {
                  openid_connect = {
                    OAUTH_PKCE_ENABLED = true;
                    SCOPE = [
                      "openid"
                      "profile"
                      "email"
                    ];
                    APPS = [
                      {
                        provider_id = "tsidp";
                        name = "Tailscale Identity Provider";
                        client_id = "unused";
                        secret = "unused";
                        settings = {
                          server_url = "http://localhost:${builtins.toString config.services.tailscale.tsidp.localPort}";
                        };
                      }
                    ];
                  };
                }
              );
            };
          };
        traefik.dynamicConfigOptions = lib.networking.traefikConfig {
          serviceName = "paperless";
          # url = "kuchiki.sparrow-yo.ts.net";
          inherit url;
          # url = config.services.paperless.settings.PAPERLESS_URL;
          port = config.services.paperless.port;
          path = config.services.paperless.settings.PAPERLESS_FORCE_SCRIPT_NAME;
        };

      };
    networking.firewall.allowedTCPPorts = lib.mkIf config.services.paperless.openFirewall [
      config.services.paperless.port
    ];
    # users.users.paperless.extraGroups = lib.optionals (config.users.groups ? "media") [
    #   config.users.groups.media.name
    # ];
  };
}
