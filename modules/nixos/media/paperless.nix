{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  paperless-oidc = "pocket-id-config.env";
in
{
  disabledModules = [ "services/misc/paperless.nix" ];
  imports = [ "${inputs.nixpkgs-unstable.outPath}/nixos/modules/services/misc/paperless.nix" ];
  # imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/hardware/cpu/amd-microcode.nix" ];

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
            # package = lib.mkDefault pkgs.paperless-ngx;
            dataDir = lib.mkDefault "${cfg.dataDir}/paperless";
            configureTika = lib.mkDefault true;
            address = if config.services.paperless.openFirewall then "0.0.0.0" else "127.0.0.1";
            openFirewall = lib.mkDefault cfg.openFirewall;
            settings = {
              PAPERLESS_URL = "https://${url}";
              PAPERLESS_FORCE_SCRIPT_NAME = lib.mkDefault "/paperless";
              PAPERLESS_APPS = lib.mkDefault "allauth.socialaccount.providers.openid_connect";
              PAPERLESS_CSRF_TRUSTED_ORIGINS = lib.strings.concatStringsSep "," [
                "https://services.arnaut.me"
                "https://${url}"
              ];
            };
            environmentFile = config.sops.templates."${paperless-oidc}".path;
          };
        traefik.dynamicConfigOptions = lib.networking.traefikConfig {
          serviceName = "paperless";
          inherit url;
          inherit (config.services.paperless) port;
          path = config.services.paperless.settings.PAPERLESS_FORCE_SCRIPT_NAME;
        };
      };
    networking.firewall.allowedTCPPorts = lib.mkIf config.services.paperless.openFirewall [
      config.services.paperless.port
    ];
    # users.users.paperless.extraGroups = lib.optionals (config.users.groups ? "media") [
    #   config.users.groups.media.name
    # ];

    sops = {
      secrets = {
        "services/paperless/client-id" = { };
        "services/paperless/client-secret" = { };
        "config/maileroo/server" = { };
        "config/maileroo/username" = { };
        "config/maileroo/password" = { };
      };
      templates."${paperless-oidc}".content = ''
        PAPERLESS_EMAIL_HOST=${config.sops.placeholder."config/maileroo/server"}
        PAPERLESS_EMAIL_PORT=587
        PAPERLESS_EMAIL_USE_TLS=true
        PAPERLESS_EMAIL_USE_SSL=false
        PAPERLESS_EMAIL_HOST_USER=${config.sops.placeholder."config/maileroo/username"}
        PAPERLESS_EMAIL_HOST_PASSWORD=${config.sops.placeholder."config/maileroo/password"}
        PAPERLESS_SOCIALACCOUNT_PROVIDERS=${
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
                  provider_id = "pocket-id";
                  name = "Pocket-ID";
                  client_id = config.sops.placeholder."services/paperless/client-id";
                  secret = config.sops.placeholder."services/paperless/client-secret";
                  settings.server_url = "https://id.arnaut.me";
                }
                {
                  provider_id = "tsidp";
                  name = "Tailscale Identity Provider";
                  client_id = "unused";
                  secret = "unused";
                  settings.server_url = "http://localhost:${builtins.toString config.services.tailscale.tsidp.localPort}";
                }
              ];
            };
          }
        }'';
    };
  };
}
