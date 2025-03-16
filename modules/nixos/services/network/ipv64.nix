{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    services.ipv64-dyndns = {
      enable = lib.mkEnableOption "Enable ipv64.net dynamic DNS service";

      domainKeyPath = lib.mkOption {
        default = null;
        type = lib.types.str;
        description = "IPv64.net: path to the domain key (security level 2)";
      };
    };
  };

  config =
    let
      cfg = config.services.ipv64-dyndns;
    in
    lib.mkIf cfg.enable {
      systemd = {
        timers."ipv64-dyndns-update" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "24h";
            OnUnitActiveSec = "24h";
            Unit = "ipv64-dyndns-update.service";
          };
        };

        services."ipv64-dyndns-update" = {
          script = ''
            set -eu
            ${lib.getExe pkgs.curl} -sSL "https://ipv64.net/nic/update?key=$(cat ${cfg.domainKeyPath})"
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };
      };
      sops.secrets = {
        "tokens/ipv64/orahovica" = { };
      };
    };
}
