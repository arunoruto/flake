{ config, lib, ... }:
let
  cfg = config.services.frigate;
in
{
  config = lib.mkIf cfg.enable {
    services.frigate = {
      # nginx vhost name; Frigate is reached through its own port below.
      hostname = lib.mkDefault "frigate";
      settings = {
        ffmpeg.hwaccel_args = lib.mkIf (cfg.vaapiDriver != null) (lib.mkDefault "preset-vaapi");
        record = {
          enabled = lib.mkDefault true;
          continuous.days = lib.mkDefault 1;
        };
      };
    };

    # Frigate hangs on SIGTERM (its "Stopping..." log call errors out and the
    # process never exits), so every restart sat out the 90s default before
    # SIGKILL. Recording is cut by the kill either way; don't wait for it.
    systemd.services.frigate.serviceConfig.TimeoutStopSec = lib.mkDefault 10;

    # Frigate's usual authenticated port, so the vhost doesn't compete with
    # anything else nginx serves. Opening it in the firewall is left to hosts.
    services.nginx.virtualHosts.${cfg.hostname}.listen = lib.mkDefault [
      {
        addr = "0.0.0.0";
        port = 8971;
      }
    ];
  };
}
