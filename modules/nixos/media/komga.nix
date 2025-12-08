{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.komga.enable {
    services = {
      komga = {
        settings = {
          server.port = 25600;
          komga = {
            oauth2-account-creation = true;
            oidc-email-verification = false;
          };
          spring.security.oauth2.client = {
            registration.pocket-id = {
              provider = "pocket-id";
              client-id = "\${KOMGA_OAUTH_CLIENT_ID}";
              client-secret = "\${KOMGA_OAUTH_CLIENT_SECRET}";
              client-name = "Pocket-ID";
              scope = "openid,email,profile";
              authorization-grant-type = "authorization_code";
              redirect-uri = "{baseUrl}/login/oauth2/code/{registrationId}";
              client-authentication-method = "client_secret_post";
            };
            provider.pocket-id = {
              user-name-attribute = "email";
              issuer-uri = "https://id.arnaut.me";
            };
          };
        };
      };
      cloudflared.tunnels."${config.networking.hostName}".ingress = [
        {
          hostname = "library.${config.services.cloudflared.defaultDomain}";
          service = "http://localhost:${builtins.toString config.services.komga.settings.server.port}";
        }
      ];
    };
    sops = {
      secrets = {
        "services/komga/client-id".owner = config.services.komga.user;
        "services/komga/client-secret".owner = config.services.komga.user;
      };
      templates."komga.env" = {
        content = ''
          KOMGA_OAUTH_CLIENT_ID=${config.sops.placeholder."services/komga/client-id"}
          KOMGA_OAUTH_CLIENT_SECRET=${config.sops.placeholder."services/komga/client-secret"}
        '';
        owner = config.services.komga.user;
      };
    };
    systemd.services.komga.serviceConfig.EnvironmentFile = config.sops.templates."komga.env".path;
  };
  # config = lib.mkMerge [
  #   (lib.mkIf config.services.komga.enable {
  #     services.komga = {
  #       settings = {
  #         server.port = 8080;
  #         komga = {
  #           oauth2-account-creation = true;
  #           oidc-email-verification = false;
  #         };
  #         spring.security.oauth2.client = {
  #           registration.pocket-id = {
  #             provider = "pocket-id";
  #             client-id = "\${KOMGA_OAUTH_CLIENT_ID}";
  #             client-secret = "\${KOMGA_OAUTH_CLIENT_SECRET}";
  #             client-name = "Pocket-ID";
  #             scope = "openid,email,profile";
  #             authorization-grant-type = "authorization_code";
  #             redirect-uri = "{baseUrl}/login/oauth2/code/{registrationId}";
  #             client-authentication-method = "client_secret_post";
  #           };
  #           provider.pocket-id = {
  #             user-name-attribute = "email";
  #             issuer-uri = "https://id.arnaut.me";
  #           };
  #         };
  #       };
  #     };
  #     sops = {
  #       secrets = {
  #         "services/komga/client-id".owner = config.services.komga.user;
  #         "services/komga/client-secret".owner = config.services.komga.user;
  #       };
  #       templates."komga.env" = {
  #         content = ''
  #           KOMGA_OAUTH_CLIENT_ID=${config.sops.placeholder."services/komga/client-id"}
  #           KOMGA_OAUTH_CLIENT_SECRET=${config.sops.placeholder."services/komga/client-secret"}
  #         '';
  #         owner = config.services.komga.user;
  #       };
  #     };
  #     systemd.services.komga.serviceConfig.EnvironmentFile = config.sops.templates."komga.env".path;
  #   })
  #   (lib.mkIf (config.services.komga.enable && config.services.cloudflared.enable) {
  #     services.cloudflared.tunnels."${config.networking.hostName}".ingress = [
  #       {
  #         hostname = "library.${config.services.cloudflared.defaultDomain}";
  #         # path = "/prowlarr.*";
  #         service = "http://localhost:${builtins.toString config.services.komga.settings.server.port}";
  #       }
  #     ];
  #   })
  # ];
}
