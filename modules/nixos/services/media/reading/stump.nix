{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ "${inputs.nixpkgs-unstable.outPath}/nixos/modules/services/web-apps/stump.nix" ];

  config = lib.mkIf config.services.stump.enable {
    services.stump = {
      package = pkgs.unstable.stump;
      port = 10001;
      openFirewall = lib.mkDefault false;

      environment = {
        STUMP_OIDC_ENABLED = "true";
        STUMP_OIDC_ISSUER_URL = "https://id.arnaut.me";
        STUMP_OIDC_SCOPES = "openid,email,profile";
        STUMP_OIDC_ALLOW_REGISTRATION = "true";
        STUMP_TRUST_PROXY_HEADERS = "true";
      };
      secretFiles = {
        STUMP_OIDC_CLIENT_ID = config.sops.secrets."services/stump/client-id".path;
        STUMP_OIDC_CLIENT_SECRET = config.sops.secrets."services/stump/client-secret".path;
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}".ingress = [
      {
        hostname = "stump.${config.services.cloudflared.defaultDomain}";
        service = "http://localhost:${builtins.toString config.services.stump.port}";
      }
    ];

    sops.secrets = {
      "services/stump/client-id" = {
        owner = config.services.stump.user;
      };
      "services/stump/client-secret" = {
        owner = config.services.stump.user;
      };
    };
  };
}
