{
  config,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;
  sabnzbdCfg = config.services.sabnzbd;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.sabnzbd.serviceConfig.ExecStart =
      lib.mkForce "${lib.getBin sabnzbdCfg.package}/bin/sabnzbd -d -f ${"/var/lib/${sabnzbdCfg.stateDir}/sabnzbd.ini"} -s 0.0.0.0:8082 --inet_exposure 5";

    systemd.tmpfiles.settings = {
      "sabnzbd" = {
        "/var/lib/sabnzbd".Z = {
          mode = "0755";
          inherit (sabnzbdCfg) user;
          inherit (sabnzbdCfg) group;
        };
      };
    };
  };
}
