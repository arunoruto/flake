{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  port =
    if (config.services.pocket-id.settings ? PORT) then
      config.services.pocket-id.settings.PORT
    else
      1411;
in
{
  disabledModules = [ "services/security/pocket-id.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix" ];
  config = lib.mkIf config.services.pocket-id.enable {
    services = {
      pocket-id = {
        package = pkgs.unstable.pocket-id;
        settings = {
          TRUST_PROXY = config.services.traefik.enable;
        };
      };
      traefik.dynamicConfigOptions.http = {
        routers = {
          pocket-id = {
            # rule = "Host(`id.arnaut.me`)";
            rule = "Host(`${lib.strings.removePrefix "https://" config.services.pocket-id.settings.APP_URL}`)";
            tls.certresolver = "cf";
            entrypoints = "websecure";
            service = "pocket-id";
          };
        };
        services.pocket-id.loadbalancer.servers = [
          { url = "http://localhost:${builtins.toString port}"; }
        ];
        middlewares.pocket-id.plugin.traefik-oidc-auth = {
          Secret = "\${POCKET_ID_SECRET}";
          Provider = {
            Url = "https://id.arnaut.me";
            ClientId = "\${POCKET_ID_CLIENT}";
            ClientSecret = "\${POCKET_ID_SECRET}";
          };
          Scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
        };
      };
    };
  };
}
