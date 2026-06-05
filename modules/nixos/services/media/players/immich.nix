{
  lib,
  pkgs,
  config,
  # inputs,
  ...
}:
# let
#   module = "services/web-apps/immich.nix";
# in
{
  # disabledModules = [ module ];
  # imports = [ "${inputs.nixpkgs-unstable.outPath}/nixos/modules/${module}" ];

  config = lib.mkIf config.services.immich.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        immich = {
          # package = pkgs.unstable.immich;
          environment = {
            IMMICH_VERSION = "2.3.1";
            IMMICH_LOG_LEVEL = "debug";
            # UPLOAD_LOCATION = lib.mkDefault "${cfg.dataDir}/photos";
          };
          host = "0.0.0.0";
          mediaLocation = lib.mkDefault "${cfg.dataDir}/photos";
          accelerationDevices = lib.mkDefault null;
          # settings = {
          #   oauth = lib.mkDefault {
          #     issuerUrl = "http://id.arnaut.me";
          #     clientId._secret = config.sops.secrets."services/immich/client-id".path;
          #     clientSecret._secret = config.sops.secrets."services/immich/client-secret".path;
          #     scope = "openid email profile";
          #     signingAlgorithm = "RS256";
          #     storageLabelClaim = "preferred_username";
          #     storageQuotaClaim = "immich_quota";
          #     defaultStorageQuota = null;
          #     buttonText = "Pocket-ID";
          #     enabled = true;
          #     profileSigningAlgorithm = "none";
          #     autoRegister = true;
          #     autoLaunch = false;
          #     mobileOverrideEnabled = false;
          #     mobileRedirectUri = "";
          #   };
          # };
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
        # tailscale.serve = {
        #   enable = true;
        #   config =
        #     let
        #       port = 2283;
        #     in
        #     {
        #       TCP = {
        #         "${builtins.toString port}" = {
        #           HTTPS = true;
        #         };
        #       };
        #       Web = {
        #         "${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net:${builtins.toString port}" =
        #           {
        #             Handlers = {
        #               "/" = {
        #                 Proxy = "http://127.0.0.1:${builtins.toString config.services.immich.port}";
        #               };
        #             };
        #           };
        #       };
        #       # AllowFunnel = {
        #       #   "mealie.auto-generated.ts.net:443" = true;
        #       # };
        #     };
        # };
      };
    users.users.immich.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
    sops = {
      secrets = {
        "services/immich/client-id" = { };
        "services/immich/client-secret" = { };
        # "config/maileroo/server" = { };
        # "config/maileroo/username" = { };
        # "config/maileroo/password" = { };
      };
      # templates."${paperless-oidc}".content = ''
      #   PAPERLESS_EMAIL_HOST=${config.sops.placeholder."config/maileroo/server"}
      #   PAPERLESS_EMAIL_PORT=587
      #   PAPERLESS_EMAIL_USE_TLS=true
      #   PAPERLESS_EMAIL_USE_SSL=false
      #   PAPERLESS_EMAIL_HOST_USER=${config.sops.placeholder."config/maileroo/username"}
      #   PAPERLESS_EMAIL_HOST_PASSWORD=${config.sops.placeholder."config/maileroo/password"}
      #   PAPERLESS_SOCIALACCOUNT_PROVIDERS=${
      #     builtins.toJSON {
      #       openid_connect = {
      #         OAUTH_PKCE_ENABLED = true;
      #         SCOPE = [
      #           "openid"
      #           "profile"
      #           "email"
      #         ];
      #         APPS = [
      #           {
      #             provider_id = "pocket-id";
      #             name = "Pocket-ID";
      #             client_id = config.sops.placeholder."services/paperless/client-id";
      #             secret = config.sops.placeholder."services/paperless/client-secret";
      #             settings.server_url = "https://id.arnaut.me";
      #           }
      #           {
      #             provider_id = "tsidp";
      #             name = "Tailscale Identity Provider";
      #             client_id = "unused";
      #             secret = "unused";
      #             settings.server_url = "http://localhost:${builtins.toString config.services.tailscale.tsidp.localPort}";
      #           }
      #         ];
      #       };
      #     }
      #   }'';
    };
  };
}
