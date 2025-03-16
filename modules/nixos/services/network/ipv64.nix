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

      domainPath = lib.mkOption {
        default = null;
        type = lib.types.string;
        description = "IPv64.net: path to domain name to update";
      };

      keyPath = lib.mkOption {
        default = null;
        type = lib.types.path;
        description = "IPv64.net: path to API key";
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
              ${lib.getExe pkgs.curl} -sSL "https://ipv64.net/nic/update?key=$(cat ${cfg.keyPath})&domain=$(cat ${cfg.domainPath}).ipv64.net"
            '';
            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
          };

          sops.secrets = {
            "tokens/ipv64/orahovica" = { };
            "tokens/ipv64/key" = { };
          };
        };
      };
  };
}
