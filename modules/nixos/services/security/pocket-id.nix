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
  pocket-id-env = "pocket-id.env";
in
{
  disabledModules = [ "services/security/pocket-id.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix"
    (lib.networking.mkTraefikModule {
      serviceName = "pocket-id";
      port = _: port;
      url = lib.strings.removePrefix "https://" config.services.pocket-id.settings.APP_URL;
    })
  ];
  config = lib.mkIf config.services.pocket-id.enable {
    services = {
      pocket-id = {
        package = pkgs.unstable.pocket-id;
        settings = {
          TRUST_PROXY = config.services.traefik.enable;
        };
        environmentFile = config.sops.templates."${pocket-id-env}".path;
        traefik.enable = true;
      };
      traefik.dynamicConfigOptions.http = {
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
    sops = {
      secrets = {
        "services/pocket-id/encryption-key" = { };
      };
      templates."${pocket-id-env}".content = ''
        ENCRYPTION_KEY=${config.sops.placeholder."services/pocket-id/encryption-key"}
      '';
    };
  };
}
