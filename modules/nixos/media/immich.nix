{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.immich.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        immich = {
          # environment = {
          #   UPLOAD_LOCATION = lib.mkDefault "${cfg.dataDir}/photos";
          # };
          host = "0.0.0.0";
          mediaLocation = lib.mkDefault "${cfg.dataDir}/photos";
          accelerationDevices = lib.mkDefault null;
          settings = {
            oauth = lib.mkDefault {
              issuerUrl = "http://localhost:${builtins.toString config.services.tailscale.tsidp.localPort}";
              clientId = "unused";
              clientSecret = "unused";
              scope = "openid email profile";
              signingAlgorithm = "RS256";
              storageLabelClaim = "preferred_username";
              storageQuotaClaim = "immich_quota";
              defaultStorageQuota = null;
              buttonText = "Tailscale Identity Provider";
              enabled = false;
              profileSigningAlgorithm = "none";
              autoRegister = true;
              autoLaunch = false;
              mobileOverrideEnabled = false;
              mobileRedirectUri = "";
            };
          };
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
        tailscale.serve = {
          enable = true;
          config =
            let
              port = 2283;
            in
            {
              TCP = {
                "${builtins.toString port}" = {
                  HTTPS = true;
                };
              };
              Web = {
                "${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net:${builtins.toString port}" =
                  {
                    Handlers = {
                      "/" = {
                        Proxy = "http://127.0.0.1:${builtins.toString config.services.immich.port}";
                      };
                    };
                  };
              };
              # AllowFunnel = {
              #   "mealie.auto-generated.ts.net:443" = true;
              # };
            };
        };
      };
  };
}
