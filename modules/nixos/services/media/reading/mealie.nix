{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.mealie;
  host = "recipe.${config.services.cloudflared.defaultDomain}";
  dataDir = "${config.services.media.dataDir}/mealie";
  # Environment variable -> sops secret, rendered into one env file.
  envSecrets = {
    OIDC_CLIENT_ID = "services/mealie/client-id";
    OIDC_CLIENT_SECRET = "services/mealie/client-secret";
  };
in
{
  config = lib.mkIf cfg.enable {
    services.mealie = {
      # Recipe scrapers break as sites change; unstable carries the fixes.
      package = lib.mkDefault pkgs.unstable.mealie;
      # Reached only through the tunnel below.
      listenAddress = "127.0.0.1";
      # SQLite in DATA_DIR, the module's default database.
      settings = {
        BASE_URL = "https://${host}";
        DATA_DIR = dataDir;
        # Sign-in is Pocket ID's alone, so the seeded default admin
        # (changeme@example.com) can never log in on the public host. The
        # client's callback URL is https://<host>/login.
        ALLOW_SIGNUP = "false";
        ALLOW_PASSWORD_LOGIN = "false";
        OIDC_AUTH_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://id.arnaut.me/.well-known/openid-configuration";
        OIDC_PROVIDER_NAME = "Pocket ID";
        # Pocket ID's group for the people who get access to everything.
        OIDC_ADMIN_GROUP = "arnaut";
        OIDC_AUTO_REDIRECT = "true";
        # Stay signed in on the kitchen tablet.
        OIDC_REMEMBER_ME = "true";
      };
      credentialsFile = config.sops.templates."mealie.env".path;
    };

    # The upstream unit uses DynamicUser, whose state can only live under
    # /var/lib; the data goes on the appdata dataset with everything else.
    users.users.mealie = {
      isSystemUser = true;
      group = "mealie";
    };
    users.groups.mealie = { };
    systemd.services.mealie = {
      serviceConfig.DynamicUser = lib.mkForce false;
      unitConfig.RequiresMountsFor = [ dataDir ];
    };
    systemd.tmpfiles.settings."10-mealie".${dataDir}.d = {
      user = "mealie";
      group = "mealie";
      mode = "0750";
    };

    services.cloudflared.tunnels.${config.networking.hostName}.ingress =
      lib.mkIf config.services.cloudflared.enable
        [
          {
            hostname = host;
            service = "http://localhost:${toString cfg.port}";
          }
        ];

    sops.secrets = lib.genAttrs (lib.attrValues envSecrets) (_: { });
    sops.templates."mealie.env" = {
      restartUnits = [ "mealie.service" ];
      content = lib.concatStrings (
        lib.mapAttrsToList (var: secret: "${var}=${config.sops.placeholder.${secret}}\n") envSecrets
      );
    };
  };
}
