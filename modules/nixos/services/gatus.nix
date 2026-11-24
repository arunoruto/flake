# Gatus with this repo's defaults: SQLite history, alerts to the ntfy topic
# the auto-upgrades use, and two plain lists for what to watch. The lists are
# written out on the monitoring host on purpose: reading them from every other
# host's config would evaluate the whole fleet inside this one.
{
  config,
  lib,
  ...
}:
let
  cfg = config.services.gatus;
  alert = extra: [ ({ type = "custom"; } // extra) ];
in
{
  options.services.gatus = {
    httpChecks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "id.arnaut.me" ];
      description = ''
        Public hostnames checked over HTTPS every 5 minutes. Any answer below
        500 passes: login redirects and 401s mean the app answered, while
        Cloudflare's 502/530 mean the origin or tunnel is down, and no answer
        at all fails.
      '';
    };
    upgradeHeartbeats = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "aizen" ];
      description = ''
        Hosts whose nixos-upgrade checks in after each successful run
        (system/upgrade.nix). One that has not for 26 hours, because it
        skipped, failed or never ran, raises an alert.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      environmentFile = config.sops.templates."gatus.env".path;
      settings = {
        web.port = lib.mkDefault 8090;
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };
        # Gatus expands ${VAR} from its environment, so the secrets stay out
        # of the store. "custom" rather than "ntfy": the latter wants the topic
        # on its own, and the secret holds the whole topic URL.
        alerting.custom = {
          url = "\${NTFY_URL}";
          method = "POST";
          headers = {
            Title = "Gatus";
            Tags = "rotating_light";
          };
          body = "[ALERT_TRIGGERED_OR_RESOLVED]: [ENDPOINT_GROUP]/[ENDPOINT_NAME] [ALERT_DESCRIPTION] [RESULT_ERRORS]";
          default-alert = {
            send-on-resolved = true;
            failure-threshold = 3;
            success-threshold = 2;
          };
        };
        endpoints = map (host: {
          name = host;
          group = "public";
          url = "https://${host}";
          interval = "5m";
          # CONNECTED too: a DNS or connection failure has no status, which
          # would pass `< 500` on its own.
          conditions = [
            "[CONNECTED] == true"
            "[STATUS] < 500"
          ];
          alerts = alert { };
        }) cfg.httpChecks;
        # Pushed to at /api/v1/endpoints/upgrades_<host>/external.
        external-endpoints = map (host: {
          name = host;
          group = "upgrades";
          token = "\${GATUS_HEARTBEAT_TOKEN}";
          heartbeat.interval = "26h";
          alerts = alert {
            description = "no successful auto-upgrade for 26h";
            failure-threshold = 1;
          };
        }) cfg.upgradeHeartbeats;
      };
    };

    sops.secrets = {
      "tokens/ntfy/upgrade" = { };
      "tokens/gatus/heartbeat" = { };
    };
    sops.templates."gatus.env" = {
      content = ''
        NTFY_URL=${config.sops.placeholder."tokens/ntfy/upgrade"}
        GATUS_HEARTBEAT_TOKEN=${config.sops.placeholder."tokens/gatus/heartbeat"}
      '';
      restartUnits = [ "gatus.service" ];
    };
  };
}
