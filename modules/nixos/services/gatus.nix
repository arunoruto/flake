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
    tailnetChecks = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            host = lib.mkOption {
              type = lib.types.str;
              description = "Tailnet machine name.";
            };
            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "media";
              description = ''
                Group on the status page. Unset, the check is grouped by host;
                set, the host moves into its name ("plex (sado)").
              '';
            };
            port = lib.mkOption { type = lib.types.port; };
            path = lib.mkOption {
              type = lib.types.str;
              default = "/";
            };
            body = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "[BODY].status == OK";
              description = "Extra Gatus condition on the response, beyond HTTP 200.";
            };
          };
        }
      );
      default = [ ];
      description = ''
        Apps checked directly over the tailnet every 5 minutes, bypassing
        Cloudflare (Access would answer for them publicly). Separate from
        httpChecks, so a dead app and a dead tunnel are different alerts.
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
        endpoints =
          map (host: {
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
          }) cfg.httpChecks
          ++ map (check: {
            name = if check.group == null then check.name else "${check.name} (${check.host})";
            group = if check.group == null then check.host else check.group;
            url = "http://${check.host}.${config.services.tailscale.tailnet}.ts.net:${toString check.port}${check.path}";
            interval = "5m";
            conditions = [ "[STATUS] == 200" ] ++ lib.optional (check.body != null) check.body;
            alerts = alert { };
          }) cfg.tailnetChecks;
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
